\name{fit_growth_model}
\alias{fit_growth_model}
\title{Fit a Nonlinear Growth Model}
\usage{
fit_growth_model(
  time,
  response,
  model = c("ltvlms", "logistic", "gompertz", "richards"),
  n_starts = 50L,
  bounds = NULL,
  seed = 42,
  control = list(iter.max = 10000L, eval.max = 20000L)
)
}
\arguments{
  \item{time}{Finite numeric observation times.}
  \item{response}{Finite positive observed responses.}
  \item{model}{Name of the growth model to fit.}
  \item{n_starts}{Number of Latin hypercube starting points.}
  \item{bounds}{Optional named list of lower and upper parameter bounds.}
  \item{seed}{Seed used to generate starting points.}
  \item{control}{Control list passed to \code{nlminb}.}
}
\value{An object of class \code{growth_fit}.}
\description{
Fits a growth model using bounded PORT optimization from multiple Latin
hypercube starting values. Failed starts are retained in the convergence count
rather than silently treated as successful.
}
\examples{
time <- 0:12
response <- logistic_growth(time, K = 20, r = 0.4, y0 = 1)
fit <- fit_growth_model(time, response, model = "logistic", n_starts = 5)
fit
}
