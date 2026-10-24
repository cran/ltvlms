\name{compare_growth_models}
\alias{compare_growth_models}
\alias{print.growth_comparison}
\alias{plot.growth_comparison}
\title{Compare Growth Models}
\usage{
compare_growth_models(time, response,
  models = c("logistic", "gompertz", "richards", "ltvlms"),
  n_starts = 50L, seed = 42, bounds = NULL,
  convention = c("standard", "paper"))

\method{print}{growth_comparison}(x, ...)
\method{plot}{growth_comparison}(x, ..., xlab = "Time", ylab = "Response")
}
\arguments{
  \item{time}{Numeric observation times.}
  \item{response}{Positive numeric observations.}
  \item{models}{Character vector of model names.}
  \item{n_starts}{Number of multi-start attempts per model.}
  \item{seed}{Seed for reproducible starting points.}
  \item{bounds}{Optional named list of model-specific bound lists.}
  \item{convention}{Information-criterion convention.}
  \item{x}{A \code{growth_comparison} object.}
  \item{xlab, ylab}{Plot axis labels.}
  \item{...}{Additional graphical arguments.}
}
\value{An object containing successful fits, metrics, and failure messages.}
\description{
Fits multiple models under the same workflow and reports consistently computed
performance metrics. Failed models remain visible rather than being discarded.
}
