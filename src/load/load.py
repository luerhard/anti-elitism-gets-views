import ibis
from ibis import _
from ibis.expr.api import case

import src

class DataLoader:
    POPBERT_THRESH = {
        "elite": 0.415961,
        "pplcentr": 0.295400,
        "left": 0.429109,
        "right": 0.302714,
    }

    PERIOD_START = "2017-12-06"
    PERIOD_END = "2024-01-20"
    MIN_TOKENS_PER_SENT = 5
    MIN_SENTS_PER_VIDEO = 5

    def __init__(self, filtered: bool = True) -> None:
        self.filtered = filtered

        self.db_path = src.TMP / "ytpop.duckdb"
        if self.db_path.is_file():
            self.db_path.unlink()

        self.con = ibis.connect(self.db_path, threads=4, memory_limit="6GB")

        self.con.read_parquet(src.DATA / "raw/yt_metadata/channels.parquet.gzip", "channels")
        self.con.read_parquet(src.DATA / "raw/yt_metadata/videos.parquet.gzip", "videos")
        self.con.read_parquet(src.DATA / "raw/yt_metadata/comments.parquet.gzip", "comments")
        self.con.read_parquet(src.DATA / "interim/sentences.parquet.gzip", "sentences")
        self.con.read_parquet(src.DATA / "interim/popbert.parquet.gzip", "popbert")
        self.con.read_parquet(src.DATA / "interim/manifesto_roberta.parquet.gzip", "manifesto")

    def channels(self):
        table = self.con.tables["channels"]
        col_names = {
            "channel_id": "id",
            "channel_title": "title",
            "channel_description": "description",
            "channel_uploader_id": "uploader_id",
            "channel_playlists": "playlist_count",
            "channel_followers": "channel_follower_count",
        }

        table = table.rename(**col_names).mutate(channel=_.channel.substitute(src.party_names))
        return table

    def comments(self):
        table = self.con.tables["comments"]
        col_names = {
            "comment_id": "id",
            "comment_text": "text",
            "comment_author": "author",
            "comment_parent": "parent",
            "comment_likes": "like_count",
        }

        table = table.rename(**col_names)
        return table

    def videos(self):
        table = self.con.tables["videos"]
        col_names = {
            "video_id": "id",
            "video_title": "title",
            "video_description": "description",
            "video_duration": "duration",
            "video_likes": "like_count",
            "video_views": "view_count",
            "video_uploadtime": "datetime_upload",
            "video_format": "format",
            "video_comments": "comment_count",
            "video_live": "was_live",
            "video_file": "relative_file_path",
        }

        table = table.rename(**col_names)

        if self.filtered:
            table = table.filter(
                [
                    _.video_format == "videos",
                    _.video_uploadtime >= self.PERIOD_START,
                    _.video_uploadtime <= self.PERIOD_END,
                ],
            )
        return table

    def sentences(self):
        table = self.con.tables["sentences"]

        if self.filtered:
            valid_videos = (
                self.videos()
                .join(table, "video_id")
                .group_by("video_id")
                .agg(n_sentences=_.sentence_id.count())
                .filter(_.n_sentences > self.MIN_SENTS_PER_VIDEO)
            )
            table = table.filter(
                [
                    _.video_id.isin(valid_videos.video_id),
                    _.tokens.length() >= self.MIN_SENTS_PER_VIDEO,
                ],
            )
        return table

    def popbert(self, binarize_predictions: bool = True):
        table = self.con.tables["popbert"]
        if binarize_predictions:
            table = table.mutate(
                elite=case().when(_.elite > self.POPBERT_THRESH["elite"], 1).else_(0).end(),
                pplcentr=case()
                .when(_.pplcentr > self.POPBERT_THRESH["pplcentr"], 1)
                .else_(0)
                .end(),
                left=case().when(_.left > self.POPBERT_THRESH["left"], 1).else_(0).end(),
                right=case().when(_.right > self.POPBERT_THRESH["right"], 1).else_(0).end(),
            )
        return table
