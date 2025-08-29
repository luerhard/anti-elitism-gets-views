library(here)
library(dplyr)

options(box.path = here())

box::use(
  r / load
)

model_path <- here("data", "models")

model_types <- list.dirs(model_path, full.names = F, recursive = F)

dfs <- list()
i <- 0
for (model_type in model_types) {
  if (model_type == "") next
  if (model_type == "hurdle") next
  cat("Processing model:", model_type, "\n")

  type_path <- here(model_path, model_type)
  parties <- list.dirs(type_path, full.names = F, recursive = F)

  for (party in parties) {
    if (party == "") next

    df <- load$read_party_results(type_path, party)
    df$model_type <- model_type

    i <- i + 1
    dfs[[i]] <- df
  }
}

df_full <- dplyr::bind_rows(dfs)

saveRDS(df_full, here("data/interim/regression_results.rds"))
