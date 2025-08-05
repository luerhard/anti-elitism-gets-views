library(tidyverse)
library(tidybayes)
library(brms)
library(here)

options(box.path = here())

box::use(
  r / load
)

out_path <- here("data", "models")

bayes_model <- function(form, data, quantile) {
  my_priors <- c(
    prior(normal(0, 15), class = "Intercept"),
    prior(normal(0, 5), class = "b"),
    prior(cauchy(0, 2), class = "sigma")
  )

  brms_form <- brms::bf(form, quantile = quantile)

  model <- brms::brm(
    brms_form,
    data = data,
    family = asym_laplace(),
    prior = my_priors,
    chains = 4,
    cores = 4,
    threads = threading(4),
    iter = 4000,
    warmup = 1000,
    seed = 1337,
    control = list(adapt_delta = 0.95)
  )

  return(model)
}

df <- load$regression_data()

parties <- df |>
  pull(party) |>
  unique()


model_types <- list(
  views_elite = formula(video_views ~ channel + log_n_sents + released_year + is_short + elite),
  views_pplcentr = formula(video_views ~ channel + log_n_sents + released_year + is_short + pplcentr),
  likes_elite = formula(video_likes ~ channel + log_n_sents + released_year + is_short + elite),
  likes_pplcentr = formula(video_likes ~ channel + log_n_sents + released_year + is_short + pplcentr)
)

quantiles <- c(0.5, 0.6, 0.7, 0.75, 0.8, 0.85, 0.9, 0.91, 0.92, 0.93, 0.94, 0.95)

for (model_type in names(model_types)) {
  print(paste("Starting model_type", model_type))
  model_formula <- model_types[[model_type]]

  fbase <- here(out_path, model_type)

  for (party in parties) {
    print(paste("Starting party", party, ", model_type: ", model_type))

    party_clean <- tolower(gsub("/", "_", party))
    fparty <- here(fbase, party_clean)
    if (!dir.exists(fparty)) dir.create(fparty, recursive = T)

    for (quantile in quantiles) {
      fname <- paste0("q", quantile * 100, ".rds")
      fpath <- here(fparty, fname)

      if (file.exists(fpath)) {
        print("model exists. skipping.")
        next
      }

      print(paste(
        "Starting quantile", quantile, ", party",
        party, "model_type:", model_type
      ))

      reg_df <- df |>
        filter(party == !!party) |>
        mutate(
          channel = channel |> fct_drop(),
          party = party |> fct_drop()
        )

      if (startsWith(model_type, "views")) {
        reg_df <- reg_df |>
          drop_na(video_views)
      } else if (startsWith(model_type, "likes")) {
        reg_df <- reg_df |>
          group_by(channel) |>
          filter(sum(!is.na(video_likes)) > 10) |>
          ungroup() |>
          drop_na(video_likes)
      } else {
        stop("Wrong model specification!")
      }

      # Check if there's only one channel after filtering
      n_channels <- reg_df |>
        pull(channel) |>
        n_distinct()

      # Modify formula if only one channel
      # important for FDP likes
      if (n_channels <= 1) {
        print("Only one channel found. Removing channel from model formula.")

        # Remove channel term from formula
        current_formula <- model_formula
        formula_terms <- all.vars(current_formula)

        # Get response variable (left side of ~)
        response_var <- formula_terms[1]

        # Get predictor variables (right side of ~), excluding 'channel'
        predictor_vars <- formula_terms[-1]
        predictor_vars <- predictor_vars[predictor_vars != "channel"]

        # Create new formula without channel
        new_formula_string <- paste(response_var, "~", paste(predictor_vars, collapse = " + "))
        current_formula <- as.formula(new_formula_string)
      } else {
        current_formula <- model_formula
      }


      model <- bayes_model(form = current_formula, data = reg_df, quantile = quantile)
      saveRDS(model, fpath, compress = TRUE)
      model <- NULL
      gc()
    }
  }
}
