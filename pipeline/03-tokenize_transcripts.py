import ibis

import src
from src.logging import logger as log
from src.processing.transcript_cleaner import BrokenTranscriptError
from src.processing.transcript_cleaner import TranscriptCleaner

CHUNKSIZE = 100
DB_PATH = src.TMP / "transcript_cleaner.duckdb"
TRANSCRIPT_PATH = src.PATH / "data/interim/transcripts/v3_large_turbo.parquet"
OUT_FILE_SENTS = src.PATH / "data/yt_metadata/sentences.parquet"
OUT_FILE_BROKEN = src.PATH / "data/yt_metadata/broken_transcripts.parquet"


def main():
    con = ibis.connect(f"duckdb://{DB_PATH}", threads=4, memory_limit="10GB")

    if "skipped" not in con.list_tables():
        schema = ibis.schema({"video_id": "string"})
        table_skipped = con.create_table("skipped", schema=schema)
    else:
        table_skipped = con.table("skipped")

    if "transcripts" not in con.list_tables():
        table_transcripts = con.read_parquet(TRANSCRIPT_PATH)
    else:
        table_transcripts = con.table("transcripts")

    if "sentences" not in con.list_tables() and OUT_FILE_SENTS.is_file():
        expr = con.read_parquet(OUT_FILE_SENTS)
        table_sentences = con.create_table("sentences", expr)
    elif "sentences" not in con.list_tables():
        schema = ibis.schema(
            {
                "sentence_id": "int",
                "video_id": "string",
                "sentence_no": "int",
                "tokens": "array<string>",
            },
        )
        table_sentences = con.create_table("sentences", schema=schema)
    else:
        table_sentences = con.table("sentences")

    if "broken_transcripts" not in con.list_tables() and OUT_FILE_BROKEN.is_file():
        expr = con.read_parquet(OUT_FILE_BROKEN)
        table_broken_transcripts = con.create_table("broken_transcripts", expr)
    elif "broken_transcripts" not in con.list_tables():
        schema = ibis.schema({"video_id": "string"})
        table_broken_transcripts = con.create_table("broken_transcripts", schema=schema)
    else:
        table_broken_transcripts = con.table("broken_transcripts")
    log.info("DB loaded.")

    cleaner = TranscriptCleaner()
    log.info("Processor loaded.")

    # data = table_transcripts.filter(
    #     table_transcripts.video_id.notin(table_sentences.video_id),
    # )
    data = (
        table_transcripts.anti_join(table_sentences, ["video_id"])
        .anti_join(
            table_broken_transcripts,
            ["video_id"],
        )
        .anti_join(table_skipped, ["video_id"])
    )
    n_total = data.count().execute()
    done = 0

    sentence_id = table_sentences.sentence_id.max().execute()
    if sentence_id is None:
        sentence_id = 0
    while True:
        transcript_df = data.limit(CHUNKSIZE).to_pandas()
        if transcript_df.empty:
            break

        done += CHUNKSIZE
        log.info("Processing (%d/%d)", done, n_total)
        insert_cache = []
        for transcript in transcript_df.itertuples():
            log.debug("Processing: %s", transcript.video_id)
            # some transcript can be empty and should be skipped
            if not transcript.text:
                log.debug("Skipping empty: %s", transcript.video_id)
                con.insert("skipped", [{"video_id": transcript.video_id}])

            # catch broken transcripts and ignore them. Write their IDs to broken_transcripts.
            try:
                sentences = cleaner.tokenize(transcript.text)
            except BrokenTranscriptError:
                log.error("Transcript with ID: %s broken. Skipping.", transcript.video_id)
                con.insert("broken_transcripts", [{"video_id": transcript.video_id}])
                continue

            cache = []
            for sentence_no, sentence in enumerate(sentences, 1):
                if not sentence:
                    continue
                sentence_id += 1
                row = {
                    "sentence_id": sentence_id,
                    "video_id": transcript.video_id,
                    "tokens": sentence,
                    "sentence_no": sentence_no,
                }
                cache.append(row)
            if cache:
                insert_cache += cache
            else:
                log.debug("Skipping empty sents: %s", transcript.video_id)
                con.insert("skipped", [{"video_id": transcript.video_id}])
        con.insert("sentences", insert_cache)

    table_broken_transcripts.to_parquet(OUT_FILE_BROKEN, compression="gzip")
    table_sentences.to_parquet(OUT_FILE_SENTS, compression="gzip")
    DB_PATH.unlink(missing_ok=False)


if __name__ == "__main__":
    main()
