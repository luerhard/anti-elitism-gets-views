from sqlalchemy import create_engine
from sqlalchemy.orm import Session

import src
from src.data.models import Base
from src.data.models import Sentence
from src.data.models import Transcript
from src.data.transcript_processor import TranscriptCleaner
from src.logging import logger as log

ENGINE = create_engine(src.PS_ENGINE)


def iter_transcripts(ENGINE):
    with Session(ENGINE) as session:
        query = session.query(Transcript).yield_per(50)
        for transcript in query:
            yield transcript


def main():
    Base.metadata.drop_all(ENGINE, tables=[Sentence.__table__])
    Base.metadata.create_all(ENGINE, tables=[Sentence.__table__])
    log.info("created all tables.")

    cleaner = TranscriptCleaner()
    log.info("Processor loaded.")

    session = Session(bind=ENGINE, expire_on_commit=False)
    for transcript_no, transcript in enumerate(iter_transcripts(ENGINE)):
        log.debug("Processing transcript (%d): %s", transcript_no, transcript.id)
        text = transcript.text
        sentences = cleaner.tokenize(text)
        for sentence_no, sentence in enumerate(sentences, 1):
            if not sentence:
                continue
            row = Sentence(
                video_id=transcript.id,
                sentence_no=sentence_no,
                tokens=sentence,
            )
            session.add(row)
        if not transcript_no % 100:
            session.commit()
    # session.commit()
    ENGINE.dispose()


if __name__ == "__main__":
    main()
