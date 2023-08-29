"""Crawl specific YT channels and download the matches."""


import datetime as dt
from pathlib import Path
from typing import Any

from yt_dlp import YoutubeDL

from src.data.models import Comment
from src.data.models import Video

class YTCrawler:
    """YT Downloader."""

    def __init__(self) -> None:
        pass

    def _parse_info_to_video(self, info: dict[str, Any]):
        video = Video(
            id=info["id"],
            title=info["title"],
            description=info["description"],
            channel_id=info["channel_id"],
            duration=info["duration"],
            view_count=0 if info["view_count"] is None else info["view_count"],
            like_count=0 if info["like_count"] is None else info["like_count"],
            comment_count=0 if info["comment_count"] is None else info["comment_count"],
            datetime_upload=dt.datetime.strptime(info["upload_date"], "%Y%m%d"),
            was_live=info["was_live"],
            relative_file_path="testpath/file.m4a",
        )

        for c_info in info["comments"]:
            comment = Comment(
                id=c_info["id"],
                text=c_info["text"],
                datetime_upload=dt.datetime.fromtimestamp(c_info["timestamp"]),
                parent=c_info["parent"],
                like_count=0 if c_info["like_count"] is None else c_info["like_count"],
                author=c_info["author"],
                author_is_uploader=c_info["author_is_uploader"],
                is_favorited=c_info["is_favorited"],
            )

            video.comments.append(comment)

        return video


class YTDownload:
    """Download a specific video."""

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
        self.ydl_opts = {
            "format": "m4a/bestaudio/best",
            # ℹ️ See help(yt_dlp.postprocessor) for a list of available Postprocessors
            "postprocessors": [
                {
                    # Extract audio using ffmpeg
                    "key": "FFmpegExtractAudio",
                    "preferredcodec": "m4a",
                },
            ],
        }

        self.ydl_opts["outtmpl"] = str(output / filename)

        self.ydl_info_opts = {
            "getcomments": True,
        }
        self.ydl_info_opts.update(self.ydl_opts)

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

    def extract_info(self, url: str):
        """Get Info of a specific video. Includes comments.

        Args:
            url (str): Full video URL.

        Returns:
            dict: Sanitized info dict returned by yt_dlp.
        """
        with YoutubeDL(self.ydl_info_opts) as ydl:
            info = ydl.extract_info(url, download=False)
            info = ydl.sanitize_info(info)
        return info
