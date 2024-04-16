import ibis

import src
from src.logging import logger as log
from src.processing.manifesto_predictor import ManifestoPredictor
from src.utils.iterate import flatten_list

CHUNKSIZE = 32
CONTEXT_WINDOW = 2
DB_PATH = src.PATH / "tmp/manifesto_roberta.duckdb"
SENTENCE_PATH = src.PATH / "data/interim/sentences.parquet.gzip"
OUT_FILE = src.PATH / "data/interim/manifesto_roberta.parquet.gzip"


def main():
    con = ibis.connect(DB_PATH)
    if "sentences" not in con.list_tables():
        table_sentences = con.read_parquet(SENTENCE_PATH)
    else:
        table_sentences = con.table("sentences")

    if "manifesto" not in con.list_tables():
        schema = ibis.schema(
            {
                "sentence_id": "int32",
                "label": "string",
                "confidence": "float64",
            },
        )
        table_manifesto = con.create_table("manifesto", schema=schema)
    else:
        table_manifesto = con.table("manifesto")
    log.info("DB loaded.")

    manifesto = ManifestoPredictor()

    sentences_df = table_sentences.filter(
        table_sentences.sentence_id.notin(table_manifesto.sentence_id),
    ).to_pandas()

    log.info("Starting Process.")
    progress_counter = 0
    total_sents = len(sentences_df)
    for video_id, video_df in sentences_df.groupby("video_id"):
        progress_counter += len(video_df)
        log.info("Processing (%d/%d): %s", progress_counter, total_sents, video_id)

        video_df = video_df.sort_values("sentence_no")
        token_sents = video_df.tokens.to_list()
        sentence_ids = video_df.sentence_id.to_list()

        sents = []
        contexts = []
        for i, sent in enumerate(token_sents, 0):
            sents.append(sent)
            if i < CONTEXT_WINDOW:
                ctx = flatten_list(token_sents[:i])
            else:
                ctx = flatten_list(token_sents[i - CONTEXT_WINDOW : i])
            contexts.append(ctx)

        predictions = manifesto.predict(sents, contexts, chunksize=CHUNKSIZE)

        cache = []
        for sent_id, prediction in zip(sentence_ids, predictions, strict=True):
            label, confidence = prediction
            row = {
                "sentence_id": sent_id,
                "label": label,
                "confidence": confidence,
            }
            cache.append(row)
        con.insert("manifesto", cache)

    table_manifesto.to_parquet(OUT_FILE, compression="gzip")
    DB_PATH.unlink(missing_ok=False)


if __name__ == "__main__":
    main()
