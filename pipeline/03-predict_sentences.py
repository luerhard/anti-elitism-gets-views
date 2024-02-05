from sqlalchemy import create_engine
from sqlalchemy.orm import Session
from sqlalchemy.orm import close_all_sessions
import src
from src.data.models import Base
from src.data.models import Sentence
from src.data.models import Transcript
from src.logging import logger as log
from src.data.transcript_processor import TranscriptProcessor


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

    processor = TranscriptProcessor()
    log.info("Processor loaded.")

    elite_thresh = float(src.config["THRESHOLD"]["elite"])
    pplcentr_thresh = float(src.config["THRESHOLD"]["pplcentr"])
    left_thresh = float(src.config["THRESHOLD"]["left"])
    right_thresh = float(src.config["THRESHOLD"]["right"])

    session = Session(bind=ENGINE, expire_on_commit=False)
    for transcript_no, transcript in enumerate(iter_transcripts(ENGINE)):
        log.debug("Processing transcript: %s", transcript.id)
        text = transcript.text
        sentences = processor.tokenize(text)
        for sentence_no, sentence in enumerate(sentences, 1):
            if not sentence:
                continue
            predictions = processor.predict_populism(sentence)
            elite = 1 if predictions[0] > elite_thresh else 0
            pplcentr = 1 if predictions[1] > pplcentr_thresh else 0
            left = 1 if predictions[2] > left_thresh else 0
            right = 1 if predictions[3] > right_thresh else 0
            row = Sentence(
                video_id=transcript.id,
                sentence_no=sentence_no,
                elite=elite,
                pplcentr=pplcentr,
                left=left,
                right=right,
                tokens=sentence,
            )
            session.add(row)
        if not transcript_no % 100:
            session.commit()
    # session.commit()
    ENGINE.dispose()


if __name__ == "__main__":
    main()
