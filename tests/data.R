library(ltvlms)

data(south_africa_hiv)
data(hiv_prevalence_63)

stopifnot(
  nrow(south_africa_hiv) == 34L,
  identical(range(south_africa_hiv$year), c(1990L, 2023L)),
  all(south_africa_hiv$prevalence > 0),
  nrow(hiv_prevalence_63) == 2142L,
  length(unique(hiv_prevalence_63$code)) == 63L,
  !anyNA(hiv_prevalence_63$prevalence)
)
