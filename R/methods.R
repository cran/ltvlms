#' @export
coef.growth_fit <- function(object, ...) {
  object$coefficients
}

#' @export
fitted.growth_fit <- function(object, ...) {
  object$fitted.values
}

#' @export
residuals.growth_fit <- function(object, ...) {
  object$residuals
}

#' @export
predict.growth_fit <- function(object, newdata = NULL, ...) {
  if (is.null(newdata)) {
    return(object$fitted.values)
  }
  if (!is.numeric(newdata) || anyNA(newdata) || any(!is.finite(newdata))) {
    stop("`newdata` must contain finite numeric time values.", call. = FALSE)
  }
  .evaluate_model(
    object$model,
    newdata - object$origin,
    object$coefficients,
    object$y0
  )
}

#' @export
print.growth_fit <- function(x, ...) {
  cat(sprintf("%s growth model fit\n", toupper(x$model)))
  cat(sprintf("Observations: %d\n", length(x$response)))
  cat(sprintf("Converged starts: %d of %d\n", x$successful_starts, x$n_starts))
  cat("Coefficients:\n")
  print(x$coefficients)
  if (length(x$boundary_hits)) {
    cat(sprintf("At parameter bound: %s\n", paste(x$boundary_hits, collapse = ", ")))
  }
  invisible(x)
}

#' @export
plot.growth_fit <- function(x, ..., xlab = "Time", ylab = "Response") {
  graphics::plot(x$time, x$response, xlab = xlab, ylab = ylab, ...)
  grid <- seq(min(x$time), max(x$time), length.out = 300L)
  graphics::lines(grid, stats::predict(x, grid), col = "#C23B23", lwd = 2)
  invisible(x)
}
