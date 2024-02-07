from sqlalchemy import create_engine
from sqlalchemy.orm import Session

import src
from src.data.models import Sentence
from src.data.predictors import ManifestorPredictor
from src.logging import logger as log
from src.utils.iterate import chunks

ENGINE = create_engine(src.PS_ENGINE)
CHUNKSIZE = 64

def iter_sentences(session):
    query = session.query(Sentence).execution_options(stream_results=True, max_row_buffer=500)
    yield from chunks(query, chunksize=CHUNKSIZE)


def main():
    manifesto = ManifestorPredictor()

    session = Session(bind=ENGINE, expire_on_commit=False)
    for chunk_no, sentences in enumerate(iter_sentences(session), 1):
        log.debug("Processing chunk: %d", chunk_no)
        tokens = [sent.tokens for sent in sentences]
        predictions = manifesto.predict(tokens, chunksize=CHUNKSIZE)
        for sentence, pred in zip(sentences, predictions, strict=True):
            label, confidence = pred
            sentence.manifesto_class = label
            sentence.manifesto_confidence = confidence

        session.add_all(sentences)
        if not chunk_no % 100:
            session.commit()
    session.commit()
    ENGINE.dispose()


if __name__ == "__main__":
    main()
