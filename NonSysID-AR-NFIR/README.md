# `NonSysID_AR_NFIR`

`NonSysID_AR_NFIR` is a dedicated variant of NonSysID for identifying AR-NFIR NARX models using the iterative Orthogonal Forward Regression (iOFR) algorithm and PRESS-statistic-based term selection.

An AR-NFIR NARX model is composed of two additive parts: a linear or nonlinear auto-regressive (AR) part, formed only from lagged outputs, and a linear or nonlinear finite impulse response (NFIR) part, formed only from lagged inputs. There are no nonlinear cross-terms between the lagged outputs and the lagged inputs, such as $`y(t-1)u(t-1)`$. Each part has its own maximum polynomial order of nonlinearity.

The cross-terms are removed from the candidate dictionary before any term selection takes place. The iOFR, PRESS-statistic, simulation-based model selection and model simulation procedures of `NonSysID` are therefore used unchanged, but operate on a smaller candidate dictionary that contains only the admissible AR-NFIR terms.

---

## Signature

```matlab
[model, Mod_Val_dat, iOFR_table_lin, iOFR_table_nl, ...
 best_mod_ind_lin, best_mod_ind_nl, val_stats] = ...
    NonSysID_AR_NFIR(mod_type, u, y, ...
                     a1, a2, b1, b2, ...
                     nl_ord_AR, nl_ord_NFIR, is_bias, n_inpts, KSA_h, RCT, ...
                     x_iOFR, stp_cri, D1_thresh, displ, sim, parall);
```

The signature is that of `NonSysID`, with `nl_ord_max` replaced by `nl_ord_AR` and `nl_ord_NFIR`.

---

## Functions in NonSysID-AR-NFIR

`NonSysID-AR-NFIR` contains two new functions, which form and prune the AR-NFIR candidate dictionary, and four functions adapted from `NonSysID`. The adapted functions differ from their `NonSysID` originals only in their names, the two additional polynomial-order inputs, and the calls to the other `_AR_NFIR` functions.

| Function                          | Origin                          | Purpose in NonSysID-AR-NFIR                                                                                                                              |
| --------------------------------- | ------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `NonSysID_AR_NFIR.m`              | Adapted from `NonSysID.m`        | Main function. Accepts `nl_ord_AR` and `nl_ord_NFIR`, and sets `nl_ord_max = max(nl_ord_AR,nl_ord_NFIR)` for the full candidate dictionary.              |
| `Sys_ID_iOFRs_PRESS_AR_NFIR.m`    | Adapted from `Sys_ID_iOFRs_PRESS.m` | Runs the linear and nonlinear iOFR procedures, passing the two polynomial orders to `RCT_sel_AR_NFIR`.                                               |
| `RCT_sel_AR_NFIR.m`               | Adapted from `RCT_sel.m`         | Constructs the AR-NFIR nonlinear candidate dictionary and applies the selected Reduced Computational Time procedure.                                     |
| `OFR_RCT_AR_NFIR.m`               | Adapted from `OFR_RCT.m`         | Produces the overfitting AR-NFIR model used to define the reduced candidate dictionary for `RCT = 2`, `3`, or `4`.                                        |
| `generate_nl_reg_AR_NFIR.m`       | New                             | Wraps `generate_nl_reg`, generating the full NARX candidate dictionary and then restricting it to the AR-NFIR model class.                               |
| `rm_crs_trms_AR_NFIR.m`           | New                             | Removes the cross-terms between lagged outputs and lagged inputs, and the terms exceeding `nl_ord_AR` or `nl_ord_NFIR`, from the candidate dictionary. |

---

## Functions Reused from NonSysID

`NonSysID-AR-NFIR` also reuses the following functions from the original `NonSysID` implementation without modification.

Some of these functions are called directly by `NonSysID-AR-NFIR`, while others are indirect dependencies called by the reused `NonSysID` functions. For full standalone operation—including linear and nonlinear identification and all RCT options—the following files from the `NonSysID` folder must be available.

