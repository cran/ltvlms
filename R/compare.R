#' Fit and compare multiple growth models
#'
#' @param time Numeric observation times.
#' @param response Positive numeric observations.
#' @param models Character vector containing any of `"logistic"`, `"gompertz"`,
#'   `"richards"`, and `"ltvlms"`.
#' @param n_starts Number of multi-start attempts per model.
#' @param seed Seed for reproducible starting points.
#' @param bounds Optional named list of model-specific bound lists.
#' @param convention Information-criterion convention passed to [metrics()].
#' @return An object of class `growth_comparison`.
#' @export
compare_growth_models <- function(
    time,
    response,
    models = c("logistic", "gompertz", "richards", "ltvlms"),
    n_starts = 50L,
    seed = 42,
    bounds = NULL,
    convention = c("standard", "paper")) {
  convention <- match.arg(convention)
  allowed <- c("logistic", "gompertz", "richards", "ltvlms")
  if (!is.character(models) || !length(models) || any(!models %in% allowed)) {
    stop("`models` contains an unknown growth model.", call. = FALSE)
  }
  models <- unique(models)
  if (!is.null(bounds) && (!is.list(bounds) || is.null(names(bounds)))) {
    stop("`bounds` must be NULL or a named list indexed by model.", call. = FALSE)
  }

  fits <- failures <- stats::setNames(vector("list", length(models)), models)
  rows <- vector("list", length(models))
  for (i in seq_along(models)) {
    model <- models[i]
    model_bounds <- if (is.null(bounds)) NULL else bounds[[model]]
    model_seed <- if (is.null(seed)) NULL else seed + i - 1L
    result <- tryCatch(
      fit_growth_model(
        time,
        response,
        model = model,
        n_starts = n_starts,
        bounds = model_bounds,
        seed = model_seed
      ),
      error = identity
    )
    if (inherits(result, "error")) {
      failures[[model]] <- conditionMessage(result)
      next
    }
    fits[[model]] <- result
    row <- metrics(result, convention = convention)
    row$model <- model
    row$converged_starts <- result$successful_starts
    row$boundary_hits <- paste(result$boundary_hits, collapse = ", ")
    rows[[i]] <- row
  }

  rows <- Filter(Negate(is.null), rows)
  if (!length(rows)) {
    stop("None of the requested models converged.", call. = FALSE)
  }
  table <- do.call(rbind, rows)
  rownames(table) <- NULL
  table <- table[c(
    "model", "n", "parameters", "mse", "rmse", "r_squared",
    "aic", "bic", "aicc", "convention", "converged_starts", "boundary_hits"
  )]

  object <- list(
    fits = fits[!vapply(fits, is.null, logical(1))],
    metrics = table,
    failures = failures[!vapply(failures, is.null, logical(1))],
    time = time,
    response = response,
    call = match.call()
  )
  class(object) <- "growth_comparison"
  object
}

#' @export
print.growth_comparison <- function(x, ...) {
  print(x$metrics, row.names = FALSE)
  if (length(x$failures)) {
    cat("\nFailed models:\n")
    for (name in names(x$failures)) {
      cat(sprintf("- %s: %s\n", name, x$failures[[name]]))
    }
  }
  invisible(x)
}

.model_legend_labels <- function(models) {
  labels <- models
  labels[models == "gompertz"] <- "Gompertz"
  labels[models == "richards"] <- "Richards"
  labels
}

#' @export
plot.growth_comparison <- function(x, ..., xlab = "Time", ylab = "Response") {
  graphics::plot(x$time, x$response, xlab = xlab, ylab = ylab, ...)
  grid <- seq(min(x$time), max(x$time), length.out = 300L)
  colors <- grDevices::hcl.colors(length(x$fits), "Dark 3")
  for (i in seq_along(x$fits)) {
    graphics::lines(grid, stats::predict(x$fits[[i]], grid), col = colors[i], lwd = 2)
  }
  graphics::legend(
    "topleft",
    legend = .model_legend_labels(names(x$fits)),
    col = colors,
    lty = 1,
    lwd = 2,
    bty = "n"
  )
  invisible(x)
}
