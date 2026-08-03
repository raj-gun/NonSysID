# `NonSysID_i`

`NonSysID_i` is a dedicated variant of NonSysID for identifying linear and nonlinear input-only models using the iterative Orthogonal Forward Regression (iOFR) algorithm and PRESS-statistic-based term selection.

Its candidate regressors are constructed exclusively from lagged inputs and their nonlinear combinations, without lagged output terms. Consequently, recursive model simulation does not depend on previously predicted outputs. For an input-only model, free-run model simulation, one-step-ahead prediction and k-step-ahead prediction are therefore identical.

By eliminating the repeated recursive simulation required for models containing lagged outputs, `NonSysID_i` can provide substantially faster system identification for input-only model structures.

---

## Signature

```matlab
[model, Mod_Val_dat, iOFR_table_lin, iOFR_table_nl, ...
 best_mod_ind_lin, best_mod_ind_nl, val_stats] = ...
    NonSysID_i(mod_type, u, y, ...
               a1, a2, b1, b2, ...
               nl_ord_max, is_bias, n_inpts, KSA_h, RCT, ...
               x_iOFR, stp_cri, D1_thresh, displ, sim, parall);
```

---

## Parameters

| Name         | Type            | Required | Description                                                                                                                                                           |
| ------------ | --------------- | -------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `mod_type`   | `char`          | Yes      | Model type. This must be set to `'ARX-i'`.                                                                                                                            |
| `u`          | `vector/matrix` | Yes      | Input signal or signals used for identification. Each column represents one input, and the number of columns must equal `n_inpts`.                                    |
| `y`          | `vector`        | Yes      | Measured output signal used as the dependent variable during identification.                                                                                          |
| `a1`         | `int`           | Yes      | Retained for call compatibility with `NonSysID`. It is not used to construct the input-only candidate dictionary.                                                          |
| `a2`         | `int`           | Yes      | Retained for call compatibility with `NonSysID`. It is not used to construct the input-only candidate dictionary.                                                          |
| `b1`         | `int`           | Yes      | Minimum input lag included in the candidate dictionary.                                                                                                               |
| `b2`         | `int`           | Yes      | Maximum input lag included in the candidate dictionary.                                                                                                               |
| `nl_ord_max` | `int`           | Yes      | Maximum polynomial nonlinearity order. Set to `1` for a linear model dictionary or greater than `1` to include nonlinear input terms.                                 |
| `is_bias`    | `int` (`0`/`1`) | Yes      | Bias-term option: `0 = exclude bias`, `1 = include bias`.                                                                                                             |
| `n_inpts`    | `int`           | Yes      | Number of measured input signals. This must equal `size(u,2)`.                                                                                                        |
| `KSA_h`      | `int`           | Yes      | Nominal k-step-ahead prediction horizon. It is retained for interface compatibility but does not affect input-only model predictions because all prediction modes are identical. |
| `RCT`        | `int` (`0`–`4`) | Yes      | Reduced Computational Time method: `0 = none`; `1`–`4` select the corresponding RCT method.                                                                           |
| `x_iOFR`     | `logical[2]`    | Yes      | Enables multiple iOFR iterations. `x_iOFR(1)` applies to linear identification and `x_iOFR(2)` applies to nonlinear identification.                                   |
| `stp_cri`    | `cell{2}`       | Yes      | Stopping criteria for linear and nonlinear identification, such as `'PRESS_thresh'` or `'BIC_thresh'`.                                                                |
| `D1_thresh`  | `double[2]`     | Yes      | Threshold values associated with the selected stopping criteria. The first value applies to the linear model and the second to the nonlinear model.                   |
| `displ`      | `int` (`0`/`1`) | Yes      | Display option for candidate-model information: `1 = display candidate models`, `0 = display only the final result.                                                   |
| `sim`        | `int[2]`        | Yes      | Prediction and display options. `sim(1) = 1` evaluates the selected model; `sim(2) = 1` displays prediction plots and error statistics.                               |
| `parall`     | `int[2]`        | Yes      | Parallel-processing options for linear and nonlinear identification. Each element must be either `0` or `1`.                                                          |

---

## Returns

| Output             | Type            | Description                                                                                                                               |
| ------------------ | --------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| `model`            | `cell`          | Identified input-only model, including lag settings, selected terms, estimated parameters, bias, error statistics and model-selection results. |
| `Mod_Val_dat`      | `struct/cell`   | Model-validation and candidate-model information generated during the iOFR procedure.                                                     |
| `iOFR_table_lin`   | `table/cell`    | iOFR results for candidate linear input-only models.                                                                                           |
| `iOFR_table_nl`    | `table/cell`    | iOFR results for candidate nonlinear input-only models.                                                                                        |
| `best_mod_ind_lin` | `int`           | Index of the selected linear model.                                                                                                       |
| `best_mod_ind_nl`  | `int`           | Index of the selected nonlinear model.                                                                                                    |
| `val_stats`        | `struct` or `0` | Validation statistics for the selected nonlinear model. Returns `0` when no nonlinear model is selected.                                  |

---

## Input-only Model Structure

An input-only model represents the output using only present or lagged input information:

[
y(t) = F\left(
u_1(t-b_1),\ldots,u_1(t-b_2),
\ldots,
u_m(t-b_1),\ldots,u_m(t-b_2)
\right) + e(t),
]

where:

* (m) is the number of inputs;
* (F(\cdot)) may be linear or polynomially nonlinear;
* no lagged output terms such as (y(t-1)) are included; and
* (e(t)) represents the model residual.

For nonlinear models, the candidate dictionary may include powers and cross-products of lagged inputs, for example:

```text
u1(t-1)^2
u1(t-1)u2(t-2)
u1(t-2)^2u2(t-1)
```

---

## Prediction Equivalence

Conventional ARX and NARX model simulation may recursively use previously predicted outputs. In contrast, an input-only model contains no output-feedback regressors.

The prediction horizon supplied through `KSA_h` does not change the predicted output of an input-only model.

This equivalence also avoids repeated recursive simulations during model evaluation, which reduces the computational cost of input-only system identification.

---

## Algorithm—High Level

1. **Input-lag matrix construction**
   Constructs candidate linear regressors from each measured input over the lag interval `b1:b2`.

2. **Nonlinear dictionary generation**
   When `nl_ord_max > 1`, generates polynomial powers and interactions from the linear input regressors.

3. **Orthogonal Forward Regression**
   Applies OFR to rank and select candidate model terms according to their contribution.

4. **PRESS-based model evaluation**
   Uses the Prediction Error Sum of Squares statistic to assess model generalisation without requiring a separate validation dataset.

5. **Iterative OFR**
   Optionally repeats OFR from different initial terms to reduce sensitivity to the orthogonalisation path.

6. **Model selection**
   Selects the preferred linear or nonlinear input-only model using the configured stopping criterion and threshold.

7. **Direct prediction**
   Evaluates the selected model directly from its input regressors. No recursive output simulation is required.

For more information about the underlying NonSysID algorithms, refer to the [`supplementary information`](/supplimentray_information/README.md).

---

## Example Usage

```matlab
% Generate example identification data
N = 1000;

