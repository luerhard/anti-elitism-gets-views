box::use(
  here[here],
  reticulate
)

reticulate::use_python(here(".venv/bin/python"))

channels <- function() {
  data_load <- reticulate::import("src.load")
  loader = data_load$DataLoader()
  df <- loader$channels()$to_pandas()
  return(df)
}

videos <- function() {
  data_load <- reticulate::import("src.load")
  loader = data_load$DataLoader()
  df <- loader$videos()$to_pandas()
  return(df)
}

sentences <- function() {
  data_load <- reticulate::import("src.load")
  loader = data_load$DataLoader()
  df <- loader$sentences()$to_pandas()
  return(df)
}

popbert <- function() {
  data_load <- reticulate::import("src.load")
  loader = data_load$DataLoader()
  df <- loader$popbert()$to_pandas()
  return(df)
}
