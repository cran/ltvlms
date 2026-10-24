\name{hiv_prevalence_63}
\alias{hiv_prevalence_63}
\docType{data}
\title{Adult HIV Prevalence Estimates for 63 Countries and Regions}
\format{
A data frame with 2,142 rows and 4 variables:
\describe{
  \item{year}{Calendar year from 1990 through 2023.}
  \item{code}{UNAIDS country or region code.}
  \item{country}{Country or region name.}
  \item{prevalence}{Estimated HIV prevalence percentage among adults aged 15-49.}
}
}
\source{
UNAIDS 2024, \emph{HIV estimates with uncertainty bounds, 1990-2023}, as
distributed with the manuscript authors' public analysis repository. Official
UNAIDS dataset portal: \url{https://aidsinfo.unaids.org/dataset}.
}
\description{
Complete prevalence series used by the manuscript's cross-country comparison.
The data contain 34 annual observations for each of 63 countries or regions.
}
\note{
These UNAIDS-derived data are not covered by the package's MIT software
license. Their use remains subject to the UNAIDS terms at
\url{https://www.unaids.org/en/terms-of-use}.
}
\usage{data(hiv_prevalence_63)}