| Function from NonSysID              | Dependency                                | Used by                                                          | Purpose in NonSysID-AR-NFIR                                                                                                      |
| ----------------------------------- | ----------------------------------------- | ---------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| `info_mat_sysID.m`                  | Direct                                    | `NonSysID_AR_NFIR`                                               | Constructs the lagged input-output information matrix used for identification.                                                   |
| `iOFR_trm_char.m`                   | Direct                                    | `Sys_ID_iOFRs_PRESS_AR_NFIR`                                     | Constructs the linear candidate regressors and their term labels.                                                                |
| `iOFRs_lin_SysID.m`                 | Direct                                    | `Sys_ID_iOFRs_PRESS_AR_NFIR`                                     | Executes the iOFR procedure for the linear model.                                                                               |
| `iOFRs_lin_SysID_P.m`               | Direct; used when `parall(1) = 1`         | `Sys_ID_iOFRs_PRESS_AR_NFIR`                                     | Executes the iOFR procedure for the linear model using parallel processing.                                                     |
| `iOFRs_nl_SysID.m`                  | Direct                                    | `Sys_ID_iOFRs_PRESS_AR_NFIR`                                     | Executes the iOFR procedure for the nonlinear model on the AR-NFIR candidate dictionary.                                        |
| `iOFRs_nl_SysID_P.m`                | Direct; used when `parall(2) = 1`         | `Sys_ID_iOFRs_PRESS_AR_NFIR`                                     | Executes the iOFR procedure for the nonlinear model using parallel processing.                                                  |
| `generate_nl_reg.m`                 | Direct                                    | `generate_nl_reg_AR_NFIR`                                        | Generates the full set of polynomial nonlinear candidate regressors and their term labels, prior to the AR-NFIR restriction.    |
| `OLS_RCT.m`                         | Direct; used for `RCT = 2`, `3`, or `4`   | `OFR_RCT_AR_NFIR`                                                | Performs the forced OLS-ERR term selection used during the RCT preliminary model construction.                                   |
| `one_step_pred_model_reg.m`         | Direct                                    | `NonSysID_AR_NFIR`                                               | Evaluates the one-step-ahead prediction of the selected model.                                                                   |
| `k_step_pred_model_reg.m`           | Direct                                    | `NonSysID_AR_NFIR`, `OFR_lin`, `OFR_nl`                          | Evaluates the k-step-ahead prediction of a model.                                                                                |
| `sim_model_reg_2.m`                 | Direct                                    | `NonSysID_AR_NFIR`, `OFR_lin`, `OFR_nl`, `k_step_pred_model_reg` | Simulates a model recursively, rebuilding its nonlinear regressors from the selected linear terms.                               |
| `OFR_lin.m`                         | Indirect                                  | `iOFRs_lin_SysID`, `iOFRs_lin_SysID_P`                           | Performs orthogonal forward regression for a linear candidate model along a given orthogonalisation path.                       |
| `OFR_nl.m`                          | Indirect                                  | `iOFRs_nl_SysID`, `iOFRs_nl_SysID_P`                             | Performs orthogonal forward regression for a nonlinear candidate model along a given orthogonalisation path.                    |
| `OLS_orthogonalisation_PRESS_frc.m` | Indirect                                  | `OFR_lin`, `OFR_nl`                                              | Performs the core orthogonal forward regression calculations, PRESS-statistic updates, term selection, and parameter estimation. |
| `ac_cc_model_valid.m`               | Indirect                                  | `OFR_lin`                                                        | Performs correlation-based residual validation for candidate linear models.                                                      |
| `ac_cc_model_valid_nl.m`            | Indirect                                  | `OFR_nl`                                                         | Performs nonlinear correlation-based residual validation for candidate nonlinear models.                                         |
| `mod_val_stats.m`                   | Indirect                                  | `OFR_nl`                                                         | Summarises the nonlinear residual-validation results and produces the model-validation statistics.                               |
| `diff_eq_mat.m`                     | Indirect                                  | `info_mat_sysID`                                                 | Constructs the delayed input and output matrices.                                                                                |
| `nl_term_comb.m`                    | Indirect                                  | `generate_nl_reg`, `one_step_pred_model_reg`, `sim_model_reg_2`  | Generates the unique index combinations required for polynomial nonlinear terms.                                                 |
| `nl_reg_data_mat.m`                 | Indirect                                  | `generate_nl_reg`, `one_step_pred_model_reg`, `sim_model_reg_2`  | Constructs the numerical nonlinear-regressor columns from the selected linear regressors.                                        |
| `model_simulation.m`                | Model evaluation                          | User scripts                                                     | Simulates an identified AR-NFIR model and evaluates its one-step-ahead and k-step-ahead predictions.                             |

