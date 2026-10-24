.with_seed <- function(seed, code) {
  if (is.null(seed)) {
    return(force(code))
  }
  if (length(seed) != 1L || !is.numeric(seed) || !is.finite(seed)) {
    stop("`seed` must be NULL or one finite number.", call. = FALSE)
  }

  had_seed <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  if (had_seed) {
    old_seed <- get(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  }
  on.exit({
    if (had_seed) {
      assign(".Random.seed", old_seed, envir = .GlobalEnv)
    } else if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) {
      rm(".Random.seed", envir = .GlobalEnv)
    }
  }, add = TRUE)

  set.seed(seed)
  force(code)
}

.latin_hypercube <- function(lower, upper, n, seed = NULL) {
  if (length(lower) != length(upper) || any(lower >= upper)) {
    stop("Every lower bound must be smaller than its upper bound.", call. = FALSE)
  }
  if (length(n) != 1L || n < 1 || n != as.integer(n)) {
    stop("`n` must be a positive whole number.", call. = FALSE)
  }

  .with_seed(seed, {
    unit <- vapply(
      seq_along(lower),
      function(j) (sample.int(n) - stats::runif(n)) / n,
      numeric(n)
    )
    starts <- sweep(unit, 2L, upper - lower, `*`)
    starts <- sweep(starts, 2L, lower, `+`)
    colnames(starts) <- names(lower)
    starts
  })
}
