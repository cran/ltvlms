# Methodological notes

## Parameter meaning

- `K`: carrying-capacity scale.
- `y0`: response at the time origin for Logistic and LTVLMS curves.
- `r`: constant rate for Logistic, Gompertz, and Richards curves.
- `r0`: initial LTVLMS growth pressure.
- `r1`: linear change in LTVLMS growth pressure.
- `nu`: positive shape parameter.
- `alpha`: positive Richards scale parameter.
- `t0`: Gompertz or Richards location parameter.

`K` is a mathematical parameter and should not automatically be interpreted as
a known biological maximum. Parameters describe the fitted curve; they do not
by themselves establish causes.

## Time origin

`fit_growth_model()` sorts observations and subtracts the earliest supplied
time. If years 1990-2023 are supplied, the internal times are 0-33. Predictions
still accept calendar years because the fitted object retains the origin.

## Optimization

Latin hypercube sampling provides dispersed starting points. Every point starts
a bounded PORT optimization through R's `nlminb()` function. Only finite,
converged solutions compete for
selection. The result retains the number of converged starts and any coefficients
at their bounds.

Multiple parameter vectors may give very similar curves. A single best fit does
not prove that all parameters are well identified. Sensitivity to bounds and
uncertainty estimation should be examined before strong parameter interpretation.

Default bounds are data-informed and aligned with the parameter scale reported
in the latest manuscript: `K` ranges from one half to twice the observed maximum
(while remaining above `y0` where required), positive constant rates range from
0.0001 to 1, `r0` ranges from 0.0001 to 3, `r1` ranges from -1 to 0, `alpha`
from 0.001 to 10, and `nu` from 0.01 to 10. The manuscript does not print the
numerical fitting bounds, so the package states its implementation choices
explicitly. Every bound can be overridden in `fit_growth_model()`.

## Numerical stability

The package evaluates denominators on the logarithmic scale and clips relevant
exponents conservatively. This avoids common overflow and underflow failures but
does not make scientifically implausible parameter ranges appropriate.

## Metrics

RMSE and R-squared describe historical fit. Standard AIC, BIC, and AICc use a
Gaussian residual likelihood and include residual variance as an estimated
parameter. The optional `paper` convention provides constant-free
least-squares criteria for manuscript-comparison reporting.

Information criteria compare models fitted to the same response observations.
Their absolute values are not meaningful across different datasets or different
formula conventions.

## Cross-validation

Random folds test interpolation. Forward folds test later observations using
models trained only on earlier observations. Neither method supplies prediction
intervals, and neither proves causal effects of treatments or interventions.

## Scope

Version 0.1.0 provides deterministic curve fitting and validation. It does not
yet claim formal parameter uncertainty, causal inference, or guaranteed long-term
forecast accuracy.