Therefore, when using `NonSysID-AR-NFIR`, `NonSysID` functions must be accessible from the MATLAB path. For example:

```matlab
addpath('path-to-NonSysID');
addpath('path-to-NonSysID-AR-NFIR');
```

Alternatively, to use `NonSysID-AR-NFIR` as a self-contained package, copy all the functions listed above from the `NonSysID` folder into the `NonSysID-AR-NFIR` folder. The functions adapted from `NonSysID` are given the `_AR_NFIR` suffix, so they do not shadow the `NonSysID` functions of the same origin on the MATLAB path.

---

## Parameters

| Name          | Type            | Required | Description                                                                                                                                                                   |
| ------------- | --------------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `mod_type`    | `char`          | Yes      | Model type. This should be set to `'ARX'`. With `'AR'`, there is no NFIR part, and the identified model is a (N)AR model with a maximum polynomial order of `nl_ord_AR`.        |
| `u`           | `vector/matrix` | Yes      | Input signal or signals used for identification. Each column represents one input, and the number of columns must equal `n_inpts`.                                          |
| `y`           | `vector`        | Yes      | Measured output signal used as the dependent variable during identification.                                                                                                |
| `a1`          | `int`           | Yes      | Minimum output lag included in the candidate dictionary.                                                                                                                    |
| `a2`          | `int`           | Yes      | Maximum output lag included in the candidate dictionary.                                                                                                                    |
| `b1`          | `int`           | Yes      | Minimum input lag included in the candidate dictionary.                                                                                                                     |
| `b2`          | `int`           | Yes      | Maximum input lag included in the candidate dictionary.                                                                                                                     |
| `nl_ord_AR`   | `int`           | Yes      | Maximum polynomial order of nonlinearity of the AR part, $`N_p^{AR}`$. Set to `1` for a linear AR part.                                                                      |
| `nl_ord_NFIR` | `int`           | Yes      | Maximum polynomial order of nonlinearity of the NFIR part, $`N_p^{NFIR}`$. Set to `1` for a linear FIR part.                                                                  |
| `is_bias`     | `int` (`0`/`1`) | Yes      | Bias-term option: `0 = exclude bias`, `1 = include bias`.                                                                                                                   |
| `n_inpts`     | `int`           | Yes      | Number of measured input signals. This must equal `size(u,2)`.                                                                                                              |
| `KSA_h`       | `int`           | Yes      | Horizon for the k-step-ahead prediction.                                                                                                                                    |
| `RCT`         | `int` (`0`–`4`) | Yes      | Reduced Computational Time method: `0 = none`; `1`–`4` select the corresponding RCT method. All RCT methods operate on the AR-NFIR candidate dictionary.                     |
| `x_iOFR`      | `logical[2]`    | Yes      | Enables multiple iOFR iterations. `x_iOFR(1)` applies to linear identification and `x_iOFR(2)` applies to nonlinear identification.                                         |
| `stp_cri`     | `cell{2}`       | Yes      | Stopping criteria for linear and nonlinear identification, such as `'PRESS_thresh'` or `'BIC_thresh'`.                                                                      |
| `D1_thresh`   | `double[2]`     | Yes      | Threshold values associated with the selected stopping criteria. The first value applies to the linear model and the second to the nonlinear model.                         |
| `displ`       | `int` (`0`/`1`) | Yes      | Display option for candidate-model information: `1 = display candidate models`, `0 = display only the final result`.                                                        |
| `sim`         | `int[2]`        | Yes      | Simulation and display options. `sim(1) = 1` simulates the selected model; `sim(2) = 1` displays simulation plots and error statistics.                                     |
| `parall`      | `int[2]`        | Yes      | Parallel-processing options for linear and nonlinear identification. Each element must be either `0` or `1`.                                                                |

