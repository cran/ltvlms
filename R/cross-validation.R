.random_folds <- function(n, folds, seed) {
  .with_seed(seed, sample(rep(seq_len(folds), length.out = n)))
}

.forward_folds <- function(n, folds, minimum_training) {
  remaining <- seq.int(minimum_training + 1L, n)
  if (length(remaining) < folds) {
    stop("Not enough observations for the requested forward folds.", call. = FALSE)
  }
  groups <- cut(seq_along(remaining), breaks = folds, labels = FALSE)
  split(remaining, groups)
}

#' Cross-validate a growth model
#'
#' Random folds assess interpolation in the style of the manuscript. Forward
#' folds train only on earlier observations and are more appropriate when the
#' intended use is forecasting later observations.
#'
#' @param time Numeric observation times.
#' @param response Positive numeric observations.
#' @param model Growth model name.
#' @param folds Number of validation folds.
#' @param method Either `"random"` or `"forward"`.
#' @param n_starts Multi-start attempts within each training fold.
#' @param seed Seed for fold assignment and starting points.
#' @param bounds Optional parameter bounds passed to [fit_growth_model()].
#' @return An object of class `growth_cv`.
#' @export
cross_validate_growth <- function(
    time,
    response,
    model = c("ltvlms", "logistic", "gompertz", "richards"),
    folds = 5L,
    method = c("random", "forward"),
    n_starts = 20L,
    seed = 42,
    bounds = NULL) {
  model <- match.arg(model)
  method <- match.arg(method)
  if (!is.numeric(time) || !is.numeric(response) || length(time) != length(response) ||
      length(time) < 6L || anyNA(time) || anyNA(response) ||
      any(!is.finite(time)) || any(!is.finite(response)) || any(response <= 0)) {
    stop("Provide at least six complete finite times and positive responses.", call. = FALSE)
  }
  if (length(folds) != 1L || !is.numeric(folds) || folds < 2L ||
      folds != as.integer(folds) || folds >= length(time)) {
    stop("`folds` must be a whole number between 2 and n - 1.", call. = FALSE)
  }

  ordering <- order(time)
  time <- time[ordering]
  response <- response[ordering]
  n <- length(time)
  if (method == "random") {
    assignment <- .random_folds(n, folds, seed)
    test_sets <- lapply(seq_len(folds), function(i) which(assignment == i))
  } else {
    minimum_training <- max(length(.model_spec(model)$parameters) + 2L, ceiling(n / 3))
    test_sets <- .forward_folds(n, folds, minimum_training)
  }

  results <- vector("list", length(test_sets))
  predictions <- vector("list", length(test_sets))
  fits <- vector("list", length(test_sets))
  for (i in seq_along(test_sets)) {
    test <- test_sets[[i]]
    train <- if (method == "random") setdiff(seq_len(n), test) else seq_len(min(test) - 1L)
    fold_seed <- if (is.null(seed)) NULL else seed + i
    fit <- tryCatch(
      fit_growth_model(
        time[train], response[train], model = model,
        n_starts = n_starts, bounds = bounds, seed = fold_seed
      ),
      error = identity
    )
    if (inherits(fit, "error")) {
      results[[i]] <- data.frame(
        fold = i, n_train = length(train), n_test = length(test),
        mse = NA_real_, rmse = NA_real_, status = conditionMessage(fit)
      )
      next
    }
    prediction <- stats::predict(fit, time[test])
    error <- response[test] - prediction
    results[[i]] <- data.frame(
      fold = i, n_train = length(train), n_test = length(test),
      mse = mean(error^2), rmse = sqrt(mean(error^2)), status = "ok"
    )
    predictions[[i]] <- data.frame(
      fold = i, time = time[test], observed = response[test], predicted = prediction
    )
    fits[[i]] <- fit
  }

  fold_results <- do.call(rbind, results)
  valid <- is.finite(fold_results$mse)
  if (!any(valid)) {
    stop("All cross-validation folds failed.", call. = FALSE)
  }
  prediction_rows <- Filter(Negate(is.null), predictions)
  object <- list(
    model = model,
    method = method,
    folds = fold_results,
    predictions = do.call(rbind, prediction_rows),
    mean_mse = mean(fold_results$mse[valid]),
    mean_rmse = mean(fold_results$rmse[valid]),
    successful_folds = sum(valid),
    requested_folds = as.integer(folds),
    fits = fits[!vapply(fits, is.null, logical(1))],
    call = match.call()
  )
  class(object) <- "growth_cv"
  object
}

#' @export
print.growth_cv <- function(x, ...) {
  cat(sprintf("%s cross-validation for %s\n", tools::toTitleCase(x$method), toupper(x$model)))
  cat(sprintf("Successful folds: %d of %d\n", x$successful_folds, x$requested_folds))
  cat(sprintf("Mean MSE: %.6g\n", x$mean_mse))
  cat(sprintf("Mean RMSE: %.6g\n", x$mean_rmse))
  invisible(x)
}
