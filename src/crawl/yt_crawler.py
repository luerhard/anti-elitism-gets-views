"""Crawl specific YT channels and download the matches."""


from pathlib import Path
from typing import Any

from yt_dlp import YoutubeDL

class YTCrawler:
    """YT Downloader."""

    def __init__(self) -> None:
        pass


class YTDownload:
    """Download a specific video."""

    ydl_opts = {
        "format": "m4a/bestaudio/best",
        # ℹ️ See help(yt_dlp.postprocessor) for a list of available Postprocessors
        "postprocessors": [{
            # Extract audio using ffmpeg
            "key": "FFmpegExtractAudio",
            "preferredcodec": "m4a",
        }],
        }

    def __init__(self, output: Path, filename: str = "%(title)s.%(ext)s") -> None:
        """Create a Downloader.

        Args:
            output (Path): Folder where all files should be saved to
            filename (str): File name template. Defaults to "%(title)s.%(ext)s".
                Default is taken from https://stackoverflow.com/a/72465857/7820587. Might be better
                names. Should check in the future...

                One option is: %(uploader)s/  -- to create automatic subfolder for the uploader
                    name.
        """
        self.ydl_opts["outtmpl"] = str(output / filename)

    def download(self, url: str):
        """Download a video from youtube.

        Settings will be read from the class variable.

        Args:
            url (str): Full URL.
        """
        self._download(url=url, settings=self.ydl_opts)

    @staticmethod
    def _download(url: str, settings: dict[Any]):
        with YoutubeDL(settings) as ydl:
            ydl.download([url])