---

## Returns

| Output             | Type            | Description                                                                                                                                                                                       |
| ------------------ | --------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `model`            | `cell`          | Identified AR-NFIR NARX model, including lag settings, selected terms, estimated parameters, bias, error statistics and model-selection results. Its structure is identical to a `NonSysID` model. |
| `Mod_Val_dat`      | `struct/cell`   | Model-validation and candidate-model information generated during the iOFR procedure.                                                                                                             |
| `iOFR_table_lin`   | `table/cell`    | iOFR results for candidate linear models.                                                                                                                                                         |
| `iOFR_table_nl`    | `table/cell`    | iOFR results for candidate nonlinear AR-NFIR models.                                                                                                                                              |
| `best_mod_ind_lin` | `int`           | Index of the selected linear model.                                                                                                                                                               |
| `best_mod_ind_nl`  | `int`           | Index of the selected nonlinear model.                                                                                                                                                            |
| `val_stats`        | `struct` or `0` | Validation statistics for the selected nonlinear model. Returns `0` when no nonlinear model is selected.                                                                                          |

---

## AR-NFIR NARX Model Structure

A general NARX model represents the current output as a function of lagged outputs and lagged inputs:

```math
y(t) = f^{N_p}\left(Y, U\right) + \xi(t),
```

where $`Y = \{y(t-a_1),\ldots,y(t-a_2)\}`$ are the output-lagged terms, $`U = \{u_1(t-b_1),\ldots,u_1(t-b_2),\ldots,u_{n_u}(t-b_1),\ldots,u_{n_u}(t-b_2)\}`$ are the input-lagged terms, $`n_u`$ is the number of input signals, $`f^{N_p}(\cdot)`$ is a polynomial function with a maximum polynomial degree $`N_p`$, and $`\xi(t)`$ is the model residual. The polynomial function $`f^{N_p}(\cdot)`$ contains linear and nonlinear combinations of both the output-lagged and the input-lagged terms.

An AR-NFIR NARX model separates the output-lagged and the input-lagged terms into two additive parts:

```math
y(t) = \hat{f}^{N_p^{AR}}\left(Y\right) + \overline{f}^{N_p^{NFIR}}\left(U\right) + \xi(t),
```

where $`\hat{f}^{N_p^{AR}}(\cdot)`$ is the (N)AR part, a polynomial function of the output-lagged terms only with a maximum polynomial degree $`N_p^{AR}`$ (`nl_ord_AR`), and $`\overline{f}^{N_p^{NFIR}}(\cdot)`$ is the NFIR part, a polynomial function of the input-lagged terms only with a maximum polynomial degree $`N_p^{NFIR}`$ (`nl_ord_NFIR`).

For a polynomial AR-NFIR NARX model, the model can be expressed as

```math
y(t) =
\sum_{m=1}^{M}
\theta_m \phi_m(t)
+
\xi(t),
```

where $`\theta_m`$ is the parameter associated with the model term $`\phi_m(t)`$, and $`M`$ is the number of selected model terms.

Each nonlinear $`\phi_m(t)`$ is formed either only from lagged outputs or only from lagged inputs. The candidate dictionary may therefore include terms such as

```math
y(t-1)^3, \ y(t-1)y(t-2), \ u_1(t-1)^2, \ u_1(t-1)u_2(t-2),
```

but never cross-terms between lagged outputs and lagged inputs, such as

```math
y(t-1)u_1(t-1), \ y(t-2)u_1(t-1)^2.
```

Cross-products between different inputs, such as $`u_1(t-1)u_2(t-2)`$, belong to the NFIR part and are retained.

An example AR-NFIR NARX model is

```math
y(t) =
0.2y(t-1)^3
-
0.5y(t-2)
+
u(t-1)
+
0.5u(t-2)
+
0.25u(t-1)u(t-2)
-
0.3u(t-1)^3
+
\xi(t).
```

