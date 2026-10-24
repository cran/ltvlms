# Getting started with ltvlms

This guide assumes no previous experience with R packages.

## 1. R and RStudio

R is the language that performs the calculations. RStudio is the application
used to write R code, view data, draw plots, and develop packages.

Commands are entered in the **Console**. A script is a saved text file containing
commands that can be run again later.

## 2. Load the package

After installation, run:

```r
library(ltvlms)
```

`library()` makes the package's exported functions available in the current R
session.

## 3. Examine the example data

```r
data(south_africa_hiv)
head(south_africa_hiv)
str(south_africa_hiv)
```

The columns are:

- `year`: calendar year;
- `code`: country code;
- `country`: country name;
- `prevalence`: estimated percentage of adults aged 15-49 living with HIV.

The `$` operator selects one column:

```r
south_africa_hiv$year
south_africa_hiv$prevalence
```

## 4. Evaluate a curve with known parameters

```r
time <- 0:10
values <- ltvlms(
  t = time,
  K = 25,
  y0 = 1.7,
  r0 = 0.8,
  r1 = -0.03,
  nu = 0.5
)
values
```

Here `<-` assigns a result to a name, `0:10` creates the integers zero through
ten, and `ltvlms()` returns one prediction per time value.

## 5. Estimate parameters from observations

```r
fit <- fit_growth_model(
  time = south_africa_hiv$year,
  response = south_africa_hiv$prevalence,
  model = "ltvlms",
  n_starts = 50,
  seed = 42
)
fit
```

The package tries 50 dispersed starting values because nonlinear optimization
can otherwise stop at a poor local solution. `seed = 42` makes those starting
values reproducible.

The printed result reports how many starts converged. It also reports any
coefficient at an allowed boundary. A boundary estimate is a reason to examine
the bounds; it is not automatically proof that the fit is invalid.

## 6. Inspect the fit

```r
coef(fit)
fitted(fit)
residuals(fit)
metrics(fit)
```

- `coef()` returns estimated parameters.
- `fitted()` returns predictions for the observations used to fit the model.
- `residuals()` returns observed minus predicted values.
- `metrics()` returns accuracy and information criteria.

Lower RMSE is better. Higher R-squared indicates a closer historical fit. AIC,
BIC, and AICc compare models fitted to exactly the same response observations;
lower values are preferred within that comparison.

## 7. Plot and predict

```r
plot(fit, xlab = "Year", ylab = "HIV prevalence (%)")
predict(fit, newdata = 2024:2026)
```

Predictions beyond the observed years are extrapolations. A close historical fit
does not guarantee reliable long-term forecasts.

## 8. Compare models

```r
comparison <- compare_growth_models(
  south_africa_hiv$year,
  south_africa_hiv$prevalence,
  n_starts = 50,
  seed = 42
)
comparison
plot(comparison)
```

This applies the same fitting and metric workflow to all requested models. The
returned object contains `comparison$fits`, `comparison$metrics`, and any
recorded `comparison$failures`.

## 9. Validate honestly

```r
random_cv <- cross_validate_growth(
  south_africa_hiv$year,
  south_africa_hiv$prevalence,
  model = "ltvlms",
  method = "random",
  seed = 42
)

forward_cv <- cross_validate_growth(
  south_africa_hiv$year,
  south_africa_hiv$prevalence,
  model = "ltvlms",
  method = "forward",
  seed = 42
)

random_cv
forward_cv
```

Random validation asks whether the curve can fill gaps among years it has seen
on both sides. Forward validation asks whether earlier years can predict later
years. Use forward validation when forecasting is the goal.

## 10. Use your own data

Your data need at least two numeric columns:

```r
my_data <- data.frame(
  year = 2000:2010,
  value = c(1.0, 1.3, 1.8, 2.5, 3.5, 4.8, 6.1, 7.0, 7.6, 7.9, 8.0)
)

my_fit <- fit_growth_model(my_data$year, my_data$value, model = "ltvlms")
```

Responses must currently be positive and complete. Remove or investigate missing
values before fitting; the package does not silently discard them.

## 11. Ask R for help

```r
?fit_growth_model
?compare_growth_models
?cross_validate_growth
?south_africa_hiv
```
