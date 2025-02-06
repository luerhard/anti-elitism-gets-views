"""Crawl specific YT channels and download the matches."""

import json
from pathlib import Path
import re
import shutil
import tempfile
from typing import Any
from urllib.parse import urlparse
from zipfile import ZIP_DEFLATED
from zipfile import ZipFile

from yt_dlp import YoutubeDL
from yt_dlp.utils import DownloadError

from src.logging import logger as log


class YTChannelCrawler:
    """YT Downloader."""

    def __init__(self, channel_url: str, output: Path) -> None:
        self.channel_url = channel_url
        self.output = output

        self.uploader_id = self.get_uploader_id(self.channel_url)
        self.subfolder = self.output / self.uploader_id
        self.subfolder.mkdir(parents=True, exist_ok=True)
        self.channel_metadata_file = self.subfolder / "channel_metadata.json"

        self.video_file_folder = self.subfolder / "videos"
        self.video_file_folder.mkdir(parents=True, exist_ok=True)

        self.meta_file_folder = self.subfolder / "metadata.zip"
        if not self.meta_file_folder.is_file():
            with ZipFile(self.meta_file_folder, "w", compression=ZIP_DEFLATED) as _:
                pass

        self.ydl = YTDownload(output=self.video_file_folder)
        self.channel_info = self.get_channel_info(self.channel_url)

        log.info("init done.")

    def get_channel_info(self, channel_url):
        if not self.channel_metadata_file.is_file():
            info = self.ydl.get_channel_info(channel_url, channel_only=False)
            with self.channel_metadata_file.open("w") as file:
                json.dump(info, file, ensure_ascii=False, indent=2)
            return info
        else:
            with self.channel_metadata_file.open("r") as file:
                info = json.load(file)
                return info

    def _all_video_ids(self):
        """Retuns a list of video ids from the info dict."""

        video_ids = set()
        if self.channel_info["_type"] == "playlist":
            for entry in self.channel_info["entries"]:
                if entry["_type"] == "url":
                    video_ids.add(entry["id"])
                elif entry["_type"] == "playlist":
                    for video in entry["entries"]:
                        video_ids.add(video["id"])
        return video_ids

    def download_channel(self):
        """Download all channel videos. Wrapper around functions for videos and shorts."""

        log.warning("starting channel videos")
        self.download_channel_videos()
        # log.warning("starting channel shorts")
        # self.download_channel_shorts()

    # def download_channel_shorts(self):
    #     """Starts the download process for the whole channel."""
    #     video_url = f"{self.channel_url.rstrip('/')}/shorts"
    #     info = self.ydl.extract_channel_info(video_url)
    #     all_ids = self._extract_video_ids(info)
    #     base_url = "https://www.youtube.com/shorts/"
    #     for id_ in all_ids:
    #         url = base_url + id_
    #         if self._video_already_exists(id_):
    #             log.debug("VideoID %s already exists. Skipping...", id_)
    #             continue
    #         try:
    #             self._download_video(url=url, channel=self.channel, format="shorts")
    #         except DownloadError:
    #             log.warning("Having Download Error")
    #             continue

    def download_channel_videos(self):
        """Starts the download process for the whole channel."""

        base_url = "https://www.youtube.com/watch?v="
        all_ids = self._all_video_ids()

        for index, video_id in enumerate(all_ids, 1):
            log.info("Starting (%d/%d) video: %s", index, len(all_ids), video_id)
            url = base_url + video_id

            if not self._video_metadata_already_exists(video_id=video_id):
                try:
                    self._download_video_metadata(url=url, video_id=video_id)
                except DownloadError:
                    log.error("Download Error during Metadata File: %s", video_id)
                    continue
            else:
                log.warning("Metadata for %s already exists. Skipping.", video_id)

            if not self._video_already_exists(video_id) and not self.was_a_livestream(video_id):
                try:
                    self._download_video(url=url)
                except DownloadError:
                    log.error("Download Error during Video File: %s", video_id)
                    raise
            else:
                log.warning("Video %s already exists or was live. Skipping.", video_id)

    def _download_video_metadata(self, url, video_id):
        info = self.ydl.get_video_info(url)
        with ZipFile(self.meta_file_folder, "a", compression=ZIP_DEFLATED) as archive:
            content = json.dumps(info, ensure_ascii=False, indent=2)
            archive.writestr(f"{video_id}.json", content)

    def was_a_livestream(self, video_id):
        filename = f"{video_id}.json"
        with ZipFile(self.meta_file_folder, "r") as archive:
            _bytes = archive.read(filename)
            content = _bytes.decode("utf-8")
            content = json.loads(content)

        return content["is_live"] | content["was_live"]

    def _download_video(self, url):
        self.ydl.download(url=url)

    def _video_already_exists(self, video_id: str) -> bool:
        stems = {fn.stem for fn in self.video_file_folder.iterdir()}
        if video_id in stems:
            return True
        return False

    def _video_metadata_already_exists(self, video_id: str) -> bool:
        filename = f"{video_id}.json"
        with ZipFile(self.meta_file_folder, "r") as archive:
            if filename in archive.namelist():
                return True
        return False

    def get_uploader_id(self, channel_url):
        """Returns a uploader_id from a channel url."""

        return re.match("/(@(.*?))(/|$)", urlparse(channel_url).path).group(1)


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
            "getcomments": False,
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

    def get_channel_info(self, url: str, channel_only: bool = False) -> dict:
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

    def get_video_info(self, url: str) -> dict:
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