Unlike an input-only model identified by `NonSysID-i`, an AR-NFIR model contains lagged outputs, so its free-run simulation, one-step-ahead prediction and k-step-ahead prediction differ.

---

## Removal of the Cross-Terms

The AR-NFIR candidate dictionary is formed in two steps by `generate_nl_reg_AR_NFIR`:

1. **Full candidate dictionary**: `generate_nl_reg` generates the full NARX candidate dictionary, up to a maximum polynomial order of `nl_ord_max = max(nl_ord_AR,nl_ord_NFIR)`.
2. **AR-NFIR restriction**: `rm_crs_trms_AR_NFIR` identifies each candidate term from its term identification string, e.g. `y1(t-1)u1(t-2)`, using the regular expressions `y\d+\(t-?\d+\)` and `u\d+\(t-?\d+\)` to count its output-lagged and input-lagged factors. A nonlinear term is removed if it
   * contains both output-lagged and input-lagged factors (a cross-term),
   * contains only output-lagged factors and has a degree greater than `nl_ord_AR`, or
   * contains only input-lagged factors and has a degree greater than `nl_ord_NFIR`.

Linear terms are always retained.

The term indices of the retained nonlinear terms keep their original values. These indices refer to the full candidate dictionary, which `sim_model_reg_2`, `one_step_pred_model_reg` and `k_step_pred_model_reg` rebuild from the selected linear terms whenever a model is simulated. Preserving them is what allows the unchanged `NonSysID` simulation functions to simulate AR-NFIR models correctly.

For example, with two output lags, two input lags and `nl_ord_AR = nl_ord_NFIR = 3`, the candidate dictionary is reduced from 34 terms to 18 terms.

---

## Algorithm—High Level

1. **Lagged-term construction**: Constructs candidate linear regressors from the specified output and input lags.
2. **Linear model identification**: Identifies the linear ARX model with iOFR, as in `NonSysID`.
3. **AR-NFIR candidate dictionary**: Generates the nonlinear candidate dictionary and removes the cross-terms, and the terms exceeding the polynomial order of their part.
4. **Orthogonal Forward Regression (OFR)**: Iteratively adds terms from the AR-NFIR candidate dictionary, evaluating their contribution at each step.
5. **Stopping criteria**: Uses PRESS (Prediction Error Sum of Squares) or BIC (Bayesian Information Criterion), with thresholds in `D1_thresh`.
6. **Iteration control**: Optional multiple iOFR iterations until convergence (`x_iOFR`).
7. **Simulation-based model selection**: Selects among the candidate models using their free-run simulation, ensuring simulation stability and enhancing long-term prediction accuracy.
8. **Performance enhancements**: RCT acceleration and parallelisation options.

For more information about the underlying NonSysID algorithms, refer to the [`supplementary information`](/supplementary_information/README.md).

---

## Example Usage

```matlab
% Generate example identification data
n = 1000;

rng(200);
u = 0.6 .* (2.*rand(n,1) - 1); % u(t) ~ U(-0.6,0.6), keeps the model stable

% Example AR-NFIR NARX system
y = zeros(n,1);
for k = 3:n
    y(k) = 0.2*y(k-1)^3 - 0.5*y(k-2) ... % NAR part
        + u(k-1) + 0.5*u(k-2) + 0.25*u(k-1)*u(k-2) - 0.3*u(k-1)^3; % NFIR part
end

% Identification data
tt_splt = 1:100;
u_ID = u(tt_splt);
y_ID = y(tt_splt);

% Configure the model
mod_type = 'ARX';

% Candidate output lags
a1 = 1;
a2 = 2;

% Candidate input lags
b1 = 1;
b2 = 2;

% Maximum polynomial degree of the NAR and NFIR parts
nl_ord_AR = 3;
nl_ord_NFIR = 3;

% Exclude a bias term
is_bias = 0;

% Number of input signals
n_inpts = size(u,2);

% Prediction horizon
KSA_h = 20;

% Reduced Computational Time method
RCT = 0;

% Run a single iOFR iteration for linear and nonlinear models
x_iOFR = [false,false];

% Model-selection stopping criteria
stp_cri = {'PRESS_thresh','PRESS_thresh'};
D1_thresh = [1e-4,10^(-7)];

% Display only the final model
displ = 0;

% Simulate the model and display the results
sim = [1,1];

% Disable parallel processing
parall = [0,0];

% Run NonSysID-AR-NFIR
[model, Mod_Val_dat, iOFR_table_lin, iOFR_table_nl, ...
 best_mod_ind_lin, best_mod_ind_nl, val_stats] = ...
    NonSysID_AR_NFIR(mod_type, u_ID, y_ID, ...
                     a1, a2, b1, b2, ...
                     nl_ord_AR, nl_ord_NFIR, is_bias, n_inpts, KSA_h, RCT, ...
                     x_iOFR, stp_cri, D1_thresh, displ, sim, parall);
```

