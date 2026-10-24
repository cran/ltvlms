# ltvlms

`ltvlms` is an R package for evaluating, fitting, comparing, and validating four
nonlinear growth curves:

- Logistic
- Gompertz
- Richards
- Linear Time-Variant Logistic Model with Shape Parameter (LTVLMS)

The package accompanies the article *Linear Time-Varying Logistic Model With
Shape Parameter for Dynamic Epidemic Modeling* by Redouane Betrouni and Tewfik
Kernane ([doi:10.1155/jama/4928447](https://doi.org/10.1155/jama/4928447)).
Bander Hussein is the third package author and package maintainer.

## What the proposed model changes

An ordinary logistic curve uses one constant growth rate. LTVLMS instead uses

```text
r(t) = r0 + r1 * t
```

and adds a positive shape parameter `nu`. This permits asymmetric trajectories
and, when `r1` is negative, a transition from increasing to decreasing growth
pressure.

## Installation

The initial CRAN release is under review. For the reviewed source archive, run:

```r
install.packages(file.choose(), repos = NULL, type = "source")
library(ltvlms)
```

Select `ltvlms_0.1.0.tar.gz` when prompted. After the package is available on
CRAN, installation will use:

```r
install.packages("ltvlms")
```

When this repository is public, the development version can be installed with:

```r
install.packages("remotes")
remotes::install_github("bshussein/ltvlms")
```

## First analysis

```r
library(ltvlms)
data(south_africa_hiv)

fit <- fit_growth_model(
  time = south_africa_hiv$year,
  response = south_africa_hiv$prevalence,
  model = "ltvlms",
  n_starts = 50,
  seed = 42
)

fit
coef(fit)
metrics(fit)
plot(fit, xlab = "Year", ylab = "HIV prevalence (%)")
predict(fit, newdata = 2024:2026)
```

## Compare all four models

```r
comparison <- compare_growth_models(
  south_africa_hiv$year,
  south_africa_hiv$prevalence,
  n_starts = 50,
  seed = 42
)

comparison
plot(comparison, xlab = "Year", ylab = "HIV prevalence (%)")
```

## Cross-validation

Random folds evaluate interpolation among observed years:

```r
cross_validate_growth(
  south_africa_hiv$year,
  south_africa_hiv$prevalence,
  model = "ltvlms",
  method = "random"
)
```

Forward folds evaluate prediction of later years from earlier years:

```r
cross_validate_growth(
  south_africa_hiv$year,
  south_africa_hiv$prevalence,
  model = "ltvlms",
  method = "forward"
)
```

These answer different questions and should not be treated as interchangeable.

## Included data

- `south_africa_hiv`: 34 annual South Africa observations, 1990-2023.
- `hiv_prevalence_63`: 2,142 observations for 63 countries and regions.

The prevalence values are UNAIDS estimates for adults aged 15-49, not raw
diagnosis counts. The package's MIT license covers the software, not the
UNAIDS-derived data. The data source and applicable UNAIDS terms are recorded
in `inst/COPYRIGHTS` and the dataset documentation.

## Reproducibility and safeguards

- Model functions do not depend on hidden global variables.
- Exponential calculations use stable log-scale forms and conservative clipping.
- Parameter bounds, successful starts, and boundary estimates are retained.
- Failed model comparisons and cross-validation folds remain visible.
- Seeds are explicit and do not permanently alter the user's random-number state.
- Standard information criteria and manuscript-compatible formulas are labeled
  separately.

The current implementation follows the published equation and its reported
South Africa parameter scale. The article is the authoritative scientific
source for this release; earlier analysis scripts are not treated as the release
specification. See the reproduction guide below for verified results and
transparent notes about the article tables.

## Guides

- [Getting started](inst/doc/getting-started.md): beginner tutorial
- [Reproducing the paper](inst/doc/reproducing-the-paper.md): South Africa
  reproduction
- [Methodological notes](inst/doc/methodological-notes.md): assumptions,
  validation, and limitations

## Citation

Run the following command for the package and article citations:

```r
citation("ltvlms")
```

## License

MIT License.
