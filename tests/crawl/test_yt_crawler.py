from src.crawl.yt_crawler import YTDownload

def test_download(tmp_path):

    ydl = YTDownload(output=tmp_path)
    # yt-dlp test video
    url = "https://www.youtube.com/watch?v=BaW_jenozKc"
    ydl.download(url)

    assert len(list(tmp_path.iterdir())) == 1
