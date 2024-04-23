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

    def __init__(self) -> None:

        self.db_path = src.TMP / "test.duckdb"
        self.con = ibis.connect(self.db_path, threads=4, memory_limit="10GB")

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

    def comments(self, filtered: bool = False):
        table = self.con.tables["comments"]
        col_names = {
            "comment_id": "id",
            "comment_text": "text",
            "comment_author": "author",
            "comment_parent": "parent",
            "comment_likes": "like_count",
        }

        table = table.rename(**col_names)

        if filtered:
            valid_videos = self.videos()
            filtered_table = table.join(valid_videos, "video_id")
            table = filtered_table[table]

        return table

    def videos(self, filtered: bool = False, _ignore_sentence_filter: bool = False):
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

        if filtered:
            # filter by time and type
            table = table.filter(
                [
                    _.video_format == "videos",
                    _.video_uploadtime >= self.PERIOD_START,
                    _.video_uploadtime <= self.PERIOD_END,
                ],
            )

            # filter by sentence criteria
            if not _ignore_sentence_filter:
                sents = self.sentences(_ignore_video_filter=True)
                filtered_table = table.join(sents, "video_id")
                table = filtered_table[table]

        return table

    def sentences(self, filtered: bool = False, _ignore_video_filter: bool = False):
        table = self.con.tables["sentences"]

        if filtered:
            # remove sentences from invalid videos (only if not called from videos)
            if not _ignore_video_filter:
                table = table.filter(
                    _.video_id.isin(self.videos(_ignore_sentence_filter=True).video_id),
                )

            # remove sentences with too few tokens
            table = table.filter(_.tokens.length() >= self.MIN_TOKENS_PER_SENT)

            # remove videos with less too few sentences
            counts = (
                table.group_by("video_id").agg(n_sents=_.sentence_id.count()).filter(_.n_sents > 5)
            )
            filtered_table = table.join(counts, "video_id")
            table = filtered_table[table]

        return table

    def popbert(self, filtered: bool = False, binarize_predictions: bool = True):
        table = self.con.tables["popbert"]

        if binarize_predictions:

            def apply_threshold(col, thresh):
                return case().when(col > thresh, 1).else_(0).end()

            table = table.mutate(
                elite=apply_threshold(_.elite, self.POPBERT_THRESH["elite"]),
                pplcentr=apply_threshold(_.pplcentr, self.POPBERT_THRESH["pplcentr"]),
                left=apply_threshold(_.left, self.POPBERT_THRESH["left"]),
                right=apply_threshold(_.right, self.POPBERT_THRESH["right"]),
            )

        if filtered:
            sents = self.sentences()
            filtered_table = table.join(sents, "sentence_id")
            table = filtered_table[table]

        return table