---

## Evaluating an Identified Model

An AR-NFIR model is returned in the same format as a `NonSysID` model, so it is evaluated with `model_simulation` from `NonSysID`:

```matlab
[sse, y_hat, error, U_delay_mat_sim] = ...
    model_simulation(model, u, y, KSA_h);
```

The outputs are:

```matlab
y_hat(:,1)   % Free-run model simulation
y_hat(:,2)   % One-step-ahead prediction
y_hat(:,3)   % k-step-ahead prediction
```

and the returned error statistics are:

```matlab
sse(1)   % Mean-squared simulation error
sse(2)   % Mean-squared one-step prediction error
sse(3)   % Mean-squared k-step prediction error
```

For details, refer to [`model_simulation`](/doc/model_simulation.md).

---

## Examples

Examples are given in [`Examples/AR_NFIR_models`](/Examples/AR_NFIR_models).

| Example script              | Model                           | Description                                                                                                                                                                                                                                                  |
| --------------------------- | ------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `example_ar_nfir.m`         | `mao_piroddi_ar_nfir_model.m`   | An AR-NFIR model with a cubic NAR part and a cubic NFIR part ($`N_p^{AR} = 3`$, $`N_p^{NFIR} = 3`$), constructed from the output-lagged terms of the Mao and Billings benchmark and the deterministic part of the Piroddi and Spinelli benchmark.               |
| `example_heater_ar_nfir.m`  | `heater_ar_nfir_model.m`        | A Hammerstein model of a small electrical heater. A Hammerstein model with a polynomial static nonlinearity is an AR-NFIR model with a linear AR part ($`N_p^{AR} = 1`$, $`N_p^{NFIR} = 2`$).                                                            |

---

## Notes

* `mod_type` should be `'ARX'`. With `'AR'`, the identified model is a (N)AR model with a maximum polynomial order of `nl_ord_AR`.
* The noise model (NARMAX) identification is not supported by `NonSysID-AR-NFIR`.
* `nl_ord_AR` and `nl_ord_NFIR` must each be at least `1`. Setting both to `1` gives a linear ARX model, identical to that from `NonSysID` with `nl_ord_max = 1`.
* Linear lagged-output and lagged-input terms are always included in the candidate dictionary. The restriction applies only to the nonlinear terms.
* Cross-terms between lagged outputs and lagged inputs are never included in the candidate dictionary.
* Nonlinear cross-products between different inputs are retained, as part of the NFIR part.
* The full candidate dictionary is generated to a polynomial order of `max(nl_ord_AR,nl_ord_NFIR)` before the restriction is applied. When the two orders differ considerably, a larger candidate dictionary is generated and then pruned.
* The identified `model` is fully compatible with `model_simulation` and the other `NonSysID` model-evaluation functions.
* For `RCT = 1` and `3`, the nonlinear candidate dictionary is formed only from the linear terms selected in the linear ARX model. A lagged output or input that is not selected in the linear model therefore cannot appear in any nonlinear term.
* Parallel processing can reduce identification time for large candidate dictionaries.
* For small problems, parallel-pool startup overhead may outweigh the computational benefit.
* The same input-lag range `b1:b2` is currently applied to every input.
