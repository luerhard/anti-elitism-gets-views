from pathlib import Path
import pytest
from sqlalchemy import create_engine

from src.crawl.yt_crawler import YTCrawler
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
        cls.engine = create_engine("sqlite:////home/lukas/Desktop/test.sqlite")
        # cls.engine = create_engine("sqlite:///:memory:")

    @pytest.mark.online()
    def test_download_and_insert(self, tmp_path: Path):
        ytc = YTCrawler(engine=self.engine, output=tmp_path)
        # yt-dlp test video
        url = "https://www.youtube.com/watch?v=BaW_jenozKc"

        ytc.download_video(url)

    @pytest.mark.online()
    def test_download_channel(self):
        ytc = YTCrawler(engine=self.engine, output="/home/lukas/Desktop/channel_videos")
        # yt-dlp test video
        channel_url = "https://www.youtube.com/@sonorityofficial9831"

        ytc.download_channel(channel_url)