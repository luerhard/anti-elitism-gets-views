import json

from sqlalchemy import create_engine
from sqlalchemy.orm import Session

import src
from src.crawl.yt_crawler import YTCrawler
from src.data.models import Base
from src.data.models import Video

class TestDB:

    @classmethod
    def setup_class(cls):
        cls.engine = create_engine("sqlite:////home/lukas/Desktop/sqlite.db")
        Base.metadata.create_all(cls.engine)

    @classmethod
    def teardown_class(cls):
        pass

    def test_insert_video(self):
        path = src.PATH / "tests/testdata/info.json"
        with path.open("r") as f:
            info = json.load(f)

        assert len(info) == 81

        crawler = YTCrawler()
        video = crawler.add_video(info)

        with Session(self.engine) as s:
            s.add(video)
            s.commit()

        with Session(self.engine) as s:
            videos = s.query(Video).all()

        assert len(videos) == 1
