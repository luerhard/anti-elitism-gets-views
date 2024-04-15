import json

from sqlalchemy import create_engine
from sqlalchemy.orm import Session

import src
from src.crawl.yt_crawler import YTChannelCrawler
from src.data.models import Base
from src.data.models import Video

class TestDB:
    @classmethod
    def setup_class(cls):
        cls.engine = create_engine("sqlite://")
        Base.metadata.create_all(cls.engine)

    @classmethod
    def teardown_class(cls):
        pass

    def test_insert_video(self, tmp_path):
        path = src.PATH / "tests/testdata/info.json"
        channel_url = "https://www.youtube.com/@PhilippHagemeister"
        with path.open("r") as f:
            info = json.load(f)

        assert len(info) == 81

        crawler = YTChannelCrawler(engine=self.engine, channel_url=channel_url, output=tmp_path)
        comments = crawler._parse_comments(info)
        video = crawler._parse_info_to_video(info)
        crawler.add_video(crawler.channel, video, comments)

        with Session(self.engine) as s:
            videos = s.query(Video).all()
            comments = videos[0].comments

        assert len(videos) == 1
        assert len(comments) == 84
