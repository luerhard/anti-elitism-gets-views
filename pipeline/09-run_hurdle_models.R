library(tidyverse)
library(tidybayes)
library(brms)
library(here)

options(box.path = here())

box::use(
  r / load
)

out_path <- here("data", "models", "hurdle")

bayes_model <- function(form, data) {

  log_mean_y <- mean(data$video_views[data$video_views > 0], na.rm = TRUE) |> log() |> as.numeric()
  qlogis_09 <- qlogis(0.9)

  print(paste("LOG MEAN Y:", log_mean_y))

  my_priors <- c(
      prior(normal(0, 3), class = "b", dpar="mu"),
      prior(normal(0, 4), class = "b", dpar = "hu"),
      prior_string(paste0("normal(", log_mean_y, ", 2)"), class = "Intercept", dpar = "mu"),
      prior_string(paste0("normal(", qlogis_09, ", 0.5)"), class = "Intercept", dpar = "hu"),
      prior(exponential(1), class = "shape")
  )

  model <- brms::brm(
    form,
    data = data,
    family = hurdle_negbinomial(),
    prior = my_priors,
    chains = 4,
    cores = 6,
    threads = threading(2),
    iter = 4000,
    warmup = 2000,
    seed = 1337,
    control = list(
        adapt_delta = 0.99,
        max_treedepth = 15
    )
  )

  return(model)
}

df <- load$regression_data()

parties <- df |>
  pull(party) |>
  unique()

model_types <- list(
    views_elite = brms::bf(
      video_views ~ elite + channel + released_year + log_n_sents + is_short,
      hu ~ elite + channel + released_year + log_n_sents + is_short
    ),
    views_pplcentr = brms::bf(
      video_views ~ pplcentr + channel + released_year + log_n_sents + is_short,
      hu ~ pplcentr + channel + released_year + log_n_sents + is_short
    )
)

for (model_type in names(model_types)) {
  model_formula <- model_types[[model_type]]

  fbase <- here(out_path, model_type)

  for (party in parties) {
    print(paste("Starting party", party, ", model_type: ", model_type))

    party_clean <- tolower(gsub("/", "_", party))

    reg_df <- df |>
      filter(party == !!party) |>
      drop_na(video_views) |>
      mutate(
        channel = channel |> fct_drop(),
        party = party |> fct_drop(),
      ) |>
      group_by(channel, released_year) |>
      mutate(
        video_views = d_video_views,
        q = quantile(video_views, probs=0.9, type = 7),
        video_views = ifelse(video_views > q, video_views, 0)
      ) |>
      ungroup()

    if (!dir.exists(fbase)) dir.create(fbase, recursive = T)
    fpath <- here(fbase, paste0(party_clean, ".rds"))

    if (file.exists(fpath)) {
      print("model exists. skipping.")
      next
    }

    model <- bayes_model(form = model_formula, data = reg_df)
    print(paste("Saving party", party, "model_type:", model_type))
    saveRDS(model, fpath, compress = TRUE)
    model <- NULL
    gc()
  }
}
