library(ltvlms)

time <- 0:12
response <- logistic_growth(time, K = 20, r = 0.4, y0 = 1)

comparison <- compare_growth_models(
  time,
  response,
  models = c("logistic", "ltvlms"),
  n_starts = 5,
  seed = 42
)
stopifnot(
  inherits(comparison, "growth_comparison"),
  nrow(comparison$metrics) == 2L,
  all(c("model", "rmse", "aic", "bic") %in% names(comparison$metrics))
)

legend_labels <- getFromNamespace(".model_legend_labels", "ltvlms")(
  c("logistic", "gompertz", "richards", "ltvlms")
)
stopifnot(
  identical(legend_labels, c("logistic", "Gompertz", "Richards", "ltvlms"))
)

random_cv <- cross_validate_growth(
  time, response, model = "logistic", folds = 3,
  method = "random", n_starts = 3, seed = 42
)
forward_cv <- cross_validate_growth(
  time, response, model = "logistic", folds = 3,
  method = "forward", n_starts = 3, seed = 42
)
stopifnot(
  inherits(random_cv, "growth_cv"),
  inherits(forward_cv, "growth_cv"),
  random_cv$successful_folds >= 1L,
  forward_cv$successful_folds >= 1L
)
