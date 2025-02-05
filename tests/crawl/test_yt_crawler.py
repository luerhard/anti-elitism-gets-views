from pathlib import Path
import zipfile

import pytest

import src
from src.crawl.yt_crawler import YTChannelCrawler
from src.crawl.yt_crawler import YTDownload


@pytest.mark.online
@pytest.mark.slow
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
    info = ydl.get_video_info(url)

    assert info["title"] == "youtube-dl test video [BaW_jenozKc]"
    assert info["id"] == "DTi8wZ1a1TA"


@pytest.mark.online
@pytest.mark.slow
def test_channel_crawler():
    channel = "https://www.youtube.com/@sonorityofficial9831"
    yt_channel_crawler = YTChannelCrawler(channel_url=channel, output=src.PATH / "data/raw/yt")
    yt_channel_crawler.download_channel_videos()

    with zipfile.ZipFile(yt_channel_crawler.meta_file_folder, "r") as archive:
        n_meta_files = sum(1 for _ in archive.namelist())
    n_video_files = sum(1 for _ in yt_channel_crawler.video_file_folder.iterdir())

    assert n_meta_files == 7
    assert n_video_files == 7
