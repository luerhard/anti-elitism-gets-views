"""Downloads all Data from Youtube.

- YTCHANNELS should be a list of channel urls that are to be crawled.
- Subfolders for channels will be created automatically.
"""

import src
from src.crawl import YTChannelCrawler
from src.logging import logger as log

STORAGE_PATH = src.PATH / "data/raw/yt"
STORAGE_PATH.mkdir(parents=True, exist_ok=True)

YTCHANNELS = [
    # "https://www.youtube.com/@AfDFraktionimBundestag",
    # "https://www.youtube.com/@AfDTV",
    # "https://www.youtube.com/@DieGruenen",
    # "https://www.youtube.com/@gruenebundestag",
    # "https://www.youtube.com/@spdde",
    # "https://www.youtube.com/@spdbt",
    # "https://www.youtube.com/@csumedia",
    # "https://www.youtube.com/@csuimbundestag9622",
    # "https://www.youtube.com/@cdutv",
    # "https://www.youtube.com/@cducsu",
    # "https://www.youtube.com/@DIELINKE",
    "https://www.youtube.com/@linksfraktion",  # bis Ende 2023
    "https://www.youtube.com/@dielinkebt",  # ab 2023
    "https://www.youtube.com/@FDP",
    "https://www.youtube.com/@fdpbt",
]


def main():
    for channel_url in YTCHANNELS:
        log.info("Starting Channel: %s", channel_url)
        ycc = YTChannelCrawler(
            channel_url=channel_url,
            output=STORAGE_PATH,
            start_date="2017-12-06",
        )
        ycc.download_channel()


if __name__ == "__main__":
    main()
