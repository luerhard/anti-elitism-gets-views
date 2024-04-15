"""Loads datasets in different formats."""

import pandas as pd
from sqlalchemy import Integer
from sqlalchemy import create_engine
from sqlalchemy import func
from sqlalchemy.orm import Query

import src
from src.data.models import Channel
from src.data.models import Sentence
from src.data.models import Video

def video_dataset():
    """Load all videos with predictions and metadata."""
    engine = create_engine(src.PS_ENGINE)
    sentence_query = (
        Query(Sentence)
        .filter(Sentence.is_valid == True)
        .group_by(Sentence.video_id)
        .with_entities(
            Sentence.video_id,
            func.avg(Sentence.elite.cast(Integer)).label("elite"),
            func.avg(Sentence.pplcentr.cast(Integer)).label("pplcentr"),
        )
        .subquery()
    )

    query = (
        Query(Channel)
        .join(Video)
        .filter(
            Video.format == "videos",
            Video.is_valid == True,
        )
        .group_by(Channel.channel, Video.id)
        .join(sentence_query, Video.id == sentence_query.c.video_id)
        .with_entities(
            Channel.channel,
            Video.datetime_upload,
            Video.like_count,
            Video.view_count,
            Video.comment_count,
            Video.duration,
            func.avg(sentence_query.c.elite).label("elite"),
            func.avg(sentence_query.c.pplcentr).label("pplcentr"),
        )
    )

    with engine.connect() as conn:
        df = pd.read_sql(query.statement, conn)

    df.channel = df.channel.replace(src.party_names)
    df.channel = df.channel.astype("category")
    df.datetime_upload = pd.to_datetime(df.datetime_upload)
    df["populism"] = df.elite * df.pplcentr
    df["year"] = df.datetime_upload.dt.year
    df["like_ratio"] = df.like_count / df.view_count
    return df
