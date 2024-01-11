import pytest
from sqlalchemy import create_engine

from src.crawl.yt_crawler import YTCrawler, YTDownload

@pytest.mark.online()
def test_download(tmp_path):
    ydl = YTDownload(output=tmp_path)
    # yt-dlp test video
    url = "https://www.youtube.com/watch?v=BaW_jenozKc"
    ydl.download(url)

    assert len(list(tmp_path.iterdir())) == 1


@pytest.mark.online()
def test_extract_video_info(tmp_path):
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

    @pytest.mark.online()
    def test_download_and_insert(self, tmp_path):
        ytc = YTCrawler(engine = self.engine, output=tmp_path)
        # yt-dlp test video
        url = "https://www.youtube.com/watch?v=BaW_jenozKc"
        
        ytc.download_video(url)


