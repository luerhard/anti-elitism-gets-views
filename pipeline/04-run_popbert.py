from sqlalchemy import create_engine
from sqlalchemy.orm import Session

import src
from src.data.models import Sentence
from src.data.predictors import PopBERTPredictor
from src.logging import logger as log
from src.utils.iterate import chunks

ENGINE = create_engine(src.PS_ENGINE)
CHUNKSIZE = 64


def iter_sentences(session):
    query = session.query(Sentence).execution_options(stream_results=True, max_row_buffer=5000)
    yield from chunks(query, chunksize=CHUNKSIZE)


def main():
    popbert = PopBERTPredictor()
    log.info("PopBERT loaded.")

    session = Session(bind=ENGINE, expire_on_commit=False)
    for chunk_no, sentences in enumerate(iter_sentences(session), 1):
        log.debug("Processing chunk: %d", chunk_no)
        tokens = [sent.tokens for sent in sentences]
        predictions = popbert.predict(tokens, chunksize=CHUNKSIZE)
        for sentence, pred in zip(sentences, predictions, strict=False):
            sentence.elite = pred[0]
            sentence.pplcentr = pred[1]
            sentence.left = pred[2]
            sentence.right = pred[3]

        session.add_all(sentences)
        if not chunk_no % 100:
            session.commit()
    session.commit()
    ENGINE.dispose()


if __name__ == "__main__":
    main()
