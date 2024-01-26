"""Transcribe all the videos."""

from sqlalchemy import create_engine
from sqlalchemy.orm import Session

import src
from src.asr import WhisperPipeline
from src.data.models import Base
from src.data.models import Transcript
from src.data.models import Video

BASE_VIDEO_PATH = src.PATH / "data/yt/"


def iter_videos(session) -> Video:
    query = session.query(Video).limit(2)
    yield from query


def main():
    engine = create_engine(src.PS_ENGINE)
    Base.metadata.create_all(engine)

    pipeline = WhisperPipeline(model_type="tiny")
    with Session(engine) as s:
        for video in iter_videos(s):
            transcript = Transcript(
                id=video.id,
            )
            text = pipeline.transcribe(src.PATH / video.relative_file_path)
            print(text)
            transcript.text = text
            video.transcript = transcript
            s.add(video)
    s.rollback()


if __name__ == "__main__":
    main()
