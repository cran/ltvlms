\name{growth_fit-methods}
\alias{coef.growth_fit}
\alias{fitted.growth_fit}
\alias{residuals.growth_fit}
\alias{predict.growth_fit}
\alias{print.growth_fit}
\alias{plot.growth_fit}
\title{Methods for Fitted Growth Models}
\usage{
\method{coef}{growth_fit}(object, ...)
\method{fitted}{growth_fit}(object, ...)
\method{residuals}{growth_fit}(object, ...)
\method{predict}{growth_fit}(object, newdata = NULL, ...)
\method{print}{growth_fit}(x, ...)
\method{plot}{growth_fit}(x, ..., xlab = "Time", ylab = "Response")
}
\arguments{
  \item{object, x}{A \code{growth_fit} object.}
  \item{newdata}{Optional numeric vector of new time values.}
  \item{xlab, ylab}{Plot axis labels.}
  \item{...}{Additional arguments, including graphical parameters for plotting.}
}
\description{
Extract coefficients, fitted values, and residuals; predict, print, or plot a
fitted growth model.
}
\value{
The return value depends on the method:
\itemize{
  \item \code{coef} returns a named numeric vector containing the estimated
  model parameters.
  \item \code{fitted} returns a numeric vector of fitted responses at the
  observed time values.
  \item \code{residuals} returns a numeric vector of observed responses minus
  their fitted values.
  \item \code{predict} returns a numeric vector of fitted responses when
  \code{newdata} is \code{NULL}, or predictions at the supplied time values
  otherwise.
  \item \code{print} invisibly returns the original \code{growth_fit} object
  after displaying a summary of the fit.
  \item \code{plot} invisibly returns the original \code{growth_fit} object
  after drawing the observations and fitted curve.
}
}
