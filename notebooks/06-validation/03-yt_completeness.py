import marimo

__generated_with = "0.18.0"
app = marimo.App(width="full", auto_download=["html"])


@app.cell
def _():
    from datetime import datetime
    from datetime import timezone
    from pprint import pprint

    from googleapiclient.discovery import build
    from ibis import _
    import pandas as pd

    import src
    from src.load import DataLoader

    dl = DataLoader()
    return build, datetime, dl, pd, pprint, src


@app.cell
def _(dl):
    videos = (
        dl.channels()
        .join(dl.videos(filtered=False), "channel_id")
        .filter(_.video_datetime_upload >= dl.PERIOD_START, _.video_datetime_upload <= dl.PERIOD_END)
        .to_pandas()
    )
    return (videos,)


@app.cell
def _(videos):
    counts = videos.groupby(["channel", "channel_uploader_id", "channel_id"]).size().reset_index(name="count")
    counts
    return (counts,)


@app.cell
def _(build, datetime, pprint, src):
    api_key = src.config.get("youtube", "api_key")
    youtube = build("youtube", "v3", developerKey=api_key)


    def get_uploads_playlist_id(channel_id):
        res = youtube.channels().list(part="contentDetails", id=channel_id).execute()
        try:
            return res["items"][0]["contentDetails"]["relatedPlaylists"]["uploads"]
        except (IndexError, KeyError):
            print(f"Could not get uploads playlist for channel {channel_id}")
            pprint(res)
            raise


    def list_uploads_in_range(channel_id, start, end):
        uploads_id = get_uploads_playlist_id(channel_id)

        videos = []
        page_token = None
        while True:
            res = (
                youtube.playlistItems()
                .list(
                    part="snippet,contentDetails",
                    playlistId=uploads_id,
                    maxResults=50,
                    pageToken=page_token,
                )
                .execute()
            )

            for it in res.get("items", []):
                published_at = datetime.fromisoformat(it["snippet"]["publishedAt"].replace("Z", "+00:00"))
                if start <= published_at < end:
                    videos.append(it["contentDetails"]["videoId"])

            page_token = res.get("nextPageToken")
            if not page_token:
                break

        return videos
    return (list_uploads_in_range,)


@app.cell
def _(datetime, dl):
    start_date = f"{dl.PERIOD_START}T00:00:00Z"
    end_date = f"{dl.PERIOD_END}T23:59:59Z"
    start_date = datetime.fromisoformat(f"{dl.PERIOD_START}T00:00:00+00:00")
    end_date = datetime.fromisoformat(f"{dl.PERIOD_END}T23:59:59+00:00")
    print(start_date)
    print(end_date)
    return end_date, start_date


@app.cell
def _(counts, end_date, list_uploads_in_range, start_date):
    rows = []
    for row in list(counts.sort_values("count", ascending=True).itertuples()):
        if row.channel == "Left BT old":
            continue
        print(f"Processing channel {row.channel} ({row.channel_id}) with {row.count} videos")
        video_ids = list_uploads_in_range(row.channel_id, start_date, end_date)
        for video_id in video_ids:
            rows.append({"channel_id": row.channel_id, "video_id": video_id})

    return (rows,)


@app.cell
def _(pd, rows):
    df_api = pd.DataFrame(rows).groupby("channel_id").size().reset_index(name="count_api")
    return (df_api,)


@app.cell
def _(counts, df_api):
    counts.merge(df_api, on="channel_id", how="left").fillna(0)
    return


@app.cell
def _():
    return


if __name__ == "__main__":
    app.run()
