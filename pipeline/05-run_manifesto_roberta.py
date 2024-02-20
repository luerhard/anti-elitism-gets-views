from sqlalchemy import create_engine
from sqlalchemy.orm import Session
from sqlalchemy.orm import subqueryload

import src
from src.data.models import Video
from src.data.predictors import ManifestorPredictor
from src.logging import logger as log
from src.utils.iterate import flatten_list

CHUNKSIZE = 4
CONTEXT_WINDOW = 2

ENGINE = create_engine(src.PS_ENGINE)


def iter_sentences(session):
    videos = (
        session.query(Video)
        .options(subqueryload(Video.sentences))
        .execution_options(stream_results=True, max_row_buffer=500)
        .limit(2)
    )
    yield from videos


def main():
    manifesto = ManifestorPredictor()

    session = Session(bind=ENGINE, expire_on_commit=False)
    for chunk_no, video in enumerate(iter_sentences(session), 1):
        log.debug("Processing chunk: %d", chunk_no)
        sentences = sorted(video.sentences, key=lambda x: x.sentence_no)
        token_sents = [sent.tokens for sent in sentences]

        sents = []
        contexts = []
        for i, sent in enumerate(sentences, 0):
            sents.append(sent.tokens)
            if i < CONTEXT_WINDOW:
                ctx = flatten_list(token_sents[:i])
            else:
                ctx = flatten_list(token_sents[i - CONTEXT_WINDOW : i])
            contexts.append(ctx)

        predictions = manifesto.predict(sents, contexts, chunksize=CHUNKSIZE)
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
