import ibis

import src
from src.logging import logger as log
from src.processing.transcript_cleaner import TranscriptCleaner

DB_PATH = src.TMP / "transcript_cleaner.duckdb"
TRANSCRIPT_PATH = src.PATH / "data/interim/audio_transcripts_v3_large.parquet.gzip"
OUT_FILE = src.PATH / "data/interim/sentences.parquet.gzip"


def main():

    con = ibis.connect(DB_PATH)
    if "transcripts" not in con.list_tables():
        table_transcripts = con.read_parquet(TRANSCRIPT_PATH)
    else:
        table_transcripts = con.table("transcripts")

    if "sentences" not in con.list_tables():
        schema = ibis.schema(
            {"video_id": "string", "sentence_no": "int32", "tokens": "array<string>"},
        )
        table_sentences = con.create_table("sentences", schema=schema)
    else:
        table_sentences = con.table("sentences")

    log.info("DB loaded.")
    cleaner = TranscriptCleaner()
    log.info("Processor loaded.")

    transcripts_df = table_transcripts.filter(
        table_transcripts.video_id.notin(table_sentences.video_id),
    ).to_pandas()
    for i, transcript in enumerate(transcripts_df.itertuples(), 1):
        log.info("Processing (%d/%d): %s", i, len(transcripts_df), transcript.video_id)
        sentences = cleaner.tokenize(transcript.text)
        cache = []
        for sentence_no, sentence in enumerate(sentences, 1):
            if not sentence:
                continue
            row = {"video_id": transcript.video_id, "tokens": sentence, "sentence_no": sentence_no}
            cache.append(row)
        con.insert("sentences", cache)

    table_sentences.to_parquet(OUT_FILE, compression="gzip")
    DB_PATH.unlink(missing_ok=False)


if __name__ == "__main__":
    main()
