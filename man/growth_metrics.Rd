\name{growth_metrics}
\alias{growth_metrics}
\alias{metrics}
\alias{metrics.growth_fit}
\title{Growth Model Performance Metrics}
\usage{
growth_metrics(observed, predicted, n_parameters,
  convention = c("standard", "paper"))

metrics(object, convention = c("standard", "paper"), ...)

\method{metrics}{growth_fit}(object,
  convention = c("standard", "paper"), ...)
}
\arguments{
  \item{observed}{Numeric observed values.}
  \item{predicted}{Numeric predicted values.}
  \item{n_parameters}{Number of fitted curve parameters, excluding variance.}
  \item{convention}{Information-criterion convention. Use \code{"paper"} for
  the constant-free least-squares formulas used for manuscript-comparison
  reporting.}
  \item{object}{A fitted growth model.}
  \item{...}{Additional arguments reserved for methods.}
}
\value{A one-row data frame containing MSE, RMSE, R-squared, AIC, BIC, and AICc.}
\description{
Calculates prediction metrics and consistently defined information criteria.
}
