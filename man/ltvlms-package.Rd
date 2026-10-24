\name{ltvlms-package}
\alias{ltvlms-package}
\docType{package}
\title{Linear Time-Variant Logistic Models with a Shape Parameter}
\description{
Tools to evaluate, fit, compare, and validate Logistic, Gompertz, Richards, and
Linear Time-Variant Logistic Models with a Shape Parameter. Fitting uses bounded
multi-start optimization initialized by Latin hypercube sampling.
}
\details{
Start with \code{fit_growth_model()} for a single model or
\code{compare_growth_models()} for all four models. Use
\code{cross_validate_growth()} to distinguish random interpolation assessment
from forward-in-time forecasting assessment.
}