u1 = randn(N,1);
u2 = randn(N,1);
u = [u1,u2];

% Example nonlinear input-only system
y = 0.7*[0;u1(1:end-1)] ...
    - 0.4*[0;0;u2(1:end-2)] ...
    + 0.3*[0;u1(1:end-1)].*[0;0;u2(1:end-2)] ...
    + 0.02*randn(N,1);

% Configure the model
mod_type = 'ARX-i';

% Retained for compatibility with NonSysID; not used by NonSysID-i
a1 = 1;
a2 = 1;

% Candidate input lags
b1 = 1;
b2 = 3;

% Maximum polynomial degree
nl_ord_max = 2;

% Include a bias term
is_bias = 1;

% Number of input signals
n_inpts = size(u,2);

% Retained prediction horizon
KSA_h = 20;

% Reduced Computational Time method
RCT = 4;

% Run iterative OFR for linear and nonlinear models
x_iOFR = [true,true];

% Model-selection stopping criteria
stp_cri = {'PRESS_thresh','PRESS_thresh'};
D1_thresh = [1e-10,10^0.9];

% Display only the final model
displ = 0;

% Evaluate the model and display prediction plots
sim = [1,1];

% Enable parallel processing
parall = [1,1];

% Run NonSysID-i
[model, Mod_Val_dat, iOFR_table_lin, iOFR_table_nl, ...
 best_mod_ind_lin, best_mod_ind_nl, val_stats] = ...
    NonSysID_i(mod_type, u, y, ...
               a1, a2, b1, b2, ...
               nl_ord_max, is_bias, n_inpts, KSA_h, RCT, ...
               x_iOFR, stp_cri, D1_thresh, displ, sim, parall);
```

---

## Evaluating an Identified Model

Use `model_simulation_i` to evaluate an identified input-only model on identification or test data:

```matlab
k = 20;

[sse, y_hat, error, U_delay_mat] = ...
    model_simulation_i(model, u, y, k);
```

For input-only models:

```matlab
y_hat(:,1)   % Free-run model simulation
y_hat(:,2)   % One-step-ahead prediction
y_hat(:,3)   % k-step-ahead prediction
```

All three columns contain the same predicted output.

The returned error statistics are:

```matlab
sse(1)   % Mean-squared simulation error
sse(2)   % Mean-squared one-step prediction error
sse(3)   % Mean-squared k-step prediction error
```

These values are also identical for an input-only model.

---

## Notes

* Only `'ARX-i'` is accepted as `mod_type`.
* At least one measured input is required.
* `n_inpts` must equal the number of columns in `u`.
* `a1` and `a2` are retained solely for compatibility with the established `NonSysID` calling convention.
* `nl_ord_max = 1` restricts the candidate dictionary to linear input terms.
* `nl_ord_max > 1` permits polynomial powers and cross-input nonlinear terms.
* The candidate dictionary never includes lagged output terms.
* `KSA_h` does not affect the input-only model predictions because one-step, k-step and free-run outputs are equivalent.
* Parallel processing can reduce identification time for large candidate dictionaries.
* For small problems, parallel-pool startup overhead may outweigh the computational benefit.
* The same input-lag range `b1:b2` is currently applied to every input.

