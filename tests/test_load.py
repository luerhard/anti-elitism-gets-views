import datetime as dt

from src.load import DataLoader


class TestDataLoader:
    @classmethod
    def setup_class(cls):
        cls.dl = DataLoader()

    def test_basic_filter_videos(self):
        non_filtered_videos = self.dl.videos(filtered=False).to_pandas()
        filtered_videos = self.dl.videos(filtered=True).to_pandas()
        assert len(filtered_videos) < len(non_filtered_videos)

    def test_daterange_videos(self):
        min_date = dt.datetime.strptime(self.dl.PERIOD_START, "%Y-%m-%d")
        max_date = dt.datetime.strptime(self.dl.PERIOD_END, "%Y-%m-%d")
        filtered_videos = self.dl.videos().to_pandas()
        assert filtered_videos.video_datetime_upload.min() >= min_date
        assert filtered_videos.video_datetime_upload.max() <= max_date

    def test_short_sentence_removal(self):
        sents = self.dl.sentences()
        sents = sents.select(sents.video_id, sents.tokens).to_pandas()
        assert sents.video_id.value_counts().min() >= 5
        assert all(len(s) >= 5 for s in sents.tokens.to_list())

    def test_uniqueness_index(self):
        sents = self.dl.sentences()
        assert sents.sentence_id.nunique().execute() == sents.count().execute()
        assert sents.filter(sents.sentence_id.isnull()).count().execute() == 0
        videos = self.dl.videos()
        assert videos.video_id.nunique().execute() == videos.count().execute()
        assert videos.filter(videos.video_id.isnull()).count().execute() == 0
        popbert = self.dl.popbert()
        assert popbert.sentence_id.nunique().execute() == popbert.count().execute()
        assert popbert.filter(popbert.sentence_id.isnull()).count().execute() == 0

    def test_each_sent_has_popbert(self):
        popbert = self.dl.popbert(binarize_predictions=False)
        sents = self.dl.sentences()
        assert (
            popbert.sentence_id.nunique().execute()
            == sents.sentence_id.nunique().execute()
        )

    def test_equal_lengths(self):
        videos = self.dl.videos()
        sents = self.dl.sentences()
        assert videos.count().execute() == sents.video_id.nunique().execute()

    def test_popbert(self):
        sents = self.dl.sentences()
        popbert = self.dl.popbert(binarize_predictions=False).semi_join(
            sents, ["sentence_id"]
        )
        assert popbert.count().execute() == sents.count().execute()
        assert popbert.filter(popbert.elite.isnull()).count().execute() == 0
        assert popbert.filter(popbert.pplcentr.isnull()).count().execute() == 0
        assert popbert.filter(popbert.left.isnull()).count().execute() == 0
        assert popbert.filter(popbert.right.isnull()).count().execute() == 0
