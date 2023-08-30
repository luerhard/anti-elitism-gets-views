"""Crawl specific YT channels and download the matches."""


import datetime as dt
from pathlib import Path
from typing import Any

from sqlalchemy.engine import Engine
from sqlalchemy.orm import Session
from yt_dlp import YoutubeDL

from src.data.models import Channel
from src.data.models import Comment
from src.data.models import Video

class YTCrawler:
    """YT Downloader."""

    def __init__(self, engine: Engine, output: Path) -> None:
        self.engine = engine
        self.ydl = YTDownload(output=output)

    def add_video(self, info: dict[str, Any]):
        """Adds a video info dict to the database.

        Args:
            info (dict[str, Any]): Video info.
        """
        with Session(self.engine) as s:
            video = s.query(Video).filter(Video.id == info["id"]).one_or_none()
            if not video:
                video = self._parse_info_to_video(info)

            for c_info in info["comments"]:
                comment = (
                    s.query(Comment).filter(Comment.id == c_info["id"]).one_or_none()
                )
                if not comment:
                    comment = self._parse_single_comment(c_info)
                video.comments.append(comment)

            try:
                s.add(video)
                s.commit()
            except Exception:
                s.rollback()
                raise


    @staticmethod
    def _parse_info_to_video(info: dict[str, Any]) -> Video:
        return Video(
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
            relative_file_path=None,
        )

    @staticmethod
    def _parse_single_comment(c_info: dict[str, Any]) -> Comment:
        return Comment(
            id=c_info["id"],
            text=c_info["text"],
            datetime_upload=dt.datetime.fromtimestamp(c_info["timestamp"]),
            parent=c_info["parent"],
            like_count=0 if c_info["like_count"] is None else c_info["like_count"],
            author=c_info["author"],
            author_is_uploader=c_info["author_is_uploader"],
            is_favorited=c_info["is_favorited"],
        )

    def _parse_channel_info(self, info: dict[str, Any]) -> Channel:
        pass


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

        output = Path(output)
        self.ydl_opts["outtmpl"] = str(output / filename)

        self.ydl_video_info_opts = {
            "getcomments": True,
        }
        self.ydl_video_info_opts.update(self.ydl_opts)

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

    def extract_channel_info(self, url: str) -> dict:
        """Get all videos of a channel.

        Args:
            url (str): Channel URL. Form should be: youtube.com/@ChannelName

        Returns:
            dict: Channel dict. key "entries" has a list of videos.
        """
        with YoutubeDL(self.ydl_opts) as ydl:
            info = ydl.extract_info(url, download=False)
            info = ydl.sanitize_info(info)
        return info

    def extract_video_info(self, url: str) -> dict:
        """Get Info of a specific video. Includes comments.

        Args:
            url (str): Full video URL.

        Returns:
            dict: Sanitized info dict returned by yt_dlp.
        """
        with YoutubeDL(self.ydl_video_info_opts) as ydl:
            info = ydl.extract_info(url, download=False)
            info = ydl.sanitize_info(info)
        return info
