\name{cross_validate_growth}
\alias{cross_validate_growth}
\alias{print.growth_cv}
\title{Cross-Validate a Growth Model}
\usage{
cross_validate_growth(time, response,
  model = c("ltvlms", "logistic", "gompertz", "richards"),
  folds = 5L, method = c("random", "forward"),
  n_starts = 20L, seed = 42, bounds = NULL)

\method{print}{growth_cv}(x, ...)
}
\arguments{
  \item{time}{Numeric observation times.}
  \item{response}{Positive numeric observations.}
  \item{model}{Growth model name.}
  \item{folds}{Number of validation folds.}
  \item{method}{Random interpolation folds or forward forecasting folds.}
  \item{n_starts}{Multi-start attempts per training fold.}
  \item{seed}{Seed for folds and starting values.}
  \item{bounds}{Optional parameter bounds.}
  \item{x}{A \code{growth_cv} object.}
  \item{...}{Additional arguments reserved for methods.}
}
\value{An object containing fold results, predictions, fitted models, and mean errors.}
\description{
Random folds assess interpolation similarly to the manuscript. Forward folds
train only on earlier observations and assess forecasting of later observations.
}
