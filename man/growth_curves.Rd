\name{growth_curves}
\alias{growth_curves}
\alias{logistic_growth}
\alias{gompertz_growth}
\alias{richards_growth}
\alias{ltvlms}
\title{Evaluate Growth Curves}
\usage{
logistic_growth(t, K, r, y0)

gompertz_growth(t, K, r, t0)

richards_growth(t, K, r, t0, alpha, nu)

ltvlms(t, K, y0, r0, r1 = 0, nu = 1)
}
\arguments{
  \item{t}{Numeric vector of time points measured from the model origin.}
  \item{K}{Positive carrying capacity.}
  \item{r}{Positive constant growth rate.}
  \item{y0}{Positive initial response at time zero, not exceeding \code{K}.}
  \item{t0}{Location parameter for the Gompertz or Richards curve.}
  \item{alpha}{Positive Richards scale parameter.}
  \item{nu}{Positive shape parameter.}
  \item{r0}{Initial LTVLMS growth rate.}
  \item{r1}{Linear change in the LTVLMS growth rate.}
}
\value{A numeric vector with the same length as \code{t}.}
\description{
Evaluates the logistic, Gompertz, Richards, or Linear Time-Variant Logistic
Model with Shape Parameter using numerically stable calculations.
}
\examples{
time <- 0:10
ltvlms(time, K = 100, y0 = 2, r0 = 0.5, r1 = -0.02, nu = 1.2)
logistic_growth(time, K = 100, r = 0.5, y0 = 2)
}
