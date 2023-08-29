import pytest

from src.crawl.yt_crawler import YTDownload

@pytest.mark.online()
def test_download(tmp_path):
    ydl = YTDownload(output=tmp_path)
    # yt-dlp test video
    url = "https://www.youtube.com/watch?v=BaW_jenozKc"
    ydl.download(url)

    assert len(list(tmp_path.iterdir())) == 1


@pytest.mark.online()
def test_extract_info(tmp_path):
    ydl = YTDownload(output=tmp_path)
    # yt-dlp test video
    url = "https://www.youtube.com/watch?v=BaW_jenozKc"
    info = ydl.extract_info(url)

    assert info["title"] == "youtube-dl test video \"'/\\ä↭𝕐"
    assert info["id"] == "BaW_jenozKc"
