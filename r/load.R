box::use(
  reticulate,
  forcats[as_factor, fct_drop],
  dplyr[...]
)

channels <- function() {
  data_load <- reticulate::import("src.load")
  loader = data_load$DataLoader()
  df <- loader$channels()$to_pandas()
  return(df)
}

videos <- function(filtered=TRUE) {
  data_load <- reticulate::import("src.load")
  loader = data_load$DataLoader()
  df <- loader$videos(filtered=filtered)$to_pandas()
  return(df)
}

sentences <- function(filtered=TRUE) {
  data_load <- reticulate::import("src.load")
  loader = data_load$DataLoader()
  df <- loader$sentences(filtered=filtered)$to_pandas()
  return(df)
}

popbert <- function(filtered=TRUE) {
  data_load <- reticulate::import("src.load")
  loader = data_load$DataLoader()
  df <- loader$popbert(filtered=filtered)$to_pandas()
  return(df)
}

colormap <- function() {
  src <- reticulate::import("src")
  cmap <- unlist(src$colormap, use.names=T)
  return(cmap)
}

regression_data <- function() {
  channels <- channels()
  videos <- videos(filtered = TRUE)
  sentences <- sentences(filtered = TRUE)
  popbert <- popbert(filtered = TRUE)

  centered <- function(x) (x - mean(x))
  z_transform <- function(x) as.vector(scale(x))

  df_sents <- sentences |>
    left_join(popbert, by = "sentence_id") |>
    group_by(video_id) |>
    summarize(
      n_sents = n(),
      elite = mean(elite),
      pplcentr = mean(pplcentr)
    )

  df <- channels |>
    left_join(videos, by = "channel_id") |>
    left_join(df_sents, by = "video_id") |>
    mutate(
      channel = as_factor(channel)
    )

  df <- df |>
    # filter(video_datetime_upload > "2020-10-01") |>
    mutate(
      released_at = video_datetime_upload |>
        lubridate::floor_date(unit="month") |>
        format("%Y-%m"),
      released_at = released_at |>
        factor(levels=sort(unique(released_at)), ordered=FALSE),
      released_year = video_datetime_upload |>
        lubridate::floor_date(unit="year") |>
        format("%Y"),
      released_year = released_year |>
        factor(levels=sort(unique(released_year)), ordered=FALSE)
    ) |>
    mutate(
      channel = channel |> fct_drop(),
      log_video_likes = log1p(video_likes),
      log_video_views = log(video_views),
      likes_per_view = video_likes / video_views,
      log_video_duration = log(video_duration),
      log_n_sents = log(n_sents),
    ) |>
    arrange(channel, video_datetime_upload) |>
    group_by(channel) |>
    mutate(
      channel_scaled_video_views = scale(video_views),
    ) |>
    ungroup()


  return(df)
}
