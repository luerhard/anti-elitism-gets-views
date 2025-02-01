from pathlib import Path

import pytest

from src.crawl.yt_crawler import YTDownload


@pytest.mark.online
def test_download(tmp_path: Path):
    ydl = YTDownload(output=tmp_path)
    # yt-dlp test video
    url = "https://www.youtube.com/watch?v=DTi8wZ1a1TA"
    ydl.download(url)

    assert len(list(tmp_path.iterdir())) == 1


@pytest.mark.online
def test_extract_video_info(tmp_path: Path):
    ydl = YTDownload(output=tmp_path)
    # yt-dlp test video
    url = "https://www.youtube.com/watch?v=DTi8wZ1a1TA"
    info = ydl.extract_video_info(url)

    assert info["title"] == "youtube-dl test video [BaW_jenozKc]"
    assert info["id"] == "DTi8wZ1a1TA"
