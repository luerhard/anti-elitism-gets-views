from sqlalchemy import create_engine
from sqlalchemy.orm import Session

import src
from src.data.models import Base
from src.data.models import Sentence
from src.data.models import Transcript
from src.data.transcript_processor import TranscriptCleaner
from src.logging import logger as log

ENGINE = create_engine(src.PS_ENGINE)
DROP_TABLES = False


def iter_transcripts(session):
    transcripts = session.query(Transcript).execution_options(
        stream_results=True,
        max_row_buffer=5000,
    )
    yield from transcripts


def main():
    if DROP_TABLES:
        log.warn("Dropping tables")
        Base.metadata.drop_all(ENGINE, tables=[Sentence.__table__])
        Base.metadata.create_all(ENGINE, tables=[Sentence.__table__])
        log.info("created all tables.")

    cleaner = TranscriptCleaner()
    log.info("Processor loaded.")

    session = Session(bind=ENGINE, expire_on_commit=False)
    for transcript_no, transcript in enumerate(iter_transcripts(session)):
        log.debug("Processing transcript (%d): %s", transcript_no, transcript.id)
        text = transcript.text
        sentences = cleaner.tokenize(text)
        cache = []
        for sentence_no, sentence in enumerate(sentences, 1):
            if not sentence:
                continue
            row = Sentence(
                video_id=transcript.id,
                sentence_no=sentence_no,
                tokens=sentence,
            )
            cache.append(row)
        if not transcript_no % 500:
            session.add_all(cache)
            cache = []
            session.commit()
    session.add_all(cache)
    session.commit()
    ENGINE.dispose()


if __name__ == "__main__":
    main()
