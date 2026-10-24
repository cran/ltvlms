library(ltvlms)

time <- 0:12
response <- logistic_growth(time, K = 20, r = 0.4, y0 = 1)

# Model evaluations remain finite across deliberately extreme, valid inputs.
stopifnot(
  all(is.finite(ltvlms(0:100, K = 1e6, y0 = 1e-6, r0 = 10, r1 = -1, nu = 5))),
  all(is.finite(gompertz_growth(-100:100, K = 1e6, r = 10, t0 = 0))),
  all(is.finite(richards_growth(-100:100, K = 1e6, r = 10, t0 = 0,
                                alpha = 10, nu = 0.1)))
)

# A local seed must not change the caller's random-number stream.
set.seed(123)
seed_before <- .Random.seed
fit_a <- fit_growth_model(time, response, "logistic", n_starts = 5, seed = 9)
seed_after <- .Random.seed
fit_b <- fit_growth_model(time, response, "logistic", n_starts = 5, seed = 9)
stopifnot(
  identical(seed_before, seed_after),
  identical(coef(fit_a), coef(fit_b))
)

# Invalid data and bounds must fail loudly rather than being discarded.
bad_missing <- try(
  fit_growth_model(time, replace(response, 2, NA_real_), "logistic"),
  silent = TRUE
)
bad_time <- try(fit_growth_model(rep(1, length(time)), response, "logistic"), silent = TRUE)
bad_bound <- try(
  fit_growth_model(time, response, "logistic", bounds = list(r = c(1, 0))),
  silent = TRUE
)
stopifnot(
  inherits(bad_missing, "try-error"),
  inherits(bad_time, "try-error"),
  inherits(bad_bound, "try-error")
)

# R-squared is deliberately undefined for a constant observed response.
constant <- growth_metrics(rep(2, 5), rep(2.1, 5), 1)
stopifnot(is.na(constant$r_squared))
