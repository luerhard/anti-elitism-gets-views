box::use(
  here[here],
  reticulate
)

reticulate::use_python(here(".venv/bin/python"))

video_dataset <- function() {
  # reticulate::import("src.data.load.video_dataset")
  data_load <- reticulate::import("src.data.load")
  df <- data_load$video_dataset()

  return(df)
}
