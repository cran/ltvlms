library(ltvlms)

data(south_africa_hiv)
fit <- fit_growth_model(
  south_africa_hiv$year,
  south_africa_hiv$prevalence,
  model = "ltvlms",
  n_starts = 50,
  seed = 42
)
result <- metrics(fit, convention = "paper")
parameters <- coef(fit)

# Regression targets based on the latest manuscript's South Africa Table 3 fit.
stopifnot(
  abs(parameters[["K"]] - 22.594967) < 0.01,
  abs(parameters[["r0"]] - 1.711236) < 0.01,
  abs(parameters[["r1"]] - (-0.068428)) < 0.001,
  abs(parameters[["nu"]] - 0.126491) < 0.001,
  abs(result$rmse - 0.1484856) < 0.001,
  result$r_squared > 0.999,
  fit$successful_starts >= 1L,
  length(fit$boundary_hits) == 0L
)
