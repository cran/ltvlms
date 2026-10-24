library(ltvlms)

time <- 0:20
logistic <- logistic_growth(time, K = 100, r = 0.5, y0 = 2)
special_case <- ltvlms(time, K = 100, y0 = 2, r0 = 0.5, r1 = 0, nu = 1)

stopifnot(
  isTRUE(all.equal(logistic, special_case, tolerance = 1e-12)),
  isTRUE(all.equal(ltvlms(0, 100, 2, 0.5), 2, tolerance = 1e-12)),
  isTRUE(all.equal(ltvlms(0:5, 100, 100, 0.5), rep(100, 6))),
  length(gompertz_growth(time, 100, 0.2, 5)) == length(time),
  length(richards_growth(time, 100, 0.2, 5, 0.5, 1.2)) == length(time)
)

invalid <- try(ltvlms(time, K = -1, y0 = 2, r0 = 0.5), silent = TRUE)
stopifnot(inherits(invalid, "try-error"))
