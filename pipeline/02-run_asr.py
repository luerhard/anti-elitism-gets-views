"""Transcribe all the videos."""

import ibis

import src
from src.logging import logger as log
from src.processing.whisper_pipeline import WhisperPipeline

BASE_VIDEO_PATH = src.PATH / "data/raw/yt/"
DB_PATH = src.PATH / "data/interim/transcripts/v3_large_turbo.duckdb"
OUT_FILE = src.PATH / "data/interim/transcripts/v3_large_turbo.parquet"


def main():
    con = ibis.connect(f"duckdb://{DB_PATH}")
    if "videos" not in con.list_tables():
        videos = con.read_parquet(src.PATH / "data/yt_metadata/videos.parquet")
    else:
        videos = con.table("videos")

    if "transcripts" not in con.list_tables():
        schema = ibis.schema({"video_id": "string", "text": "string"})
        transcripts = con.create_table(name="transcripts", schema=schema)
    else:
        transcripts = con.table("transcripts")
    log.warning("DB Connection established.")
    # pipeline = WhisperPipeline(model_type="large-v3")
    pipeline = WhisperPipeline(model_type="large-v3")
    log.warning("Pipeline loaded.")

    video_df = videos.filter(
        [
            videos.datetime_upload >= "2017-12-06",
            videos.datetime_upload <= "2025-02-01",
            videos.id.notin(transcripts.video_id),
        ],
    ).to_pandas()
    log.warning("%d videos left to transcribe", len(video_df))
    for i, video in enumerate(video_df.itertuples(), 1):
        log.info("Processing (%d/%d): %s", i, len(video_df), video.id)
        text = pipeline.transcribe(BASE_VIDEO_PATH / video.relative_file_path)
        transcript = {"video_id": video.id, "text": text}
        con.insert("transcripts", transcript)

    transcripts.to_parquet(OUT_FILE, compression="gzip")


if __name__ == "__main__":
    main()
