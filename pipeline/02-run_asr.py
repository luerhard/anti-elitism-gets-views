"""Transcribe all the videos."""

import ibis

import src
from src.logging import logger as log
from src.processing.whisper_pipeline import WhisperPipeline

BASE_VIDEO_PATH = src.PATH / "data/raw/yt/"
DB_PATH = src.PATH / "tmp/v3_large_turbo.duckdb"
OUT_FILE = src.PATH / "data/interim/transcripts/v3_large_turbo.parquet"


def main():
    con = ibis.connect(f"duckdb://{DB_PATH}", memory_limit="5GB")
    if "videos" not in con.list_tables():
        videos = con.read_parquet(src.PATH / "data/yt_metadata/videos.parquet")
    else:
        videos = con.table("videos")

    if "transcripts" not in con.list_tables() and OUT_FILE.is_file():
        expr = con.read_parquet(OUT_FILE)
        transcripts = con.create_table("transcripts", expr)
    elif "transcripts" not in con.list_tables():
        schema = ibis.schema({"video_id": "string", "text": "string"})
        transcripts = con.create_table(name="transcripts", schema=schema)
    else:
        transcripts = con.table("transcripts")
    log.warning("DB Connection established.")
    pipeline = WhisperPipeline(model_type="large-v3-turbo")
    log.warning("Pipeline loaded.")

    data = videos.filter(
        [
            videos.video_was_live == False,
            videos.video_datetime_upload >= "2017-12-06",
            videos.video_datetime_upload <= "2025-02-05",
        ],
    ).anti_join(transcripts, ["video_id"])
    n_total = data.count().execute()
    done = 0
    log.info("Start Processing")
    while True:
        video_df = data.limit(1).to_pandas()
        if video_df.empty:
            break
        video = video_df.iloc[0]

        done += 1
        log.info("Processing (%d/%d): %s", done, n_total, video.video_id)
        file_path = BASE_VIDEO_PATH / video.channel / "videos" / f"{video.video_id}.m4a"
        text = pipeline.transcribe(file_path)
        transcript = {"video_id": video.video_id, "text": text}
        con.insert("transcripts", [transcript])

    transcripts.to_parquet(OUT_FILE, compression="gzip")
    DB_PATH.unlink(missing_ok=False)


if __name__ == "__main__":
    main()
