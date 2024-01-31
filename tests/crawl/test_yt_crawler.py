from pathlib import Path

import pytest
from sqlalchemy import create_engine

from src.crawl.yt_crawler import YTChannelCrawler
from src.crawl.yt_crawler import YTDownload

@pytest.mark.online()
def test_download(tmp_path: Path):
    ydl = YTDownload(output=tmp_path)
    # yt-dlp test video
    url = "https://www.youtube.com/watch?v=BaW_jenozKc"
    ydl.download(url)

    assert len(list(tmp_path.iterdir())) == 1


@pytest.mark.online()
def test_extract_video_info(tmp_path: Path):
    ydl = YTDownload(output=tmp_path)
    # yt-dlp test video
    url = "https://www.youtube.com/watch?v=BaW_jenozKc"
    info = ydl.extract_video_info(url)

    assert info["title"] == "youtube-dl test video \"'/\\ä↭𝕐"
    assert info["id"] == "BaW_jenozKc"


class TestDBInsert:
    @classmethod
    def setup_class(cls):
        # cls.engine = create_engine("sqlite:////home/lukas/Desktop/testing/test.sqlite")
        cls.engine = create_engine("sqlite:///:memory:")

    @pytest.mark.online()
    def test_download_channel(self, tmp_path):
        ytc = YTChannelCrawler(
            engine=self.engine,
            channel_url="https://www.youtube.com/@sonorityofficial9831",
            output=tmp_path,
        )
        ytc.download_channel_videos()
