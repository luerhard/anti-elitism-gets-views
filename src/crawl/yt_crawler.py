"""Crawl specific YT channels and download the matches."""


from collections.abc import Iterable
import datetime as dt
from pathlib import Path
import re
import shutil
import tempfile
from typing import Any
from urllib.parse import urlparse

from sqlalchemy import or_
from sqlalchemy.engine import Engine
from sqlalchemy.orm import Session
from yt_dlp import YoutubeDL
from yt_dlp.utils import DownloadError

from src.data.models import Base
from src.data.models import Channel
from src.data.models import Comment
from src.data.models import Video
from src.logging import logger as log

class YTChannelCrawler:
    """YT Downloader."""

    def __init__(self, channel_url: str, engine: Engine, output: Path) -> None:
        self.channel_url = channel_url
        self.output = output

        self.engine = engine
        Base.metadata.create_all(bind=engine)
        self.s = Session(self.engine, expire_on_commit=False)

        self.ydl = YTDownload(output=self.output)
        self.info = self.ydl.extract_channel_info(channel_url, channel_only=True)
        self.channel = self.get_channel_by_url(self.channel_url)

        self.subfolder = self.output / str(self.channel.uploader_id)
        self.subfolder.mkdir(parents=True, exist_ok=True)
        log.info("init done.")

    @staticmethod
    def _extract_video_ids(info):
        """Retuns a list of video ids from the info dict."""
        ids = [entry["id"] for entry in info["entries"]]
        return ids

    def download_channel(self):
        """Download all channel videos. Wrapper around functions for videos and shorts."""
        log.warning("starting channel videos")
        self.download_channel_videos()
        log.warning("starting channel shorts")
        self.download_channel_shorts()

    def download_channel_shorts(self):
        """Starts the download process for the whole channel."""
        video_url = f"{self.channel_url.rstrip('/')}/shorts"
        info = self.ydl.extract_channel_info(video_url)
        all_ids = self._extract_video_ids(info)
        base_url = "https://www.youtube.com/shorts/"
        for id_ in all_ids:
            url = base_url + id_
            if self._video_already_exists(id_):
                log.debug("VideoID %s already exists. Skipping...", id_)
                continue
            try:
                self._download_video(url=url, channel=self.channel, format="shorts")
            except DownloadError as exc:
                log.warning("Having Download Error")
                continue

    def download_channel_videos(self):
        """Starts the download process for the whole channel."""
        video_url = f"{self.channel_url.rstrip('/')}/videos"
        info = self.ydl.extract_channel_info(video_url)
        all_ids = self._extract_video_ids(info)
        base_url = "https://www.youtube.com/watch?v="
        for id_ in all_ids:
            url = base_url + id_
            if self._video_already_exists(id_):
                log.debug("VideoID %s already exists. Skipping...", id_)
                continue
            try:
                self._download_video(url=url, channel=self.channel, format="videos")
            except DownloadError as exc:
                log.warning("Having Download Error")
                continue

    def _download_video(self, url, channel, format):
        info = self.ydl.extract_video_info(url)
        video = self._parse_info_to_video(info)
        if self._video_already_exists(video):
            print("Video already exists!")
            return
        video.format = format
        comments = self._parse_comments(info)
        file_path = self.ydl.download(url=url, subfolder=self.subfolder / format)
        video.relative_file_path = str(file_path.relative_to(self.output))
        self.add_video(channel, video, comments)

    def _video_already_exists(self, video: Video | str) -> bool:
        if isinstance(video, Video):
            video = self.s.query(Video).filter(Video.id == video.id).one_or_none()
        elif isinstance(video, str):
            video = self.s.query(Video).filter(Video.id == video).one_or_none()
        else:
            msg = "Undefined format for video!"
            raise Exception(msg)

        if not video:
            return False
        return True

    def _comment_already_exists(self, comment: Comment) -> bool:
        comment = self.s.query(Comment).filter(Comment.id == comment.id).one_or_none()
        if comment:
            return True
        return False

    def get_channel_by_url(self, channel_url):
        """Returns a Channel object of a channel url.

        Adds to DB if the Channel does not already exist.

        Args:
            channel_url: The URL of the Channel. Can be the @-id or the actual channel id.
        """
        name = re.match("/(@(.*?))(/|$)", urlparse(channel_url).path).group(1)

        channel = (
            self.s.query(Channel)
            .filter(or_(Channel.uploader_id == name, Channel.id == name))
            .one_or_none()
        )

        if channel:
            return channel

        channel = Channel(
            id=self.info["channel_id"],
            channel=self.info["channel"],
            uploader_id=self.info["uploader_id"],
            title=self.info["title"],
            description=self.info["description"],
            channel_follower_count=self.info["channel_follower_count"],
            channel_url=self.info["uploader_url"],
            playlist_count=self.info["playlist_count"],
        )

        self.s.add(channel)
        self.s.commit()
        return channel

    def add_video(self, channel: Channel, video: Video, comments: Iterable[Comment] | None):
        """Adds a video info dict to the database.

        Args:
            channel: Channel object the video belongs to.
            video: Video object.
            comments: An Iterable with all Comment object to that video.
        """
        log.debug("Adding Video: %s", video.title)
        for comment in comments:
            video.comments.append(comment)

        video.channel = channel

        self.s.add(video)
        self.s.commit()

    @staticmethod
    def _copy_video_file(source: Path, destination_folder: Path):
        filename = source.name
        destination_file = destination_folder / filename

        if not (destination_file).exists():
            destination_file.replace(source)
        else:
            msg = f"File already exists in Storage Folder! {filename}"
            raise Exception(msg)

        return destination_file

    @staticmethod
    def _parse_info_to_video(info: dict[str, Any]) -> Video:
        return Video(
            id=info["id"],
            title=info["title"],
            description=info["description"],
            channel_id=info["channel_id"],
            duration=info["duration"],
            view_count=0 if info.get("view_count") is None else info["view_count"],
            like_count=0 if info.get("like_count") is None else info["like_count"],
            comment_count=0 if info.get("comment_count") is None else info["comment_count"],
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

    def _parse_comments(self, info: dict[str, Any]) -> list[Comment]:
        comments = []

        # happens when comments are turned of on a video
        if info["comments"] is None:
            return comments

        for c_info in info["comments"]:
            comment = self._parse_single_comment(c_info)
            comments.append(comment)

        return comments

    def _parse_channel_info(self, info: dict[str, Any]) -> Channel:
        pass


class YTDownload:
    """Download a specific video."""

    def __init__(self, output: Path, filename: str = "%(id)s.%(ext)s") -> None:
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

        self.output = Path(output)
        self.output.mkdir(parents=True, exist_ok=True)
        self.filename = filename
        self.ydl_video_info_opts = {
            "getcomments": True,
            "writeinfojson": True,
        }
        self.ydl_video_info_opts.update(self.ydl_opts)

    def download(self, url: str, subfolder: Path | None = None) -> Path:
        """Download a video from youtube.

        Settings will be read from the class variable.

        Args:
            url (str): Full URL.
            subfolder: If the file should be downloaded to a subfolder in output, a folder can
                be passed here.
        """
        if subfolder:
            output = self.output / subfolder
            output.mkdir(parents=True, exist_ok=True)
        else:
            output = self.output

        with tempfile.TemporaryDirectory(ignore_cleanup_errors=True) as tmpdir:
            tmpdir = Path(tmpdir)
            self.ydl_opts["outtmpl"] = str(tmpdir / self.filename)
            self._download(url=url, settings=self.ydl_opts)
            files_in_folder = list(tmpdir.iterdir())
            assert len(files_in_folder) == 1
            f = files_in_folder[0]
            shutil.move(f, output / f.name)
        return output / f.name

    def _download(self, url: str, settings: dict[Any]):
        with YoutubeDL(settings) as ydl:
            ydl.download([url])

    def extract_channel_info(self, url: str, channel_only: bool = False) -> dict:
        """Get all videos of a channel.

        Args:
            url (str): Channel URL. Form should be: youtube.com/@ChannelName
            channel_only: If True, restricts the query to only 1 video. Just to get the channel
                info as fast as possible.

        Returns:
            dict: Channel dict. key "entries" has a list of videos.
        """
        ydl_opts = {
            "extract_flat": "in_playlist",
            "allow_playlist_files": True,
            "writeinfojson": False,
        }

        if channel_only:
            ydl_opts["playlistend"] = 1

        with YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(url)
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
