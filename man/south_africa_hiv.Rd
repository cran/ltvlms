\name{south_africa_hiv}
\alias{south_africa_hiv}
\docType{data}
\title{South Africa Adult HIV Prevalence Estimates, 1990-2023}
\format{
A data frame with 34 rows and 4 variables:
\describe{
  \item{year}{Calendar year.}
  \item{code}{UNAIDS country code, \code{"ZAF"}.}
  \item{country}{Country name.}
  \item{prevalence}{Estimated HIV prevalence percentage among adults aged 15-49.}
}
}
\source{
UNAIDS 2024, \emph{HIV estimates with uncertainty bounds, 1990-2023}, as
distributed with the manuscript authors' public analysis repository. Official
UNAIDS dataset portal: \url{https://aidsinfo.unaids.org/dataset}.
}
\description{
Annual national HIV prevalence estimates used for the manuscript's South
Africa case study. These are modeled UNAIDS estimates, not raw diagnosis counts.
}
\note{
These UNAIDS-derived data are not covered by the package's MIT software
license. Their use remains subject to the UNAIDS terms at
\url{https://www.unaids.org/en/terms-of-use}.
}
\usage{data(south_africa_hiv)}
