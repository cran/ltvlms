# Reproducing the South Africa analysis

## Authoritative specification

This package treats the published article, *Linear Time-Varying Logistic Model
With Shape Parameter for Dynamic Epidemic Modeling*, as the scientific
specification. The LTVLMS implementation follows equations (6)-(8):

```text
r(t) = r0 + r1 * t

y(t) = K / [1 + ((K^nu - y0^nu) / y0^nu) *
             exp(-nu * (r0*t + 0.5*r1*t^2))]^(1/nu)
```

Earlier analysis scripts are not treated as the release specification.

## Data

```r
library(ltvlms)
data(south_africa_hiv)
years <- south_africa_hiv$year
prevalence <- south_africa_hiv$prevalence
```

The 34 values are the UNAIDS adult prevalence estimates used in the manuscript.

## Fit the four models

```r
comparison <- compare_growth_models(
  years,
  prevalence,
  models = c("logistic", "gompertz", "richards", "ltvlms"),
  n_starts = 50,
  seed = 42,
  convention = "paper"
)
comparison
```

The optional `paper` convention reports constant-free least-squares criteria:

```text
AIC  = n * log(MSE) + 2k
BIC  = n * log(MSE) + k * log(n)
AICc = AIC + 2k(k + 1) / (n - k - 1)
```

The same formula is applied consistently to every model. For normal package
use, omit `convention = "paper"` to obtain Gaussian likelihood criteria that
include the residual-variance parameter.

## LTVLMS case-study fit

```r
fit <- fit_growth_model(
  years,
  prevalence,
  model = "ltvlms",
  n_starts = 50,
  seed = 42
)
coef(fit)
metrics(fit, convention = "paper")
plot(fit, xlab = "Year", ylab = "HIV prevalence (%)")
```

The default bounded fit produces approximately:

| Quantity | Package result | Manuscript Table 3 |
|---|---:|---:|
| K | 22.59496 | 22.594967 |
| r0 | 1.71122 | 1.711236 |
| r1 | -0.068428 | -0.068428 |
| nu | 0.126492 | 0.126491 |

The manuscript says parameters are fitted within predefined bounds but does not
list their numerical values. The package transparently uses `r0` bounds of
0.0001 to 3: this bounded interval includes the manuscript estimate and the
South Africa optimum does not reach either boundary. Users can override every
bound explicitly through `fit_growth_model()`.

## Recalculated fit measures

Evaluating the latest manuscript's Table 3 parameter values against the 34
included observations gives approximately RMSE 0.148486 and R-squared 0.999188.
These differ from the LTVLMS values RMSE 0.153089 and R-squared 0.999137 printed
in Table 2. This indicates that Tables 2 and 3 reflect different fitted parameter
sets or analysis revisions. The package regression test follows the latest
Table 3 parameter set and calculates all metrics directly from that fit.

Table 2's AIC entries are also not produced by one common parameter-count rule,
and its LTVLMS value under the `Adjusted AIC` heading corresponds to a different
criterion in the earlier calculations. The package does not hard-code those
table entries. It applies the selected metric definition consistently to all
models and makes the convention explicit in the output.

## Cross-validation

```r
random_cv <- cross_validate_growth(
  years, prevalence, model = "ltvlms",
  method = "random", folds = 5, n_starts = 20, seed = 42
)
random_cv

forward_cv <- cross_validate_growth(
  years, prevalence, model = "ltvlms",
  method = "forward", folds = 5, n_starts = 20, seed = 42
)
forward_cv
```

The manuscript describes shuffled five-fold validation. The package implements
that method without using information outside each training fold. Forward
validation is additionally available because it tests later observations using
models trained only on earlier observations.

## Cross-country data

```r
data(hiv_prevalence_63)
countries <- unique(hiv_prevalence_63$country)
length(countries)

example <- subset(hiv_prevalence_63, code == "ZAF")
fit_growth_model(example$year, example$prevalence, model = "ltvlms")
```
