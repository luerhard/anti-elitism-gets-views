box::use(
  reticulate,
  forcats[as_factor, fct_drop],
  dplyr[left_join, group_by, summarize, mutate, arrange, ungroup, rename, select, filter, bind_rows, n],
  stats[setNames],
  future[plan, multisession, sequential],
  furrr[future_map_dfr],
  tibble[rownames_to_column],
  here[here]
)

channels <- function() {
  data_load <- reticulate::import("src.load")
  loader <- data_load$DataLoader()
  df <- loader$channels()$to_pandas()
  return(df)
}

videos <- function(filtered = TRUE) {
  data_load <- reticulate::import("src.load")
  loader <- data_load$DataLoader()
  df <- loader$videos(filtered = filtered)$to_pandas()
  return(df)
}

sentences <- function(filtered = TRUE) {
  data_load <- reticulate::import("src.load")
  loader <- data_load$DataLoader()
  df <- loader$sentences(filtered = filtered)$to_pandas()
  return(df)
}

popbert <- function(filtered = TRUE) {
  data_load <- reticulate::import("src.load")
  loader <- data_load$DataLoader()
  df <- loader$popbert(filtered = filtered)$to_pandas()
  return(df)
}

colormap <- function() {
  src <- reticulate::import("src")
  cmap_df <- src$r_colormap_party
  cmap_vec <- setNames(as.character(cmap_df$color), cmap_df$party)
  return(cmap_vec)
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
        lubridate::floor_date(unit = "month") |>
        format("%Y-%m"),
      released_at = released_at |>
        factor(levels = sort(unique(released_at)), ordered = FALSE),
      released_year = video_datetime_upload |>
        lubridate::floor_date(unit = "year") |>
        format("%Y"),
      released_year = released_year |>
        factor(levels = sort(unique(released_year)), ordered = FALSE),
      is_short = factor(video_is_short, levels = c(FALSE, TRUE))
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

read_model <- function(model_file) {
    if (!file.exists(model_file)) stop("File does not exist: ", model_file)
    model <- readRDS(model_file)
    return(model)
}

create_model_summary <- function(model) {
  model_summary <- summary(model)

  df <- model_summary$fixed |>
      rownames_to_column("term") |>
      rename(est = Estimate, upper_ci = `u-95% CI`, lower_ci = `l-95% CI`, rhat = Rhat) |>
      select(term, lower_ci, est, upper_ci, rhat) |>
      mutate(quantile = model$formula$pfix$quantile)

  return(df)
}

read_quantile_models_from_folder <- function(folder_path) {

  files_in_folder <- list.files(folder_path, include.dirs=F, full.names=T, pattern = "*\\.rds", ignore.case=T)

  future::plan(future::multicore, workers = 4L)

  suppressMessages(
    results <- furrr::future_map(
      files_in_folder,
      ~{
        tryCatch({
          model <- read_model(.x)
          summary <- create_model_summary(model)
          return(summary)
        }, error = function(e) {
          warning(paste("Error processing file:", e$message))
          return(data.frame())
        })
      }
    )
  )

  future::plan(future::sequential)
  gc(verbose = F)

  return(results)
}

read_party_results <- function(base_path, party) {

  summaries <- read_quantile_models_from_folder(here(base_path, party))
  df <- dplyr::bind_rows(summaries)
  df$party <- party

  return(df)

}

# regression_results <- function(model_file) {
#   model <- read_model(model_file)
#   df <- create_model_summary(model)
#   if (nrow(df) == 0) {
#     stop("DF len is zero for:", model_file)
#   }
#   return(df)
# }
