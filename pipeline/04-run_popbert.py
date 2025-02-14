import gc

import ibis
import numpy as np
import pandas as pd
import torch

import src
from src.logging import logger as log
from src.processing.popbert_predictor import PopBERTPredictor

CHUNKSIZE = 64
LOG_EVERY = 50
DB_PATH = src.PATH / "tmp/popbert.duckdb"
SENTENCE_PATH = src.PATH / "data/yt_metadata/sentences.parquet"
OUT_FILE = src.PATH / "data/yt_metadata/popbert.parquet"


def main():
    con = ibis.connect(DB_PATH)
    if "sentences" not in con.list_tables():
        table_sentences = con.read_parquet(SENTENCE_PATH)
    else:
        table_sentences = con.table("sentences")

    if "popbert" not in con.list_tables() and OUT_FILE.is_file():
        expr = con.read_parquet(OUT_FILE)
        table_popbert = con.create_table("popbert", expr)
    elif "popbert" not in con.list_tables():
        schema = ibis.schema(
            {
                "sentence_id": "int",
                "elite": "float",
                "pplcentr": "float",
                "left": "float",
                "right": "float",
            },
        )
        table_popbert = con.create_table("popbert", schema=schema)
    else:
        table_popbert = con.table("popbert")
    log.info("DB loaded.")

    popbert = PopBERTPredictor()
    log.info("PopBERT loaded.")

    data = table_sentences.anti_join(table_popbert, ["sentence_id"]).select(
        table_sentences.sentence_id,
        table_sentences.tokens,
    )

    done = 0
    n_total = data.count().execute()
    while True:
        subset = data.limit(CHUNKSIZE * 50).to_pandas()
        if subset.empty:
            break

        for chunk in np.array_split(subset, 50):
            text = chunk.tokens.to_list()
            predictions = popbert.predict(text, chunksize=CHUNKSIZE)
            predictions = pd.DataFrame(
                predictions,
                columns=["elite", "pplcentr", "left", "right"],
            )

            chunk_result = pd.concat(
                [chunk[["sentence_id"]].reset_index(drop=True), predictions],
                axis=1,
            )
            con.insert("popbert", chunk_result)

            done += len(chunk)
            if not (done % LOG_EVERY):
                free, total = torch.cuda.mem_get_info()
                log.info(
                    "%.2f%% (%d/%d) done. VRAM used: %.2f%%",
                    (done / n_total) * 100,
                    done,
                    n_total,
                    ((total - free) / total) * 100,
                )
                gc.collect()
                torch.cuda.empty_cache()

    log.info("%d sentences processed. Exporting file.", done)
    table_popbert.to_parquet(OUT_FILE, compression="gzip")
    DB_PATH.unlink(missing_ok=False)


if __name__ == "__main__":
    main()
