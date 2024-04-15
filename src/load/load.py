
import pandas as pd

import src

PERIOD_START = "2017-12-06"
PERIOD_END = "2024-01-20"
MIN_TOKENS_PER_SENT = 5
MIN_SENTS_PER_VIDEO = 5

POPBERT_THRESHOLDS = {
    "elite": 0.415961,
    "pplcentr": 0.295400,
    "left": 0.429109,
    "right": 0.302714,
}


def videos(filter_period: bool = True, filter_format: bool = True, filter_sentences: bool = True):
    df = pd.read_parquet(src.DATA / "raw/yt_metadata/videos.parquet.gzip")
    if filter_period:
        df = df.loc[(df.datetime_upload >= PERIOD_START) & (df.datetime_upload <= PERIOD_END)]
    if filter_format:
        df = df.loc[df.format == "videos", :]
    if filter_sentences:
        sent_df = sentences(filter_short=True, filter_n_sents=True, filter_video=False)
        unique_video_ids = sent_df.video_id.unique()
        df = df.loc[df["id"].isin(unique_video_ids)]
    return df


def sentences(filter_short: bool = True, filter_n_sents: bool = True, filter_video: bool = True):
    df = pd.read_parquet(src.DATA / "interim/sentences.parquet.gzip")
    if filter_short:
        df = df.loc[df.tokens.str.len() >= MIN_TOKENS_PER_SENT]
    if filter_n_sents:
        df = df.groupby("video_id").filter(lambda x: len(x) >= MIN_SENTS_PER_VIDEO)
    if filter_video:
        video_df = videos(filter_period=True, filter_format=True, filter_sentences=False)
        unique_video_ids = video_df.id.unique()
        df = df.loc[df.video_id.isin(unique_video_ids)]

    return df


def popbert(binarize_predictions: bool = True):
    df = pd.read_parquet(src.DATA / "interim/popbert.parquet.gzip")
    if binarize_predictions:
        for col in ["elite", "pplcentr", "left", "right"]:
            df[col] = df[col].apply(lambda x, col=col: 1 if x > POPBERT_THRESHOLDS[col] else 0)
    return df


def manifesto_roberta():
    df = pd.read_parquet(src.DATA / "interim/manifesto_roberta.parquet.gzip")
    return df
