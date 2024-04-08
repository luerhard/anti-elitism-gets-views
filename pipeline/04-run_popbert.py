import ibis

import src
from src.logging import logger as log
from src.processing.predictors import PopBERTPredictor

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
                "video_id": "string",
                "sentence_no": "int32",
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
        table_sentences.video_id.notin(table_popbert.video_id),
    ).to_pandas()

    i = 0
    for video_id, video_df in sentences_df.groupby("video_id"):
        i += len(video_df)
        log.info("Processing (%d/%d): %s", i, len(sentences_df), video_id)
        cache = []
        tokens = video_df.tokens.to_list()
        sentence_numbers = video_df.sentence_no.to_list()
        predictions = popbert.predict(tokens, chunksize=CHUNKSIZE)
        for sentence_no, prediction in zip(sentence_numbers, predictions, strict=True):
            row = {
                "video_id": video_id,
                "sentence_no": sentence_no,
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
