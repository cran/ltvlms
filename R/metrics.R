#' Calculate growth-model accuracy and information criteria
#'
#' @param observed Numeric observed values.
#' @param predicted Numeric predictions of equal length.
#' @param n_parameters Number of fitted curve parameters, excluding residual
#'   variance.
#' @param convention `"standard"` for Gaussian likelihood criteria or
#'   `"paper"` for the constant-free least-squares formulas used for
#'   manuscript-comparison reporting.
#' @return A one-row data frame of metrics.
#' @export
growth_metrics <- function(observed, predicted, n_parameters,
                           convention = c("standard", "paper")) {
  convention <- match.arg(convention)
  if (!is.numeric(observed) || !is.numeric(predicted) ||
      length(observed) != length(predicted) || length(observed) < 2L ||
      anyNA(observed) || anyNA(predicted) ||
      any(!is.finite(observed)) || any(!is.finite(predicted))) {
    stop("`observed` and `predicted` must be equal-length finite numeric vectors.", call. = FALSE)
  }
  if (length(n_parameters) != 1L || !is.numeric(n_parameters) ||
      n_parameters < 1 || n_parameters != as.integer(n_parameters)) {
    stop("`n_parameters` must be a positive whole number.", call. = FALSE)
  }

  n <- length(observed)
  residuals <- observed - predicted
  rss <- sum(residuals^2)
  mse <- rss / n
  tss <- sum((observed - mean(observed))^2)
  r_squared <- if (tss == 0) NA_real_ else 1 - rss / tss

  if (mse == 0) {
    aic <- bic <- aicc <- -Inf
  } else if (convention == "standard") {
    p <- n_parameters + 1L
    minus_twice_log_likelihood <- n * (log(2 * pi) + 1 + log(mse))
    aic <- minus_twice_log_likelihood + 2 * p
    bic <- minus_twice_log_likelihood + log(n) * p
    aicc <- if (n > p + 1) aic + 2 * p * (p + 1) / (n - p - 1) else NA_real_
  } else {
    p <- n_parameters
    aic <- n * log(mse) + 2 * p
    bic <- n * log(mse) + log(n) * p
    aicc <- if (n > p + 1) aic + 2 * p * (p + 1) / (n - p - 1) else NA_real_
  }

  data.frame(
    n = n,
    parameters = n_parameters,
    mse = mse,
    rmse = sqrt(mse),
    r_squared = r_squared,
    aic = aic,
    bic = bic,
    aicc = aicc,
    convention = convention,
    stringsAsFactors = FALSE
  )
}

#' @export
metrics <- function(object, convention = c("standard", "paper"), ...) {
  UseMethod("metrics")
}

#' @export
metrics.growth_fit <- function(object, convention = c("standard", "paper"), ...) {
  growth_metrics(
    object$response,
    object$fitted.values,
    length(object$coefficients),
    convention = match.arg(convention)
  )
}
