.validate_curve_inputs <- function(t, parameters, positive = character()) {
  if (!is.numeric(t) || anyNA(t) || any(!is.finite(t))) {
    stop("`t` must contain only finite numeric values.", call. = FALSE)
  }
  if (!all(vapply(parameters, is.numeric, logical(1))) ||
      !all(lengths(parameters) == 1L) ||
      anyNA(unlist(parameters, use.names = FALSE)) ||
      any(!is.finite(unlist(parameters, use.names = FALSE)))) {
    stop("Model parameters must be finite numeric scalars.", call. = FALSE)
  }
  if (any(unlist(parameters[positive], use.names = FALSE) <= 0)) {
    stop(
      sprintf("%s must be positive.", paste(sprintf("`%s`", positive), collapse = ", ")),
      call. = FALSE
    )
  }
  invisible(NULL)
}

.softplus <- function(x) {
  ifelse(x > 0, x + log1p(exp(-x)), log1p(exp(x)))
}

#' Evaluate classical and time-varying growth curves
#'
#' These vectorized functions evaluate the four growth curves compared in the
#' LTVLMS manuscript. `t` is measured from the model's time origin.
#'
#' @param t Numeric vector of time points.
#' @param K Positive carrying capacity.
#' @param y0 Positive initial value at `t = 0`, not greater than `K`.
#' @param r Positive constant growth rate.
#' @param t0 Location parameter for the Gompertz and Richards curves.
#' @param alpha Positive Richards scale parameter.
#' @param nu Positive shape parameter.
#' @param r0 Initial LTVLMS growth rate.
#' @param r1 Linear change in the LTVLMS growth rate.
#' @return A numeric vector with the same length as `t`.
#' @name growth_curves
NULL

#' @rdname growth_curves
#' @export
logistic_growth <- function(t, K, r, y0) {
  parameters <- list(K = K, r = r, y0 = y0)
  .validate_curve_inputs(t, parameters, positive = names(parameters))
  if (y0 > K) {
    stop("`y0` must not exceed `K`.", call. = FALSE)
  }
  if (y0 == K) {
    return(rep(as.numeric(K), length(t)))
  }

  log_odds <- log((K - y0) / y0) - r * t
  exp(log(K) - .softplus(log_odds))
}

#' @rdname growth_curves
#' @export
gompertz_growth <- function(t, K, r, t0) {
  parameters <- list(K = K, r = r, t0 = t0)
  .validate_curve_inputs(t, parameters, positive = c("K", "r"))

  inner <- exp(pmax(-500, pmin(500, -r * (t - t0))))
  exp(log(K) - inner)
}

#' @rdname growth_curves
#' @export
richards_growth <- function(t, K, r, t0, alpha, nu) {
  parameters <- list(K = K, r = r, t0 = t0, alpha = alpha, nu = nu)
  .validate_curve_inputs(
    t,
    parameters,
    positive = c("K", "r", "alpha", "nu")
  )

  log_term <- log(alpha) - r * (t - t0)
  exp(log(K) - .softplus(log_term) / nu)
}

#' @rdname growth_curves
#' @export
ltvlms <- function(t, K, y0, r0, r1 = 0, nu = 1) {
  parameters <- list(K = K, y0 = y0, r0 = r0, r1 = r1, nu = nu)
  .validate_curve_inputs(t, parameters, positive = c("K", "y0", "nu"))
  if (y0 > K) {
    stop("`y0` must not exceed `K`.", call. = FALSE)
  }
  if (y0 == K) {
    return(rep(as.numeric(K), length(t)))
  }

  cumulative_rate <- r0 * t + 0.5 * r1 * t^2
  exponent <- pmax(-500, pmin(500, -nu * cumulative_rate))
  log_capacity_ratio <- nu * log(K / y0)
  log_ratio <- if (log_capacity_ratio > 50) {
    log_capacity_ratio
  } else {
    log(expm1(log_capacity_ratio))
  }

  exp(log(K) - .softplus(log_ratio + exponent) / nu)
}

.model_spec <- function(model) {
  switch(
    model,
    logistic = list(
      fun = logistic_growth,
      parameters = c("K", "r"),
      uses_y0 = TRUE
    ),
    gompertz = list(
      fun = gompertz_growth,
      parameters = c("K", "r", "t0"),
      uses_y0 = FALSE
    ),
    richards = list(
      fun = richards_growth,
      parameters = c("K", "r", "t0", "alpha", "nu"),
      uses_y0 = FALSE
    ),
    ltvlms = list(
      fun = ltvlms,
      parameters = c("K", "r0", "r1", "nu"),
      uses_y0 = TRUE
    ),
    stop("Unknown growth model.", call. = FALSE)
  )
}

.evaluate_model <- function(model, t, coefficients, y0) {
  spec <- .model_spec(model)
  arguments <- c(list(t = t), as.list(coefficients))
  if (spec$uses_y0) {
    arguments$y0 <- y0
  }
  do.call(spec$fun, arguments)
}
