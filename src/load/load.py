import ibis
from ibis import _
from ibis.expr.api import case
import ibis.selectors as s

import src


class DataLoader:
    POPBERT_THRESH = {
        "elite": 0.415961,
        "pplcentr": 0.295400,
        "left": 0.429109,
        "right": 0.302714,
    }

    PERIOD_START = "2017-12-06"
    PERIOD_END = "2025-02-24"
    MIN_TOKENS_PER_SENT = 3
    MIN_SENTS_PER_VIDEO = 5

    def __init__(self) -> None:
        ytdata = src.DATA / "yt_metadata"
        self.con = ibis.duckdb.connect(threads=6, memory_limit="10GB")
        self.con.read_parquet(ytdata / "channels.parquet", "channels")
        self.con.read_parquet(ytdata / "videos.parquet", "videos")
        self.con.read_parquet(ytdata / "broken_transcripts.parquet", "broken_transcripts")
        self.con.read_parquet(ytdata / "sentences.parquet", "sentences")
        self.con.read_parquet(ytdata / "popbert.parquet", "popbert")

    def channels(self):
        table = self.con.table("channels").select(~s.cols("channel_url"))
        table = table.mutate(channel=_.channel.substitute(src.party_names))
        return table

    def videos(
        self,
        filtered: bool = True,
        text_fields: bool = False,
        _ignore_sentence_filter: bool = False,
        _ignore_broken_transcripts_filter: bool = False,
    ):
        table = self.con.table("videos").select(~s.cols("video_comments", "channel"))

        if filtered:
            # filter by time and type
            table = table.filter(
                [
                    _.video_datetime_upload >= self.PERIOD_START,
                    _.video_datetime_upload <= self.PERIOD_END,
                    _.video_was_live == False,
                ],
            )
            if not _ignore_broken_transcripts_filter:
                table = table.anti_join(self.broken_transcripts(filtered=False), ["video_id"])

            if not _ignore_sentence_filter:
                # necessary to avoid possible infinite recursion
                sents = self.sentences(_ignore_video_filter=True)
                table = table.semi_join(sents, "video_id")

        if not text_fields:
            table = table.select(~s.cols("video_description"))

        return table

    def broken_transcripts(self, filtered: True):
        broken_table = self.con.table("broken_transcripts")
        if filtered:
            videos = self.videos(
                filtered=True,
                _ignore_broken_transcripts_filter=True,
                _ignore_sentence_filter=True,
            )
            broken_table = broken_table.semi_join(videos, "video_id")

        return broken_table

    def sentences(
        self,
        filtered: bool = True,
        text_fields: bool = False,
        _ignore_video_filter: bool = False,
    ):
        table = self.con.table("sentences")

        if filtered:
            # remove sentences from invalid videos (only if not called from videos)
            if not _ignore_video_filter:
                # necessary to avoid possible infinite recursion
                videos = self.videos(_ignore_sentence_filter=True)
                table = table.semi_join(videos, "video_id")

            # remove sentences with too few tokens
            table = table.filter(_.tokens.length() >= self.MIN_TOKENS_PER_SENT)

            # remove videos with less too few sentences
            counts = (
                table.group_by("video_id")
                .agg(n_sents=_.sentence_id.count())
                .filter(_.n_sents >= self.MIN_SENTS_PER_VIDEO)
            )
            table = table.semi_join(counts, "video_id")

        if not text_fields:
            table = table.select(~s.cols("tokens"))

        return table

    def popbert(self, filtered: bool = True, binarize_predictions: bool = True):
        table = self.con.table("popbert")

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
            sents = self.sentences(filtered=True)
            table = table.semi_join(sents, "sentence_id")

        return table
