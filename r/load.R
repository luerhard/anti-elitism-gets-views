box::use(
  reticulate,
  forcats[as_factor, fct_drop],
  dplyr[...],
  stats[setNames],
  future[plan, multisession, sequential],
  furrr[future_map_dfr],
  tibble[rownames_to_column]
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
    readRDS(model_file)
}

create_model_summary <- function(model, var) {
    model_summary <- summary(model)

    df <- model_summary$fixed |>
        rownames_to_column("term") |>
        filter(term == !!var) |>
        rename(est = Estimate, upper_ci = `u-95% CI`, lower_ci = `l-95% CI`, rhat = Rhat) |>
        select(lower_ci, est, upper_ci, rhat)
}

regression_results <- function(model_file, var) {
  model <- read_model(model_file)
  df <- create_model_summary(model, var)
  df$var <- var
}


read_quantile_regs_from_folder <- function(folder_path, var) {
  files_in_folder <- list.files(folder_path, include.dirs=F, full.names=T, pattern = "*\\.rds", ignore.case=T)
  future::plan(future::multisession, workers = 4)

  results <- furrr::future_map_dfr(
    files_in_folder,
    ~{
      tryCatch({
        cat("Processing file:", basename(.x), "\r")  # Debug outputs
        result <- regression_results(.x, var)
        if (nrow(result) == 0) {
          warning("No results for variable '", var, "' in file: ", basename(.x))
        }
        return(result)
      }, error = function(e) {
        warning(paste("Error processing file:", e$message))
        return(data.frame())
      })
    }
  )


  future::plan(future::sequential)

  return(results)

}

read_party <- function(base_path, party, var) {

}
