"""Downloads all Data from Youtube.

- YTCHANNELS should be a list of channel urls that are to be crawled.
- Subfolders for channels will be created automatically.
"""
from sqlalchemy import create_engine

import src
from src.crawl import YTChannelCrawler

STORAGE_PATH = src.PATH / "data/yt"
STORAGE_PATH.mkdir(parents=True, exist_ok=True)
ENGINE = create_engine(f"sqlite:///{STORAGE_PATH / 'db.sqlite'}")

YTCHANNELS = [
    "https://www.youtube.com/@sonorityofficial9831",
]


def main():
    for channel_url in YTCHANNELS:
        ycc = YTChannelCrawler(channel_url=channel_url, engine=ENGINE, output=STORAGE_PATH)
        ycc.download_channel()


if __name__ == "__main__":
    main()
