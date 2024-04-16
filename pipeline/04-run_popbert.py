import ibis

import src
from src.logging import logger as log
from src.processing.popbert_predictor import PopBERTPredictor

CHUNKSIZE = 64
DB_PATH = src.PATH / "tmp/popbert.duckdb"
SENTENCE_PATH = src.PATH / "data/interim/sentences.parquet.gzip"
OUT_FILE = src.PATH / "data/interim/popbert.parquet.gzip"


def main():
    con = ibis.connect(DB_PATH)
    if "sentences" not in con.list_tables():
        table_sentences = con.read_parquet(SENTENCE_PATH)
    else:
        table_sentences = con.table("sentences")

    if "popbert" not in con.list_tables():
        schema = ibis.schema(
            {
                "sentence_id": "int32",
                "elite": "float64",
                "pplcentr": "float64",
                "left": "float64",
                "right": "float64",
            },
        )
        table_popbert = con.create_table("popbert", schema=schema)
    else:
        table_popbert = con.table("popbert")
    log.info("DB loaded.")

    popbert = PopBERTPredictor()
    log.info("PopBERT loaded.")

    sentences_df = table_sentences.filter(
        table_sentences.sentence_id.notin(table_popbert.sentence_id),
    ).to_pandas()

    i = 0
    total_sents = len(sentences_df)
    for video_id, video_df in sentences_df.groupby("video_id"):
        i += len(video_df)
        log.info("Processing (%d/%d): %s", i, total_sents, video_id)
        cache = []
        tokens = video_df.tokens.to_list()
        sentence_ids = video_df.sentence_id.to_list()
        predictions = popbert.predict(tokens, chunksize=CHUNKSIZE)
        for sent_id, prediction in zip(sentence_ids, predictions, strict=True):
            row = {
                "sentence_id": sent_id,
                "elite": prediction[0],
                "pplcentr": prediction[1],
                "left": prediction[2],
                "right": prediction[3],
            }
            cache.append(row)
        con.insert("popbert", cache)

    table_popbert.to_parquet(OUT_FILE, compression="gzip")
    DB_PATH.unlink(missing_ok=False)


if __name__ == "__main__":
    main()
