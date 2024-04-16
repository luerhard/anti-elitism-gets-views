box::use(
  here[here],
  reticulate
)

reticulate::use_python(here(".venv/bin/python"))

channels <- function() {
  data_load <- reticulate::import("src.load")
  df <- data_load$channels()
  return(df)
}

videos <- function() {
  data_load <- reticulate::import("src.load")
  df <- data_load$videos()
  return(df)
}

sentences <- function() {
  data_load <- reticulate::import("src.load")
  df <- data_load$sentences()
  return(df)
}

popbert <- function() {
  data_load <- reticulate::import("src.load")
  df <- data_load$popbert()
  return(df)
}
