"""Transcribe all the videos."""

from sqlalchemy import create_engine
from sqlalchemy.orm import Session

import src
from src.logging import logger as log
from src.asr import WhisperPipeline
from src.data.models import Base
from src.data.models import Transcript
from src.data.models import Video

BASE_VIDEO_PATH = src.PATH / "data/yt/"


def iter_videos(session) -> Video:
    query = session.query(Video).outerjoin(Transcript).filter(Transcript.id == None)
    for video in query:
        yield video


def main():
    engine = create_engine(src.PS_ENGINE)
    Base.metadata.create_all(engine)
    log.info("DB Connection established.")
    pipeline = WhisperPipeline(model_type="large-v3")
    log.info("Pipeline loaded.")
    with Session(engine, expire_on_commit=False) as s:
        for video in iter_videos(s):
            log.debug("Video [%s]: %s", video.id, video.title)
            transcript = Transcript(
                id=video.id,
                model_type=pipeline.model_type,
            )
            text = pipeline.transcribe(BASE_VIDEO_PATH / video.relative_file_path)
            transcript.text = text
            video.transcript = transcript
            s.add(video)
            s.commit()


if __name__ == "__main__":
    main()
