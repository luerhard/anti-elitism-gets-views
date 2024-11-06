box::use(
  reticulate
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
