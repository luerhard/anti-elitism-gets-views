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
        self.con = ibis.connect("duckdb://:memory:", threads=4, memory_limit="10GB")
        self.con.read_parquet(src.DATA / "yt_metadata/channels.parquet", "channels")
        self.con.read_parquet(src.DATA / "yt_metadata/videos.parquet", "videos")
        self.con.read_parquet(src.DATA / "interim/sentences.parquet.gzip", "sentences")
        self.con.read_parquet(src.DATA / "interim/popbert.parquet.gzip", "popbert")

    def channels(self):
        table = self.con.tables["channels"]
        table = table.mutate(channel=_.channel.substitute(src.party_names))
        return table

    def videos(self, filtered: bool = False, _ignore_sentence_filter: bool = False):
        table = self.con.tables["videos"]

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
                sents = self.sentences(filtered=True, _ignore_video_filter=True)
                remaining_videos = sents.select("video_id").distinct()
                filtered_table = table.filter(_.video_id.isin(remaining_videos.video_id))
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
            sents = self.sentences(filtered=True)
            filtered_table = table.join(sents, "sentence_id")
            table = filtered_table[table]

        return table
