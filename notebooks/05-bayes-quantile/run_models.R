library(tidyverse)
library(tidybayes)
library(brms)
library(here)

knitr::opts_chunk$set(echo = TRUE)
options(box.path = here())

box::use(
  r / load
)
box::reload(load)

z_transform <- function(x) as.vector(scale(x))

df <- load$regression_data()

df <- df |>
  group_by(channel) |>
  mutate(
    d_elite = elite,
    elite = z_transform(elite),
    d_pplcentr = pplcentr,
    pplcentr = z_transform(pplcentr),
    z_log_video_views <- z_transform(log_video_views),
    z_log_video_likes <- z_transform(log_video_likes),
  ) |>
  ungroup()

run_bayes_reg <- function(data, quantiles) {

  my_priors <- c(
    prior(normal(0, 15), class = "Intercept"),
    prior(normal(0, 5), class = "b"),
    prior(cauchy(0, 2), class = "sigma")
  )

  results <- list()

  for (q in quantiles) {
    elite_form_bayes <- brms::bf(
      log_video_views ~
        channel + log_n_sents + released_year + is_short + elite,
      quantile = q
    )

    model <- brms::brm(
      elite_form_bayes,
      data = reg_df,
      family = asym_laplace(),
      prior = my_priors,
      chains = 6,
      cores = 12,
      threads = threading(2),
      iter = 4000,
      warmup = 1000,
      control = list(adapt_delta = 0.95)
    )

    results[[paste0("q", q * 100)]] <- model
  }

  return(results)
}

parties <- df |> pull(party) |> unique()
quantiles = c(0.25, 0.5, 0.6, 0.7, 0.75, 0.8, 0.85, 0.9, 0.95, 0.99)

for (party in parties) {
  print(paste("Running model: ", party))

  reg_df <- df |>
    drop_na(video_views) |>
    filter(party == !!party) |>
    mutate(
      channel = channel |> fct_drop(),
      party = party |> fct_drop()
    )

    party_models <- run_bayes_reg(reg_df, quantiles = quantiles)

    clean_party <- tolower(gsub("/", "_", party))
    saveRDS(
      party_models,
      here("data", "models", paste0(clean_party, ".rds")),
      compress = T
    )

}
