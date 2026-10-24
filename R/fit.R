.default_bounds <- function(model, time, response, y0) {
  maximum <- max(response)
  time_range <- range(time)
  common <- list(
    K = c(max(0.5 * maximum, y0 * 1.001), maximum * 2),
    r = c(0.0001, 1),
    t0 = time_range,
    alpha = c(0.001, 10),
    nu = c(0.01, 10),
    # The manuscript reports r0 = 1.711236 for the South Africa fit. An upper
    # limit of 3 retains a bounded search while allowing that reported scale.
    r0 = c(0.0001, 3),
    r1 = c(-1, 0)
  )
  common[.model_spec(model)$parameters]
}

.merge_bounds <- function(defaults, bounds) {
  if (is.null(bounds)) {
    bounds <- defaults
  } else {
    if (!is.list(bounds) || is.null(names(bounds))) {
      stop("`bounds` must be a named list of lower/upper pairs.", call. = FALSE)
    }
    unknown <- setdiff(names(bounds), names(defaults))
    if (length(unknown)) {
      stop(sprintf("Unknown bound: %s.", paste(unknown, collapse = ", ")), call. = FALSE)
    }
    defaults[names(bounds)] <- bounds
    bounds <- defaults
  }

  valid <- vapply(
    bounds,
    function(x) is.numeric(x) && length(x) == 2L &&
      all(is.finite(x)) && x[1] < x[2],
    logical(1)
  )
  if (!all(valid)) {
    stop("Each bound must contain two finite numbers in increasing order.", call. = FALSE)
  }
  bounds
}

#' Fit a nonlinear growth model with multi-start optimization
#'
#' Fits one of the four manuscript models using bounded PORT optimization
#' from Latin hypercube starting values.
#'
#' @param time Finite numeric observation times.
#' @param response Finite, positive observed responses.
#' @param model One of `"ltvlms"`, `"logistic"`, `"gompertz"`, or
#'   `"richards"`.
#' @param n_starts Number of Latin hypercube starting points.
#' @param bounds Optional named list overriding default lower/upper bounds.
#' @param seed Random seed used only to generate starting points.
#' @param control Optional list passed to [stats::nlminb()].
#' @return An object of class `growth_fit`.
#' @export
fit_growth_model <- function(time, response,
                             model = c("ltvlms", "logistic", "gompertz", "richards"),
                             n_starts = 50L, bounds = NULL, seed = 42,
                             control = list(iter.max = 10000L, eval.max = 20000L)) {
  model <- match.arg(model)
  if (!is.numeric(time) || !is.numeric(response) || length(time) != length(response)) {
    stop("`time` and `response` must be numeric vectors of equal length.", call. = FALSE)
  }
  if (length(time) < 3L || anyNA(time) || anyNA(response) ||
      any(!is.finite(time)) || any(!is.finite(response))) {
    stop("Provide at least three complete, finite observations.", call. = FALSE)
  }
  if (length(unique(time)) < 2L) {
    stop("`time` must contain at least two distinct values.", call. = FALSE)
  }
  if (any(response <= 0)) {
    stop("`response` values must be positive.", call. = FALSE)
  }

  ordering <- order(time)
  time <- time[ordering]
  response <- response[ordering]
  origin <- min(time)
  scaled_time <- time - origin
  y0 <- response[which.min(scaled_time)]
  spec <- .model_spec(model)
  bounds <- .merge_bounds(.default_bounds(model, scaled_time, response, y0), bounds)
  lower <- stats::setNames(vapply(bounds, `[`, numeric(1), 1L), names(bounds))
  upper <- stats::setNames(vapply(bounds, `[`, numeric(1), 2L), names(bounds))
  starts <- .latin_hypercube(lower, upper, n = n_starts, seed = seed)

  objective <- function(parameters) {
    names(parameters) <- spec$parameters
    prediction <- tryCatch(
      .evaluate_model(model, scaled_time, parameters, y0),
      error = function(e) rep(NA_real_, length(response))
    )
    if (any(!is.finite(prediction))) {
      return(.Machine$double.xmax / 100)
    }
    sum((response - prediction)^2)
  }

  attempts <- vector("list", n_starts)
  best <- NULL
  for (i in seq_len(n_starts)) {
    result <- tryCatch(
      stats::nlminb(
        start = starts[i, ], objective = objective,
        lower = lower, upper = upper, control = control
      ),
      error = identity
    )
    attempts[[i]] <- result
    if (!inherits(result, "error") && result$convergence == 0L &&
        is.finite(result$objective) &&
        (is.null(best) || result$objective < best$objective)) {
      best <- result
    }
  }
  successful <- sum(vapply(
    attempts,
    function(x) !inherits(x, "error") &&
      x$convergence == 0L && is.finite(x$objective),
    logical(1)
  ))
  if (is.null(best)) {
    stop("All optimization starts failed to converge; inspect the data or bounds.", call. = FALSE)
  }

  coefficients <- stats::setNames(best$par, spec$parameters)
  tolerance <- sqrt(.Machine$double.eps) * pmax(1, upper - lower)
  boundary_hits <- names(coefficients)[
    abs(coefficients - lower) <= tolerance |
      abs(coefficients - upper) <= tolerance
  ]
  fitted_values <- .evaluate_model(model, scaled_time, coefficients, y0)
  object <- list(
    model = model,
    coefficients = coefficients,
    time = time,
    scaled_time = scaled_time,
    response = response,
    origin = origin,
    y0 = y0,
    fitted.values = fitted_values,
    residuals = response - fitted_values,
    sse = sum((response - fitted_values)^2),
    bounds = bounds,
    n_starts = as.integer(n_starts),
    successful_starts = successful,
    boundary_hits = boundary_hits,
    seed = seed,
    optimization = best,
    call = match.call()
  )
  class(object) <- "growth_fit"
  object
}
