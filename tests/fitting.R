library(ltvlms)

time <- 0:12
response <- logistic_growth(time, K = 20, r = 0.4, y0 = 1)

fit <- fit_growth_model(
  time,
  response,
  model = "logistic",
  n_starts = 10,
  seed = 42
)

stopifnot(
  inherits(fit, "growth_fit"),
  max(abs(fitted(fit) - response)) < 2e-4,
  length(coef(fit)) == 2L,
  length(residuals(fit)) == length(response),
  length(predict(fit, 13:15)) == 3L,
  metrics(fit)$rmse < 1e-4
)

paper <- growth_metrics(response, fitted(fit), 2, convention = "paper")
standard <- growth_metrics(response, fitted(fit), 2, convention = "standard")
stopifnot(paper$convention == "paper", standard$convention == "standard")
