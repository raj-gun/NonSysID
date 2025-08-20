# `NonSysID`

`NonSysID` performs system identification for **linear/nonlinear ARX** (input–output) and **AR** (autoregressive) models using an iterative Orthogonal Forward Regression (iOFR) algorithm.  
It supports polynomial nonlinearities, multiple stopping criteria, k-step-ahead prediction, and optional parallelization.

---

## Signature

```matlab
[model, Mod_Val_dat, iOFR_table_lin, iOFR_table_nl, ...
 best_mod_ind_lin, best_mod_ind_nl, val_stats] = ...
    NonSysID(mod_type, u_ID, y_ID, ...
             na1, na2, nb1, nb2, ...
             nl_ord_max, is_bias, n_inpts, KSA_h, RCT, ...
             x_iOFR, stp_cri, D1_thresh, displ, sim, parall);
```
---

## Parameters

| Name        | Type        | Required | Description |
|-------------|-------------|----------|-------------|
| `mod_type`  | `char`      | Yes 	   | Model type: `'ARX'` (linear/nonlinear input–output model) or `'AR'` (linear/nonlinear autoregressive model). |
| `u_ID`      | `vector/matrix`    | Yes 	   | Input signal(s) used for identification. Number of columns depends on `n_inpts`. |
| `y_ID`      | `vector`    | Yes 	   | Output signal used for identification. |
| `na1`       | `int`       | Yes 	   | Minimum output lag (smallest lagged output term included). |
| `na2`       | `int`       | Yes 	   | Maximum output lag (largest lagged output term included). |
| `nb1`       | `int`       | Yes 	   | Minimum input lag (smallest lagged input term included). |
| `nb2`       | `int`       | Yes 	   | Maximum input lag (largest lagged input term included). |
| `nl_ord_max`| `int`       | Yes 	   | Maximum polynomial nonlinearity order. `1 = linear`, `>1 = nonlinear`. |
| `is_bias`   | `int` (0/1) | Yes 	   | Include bias/DC offset term (`0 = include`, `1 = exclude`). |
| `n_inpts`   | `int`       | Yes 	   | Number of input signals. |
| `KSA_h`     | `int`       | Yes 	   | Horizon for **k-step-ahead prediction**. |
| `RCT`       | `int` (0–4) | Yes 	   | Reduce Computational Time method (`0 = none`, `1–4 = selected RCT method`). |
| `x_iOFR`    | `logical[2]`| Yes 	   | Whether to run more than one iOFR iteration: `x_iOFR(1)` for linear model, `x_iOFR(2)` for nonlinear. |
| `stp_cri`   | `cell{2}`   | Yes 	   | Stopping criteria: `'PRESS_thresh'` or `'BIC_thresh'`. First for linear, second for nonlinear. |
| `D1_thresh` | `double[2]` | Yes 	   | Threshold values for stopping criteria. First for linear, second for nonlinear. |
| `displ`     | `int` (0/1) | Yes 	   | Display all candidate models (`1`) or only final model (`0`). |
| `sim`       | `int[2]`    | Yes 	   | Run and display simulation: `sim(1)` for linear model, `sim(2)` for nonlinear (`0 = no`, `1 = yes`). |
| `parall`    | `int[2]`    | Yes 	   | Enable parallel processing: `parall(1)` for linear, `parall(2)` for nonlinear (`0 = no`, `1 = yes`). |

---

## Returns

| Output             | Type     | Description |
|--------------------|----------|-------------|
| `model`            | struct   | Identified best model structure (linear or nonlinear depending on settings). |
| `Mod_Val_dat`      | struct   | Validation data and results for identified models. |
| `iOFR_table_lin`   | table    | Orthogonal Forward Regression (OFR) results for candidate **linear** models. |
| `iOFR_table_nl`    | table    | OFR results for candidate **nonlinear** models. |
| `best_mod_ind_lin` | int      | Index of the best linear model among candidates. |
| `best_mod_ind_nl`  | int      | Index of the best nonlinear model among candidates. |
| `val_stats`        | struct   | Validation statistics (e.g., prediction error, PRESS, BIC). |

---

## Algorithm (High-Level)

1. **Model candidate generation**: Constructs ARX or AR regressors based on specified input/output lags and nonlinearity order.  
2. **Orthogonal Forward Regression (OFR)**: Iteratively adds terms, evaluating contribution at each step.  
3. **Stopping criteria**: Uses PRESS (Prediction Error Sum of Squares) or BIC (Bayesian Information Criterion), with thresholds in `D1_thresh`.  
4. **Iteration control**: Optional multiple iterations until convergence (`x_iOFR`).  
5. **Performance enhancements**: Bias term, RCT acceleration, and parallelization options.  
6. **Validation**: Performs k-step-ahead prediction and/or simulation as configured.  

---

## Example Usage

```matlab
% Identification data (replace with actual signals)
u_ID = randn(1000,1);   % input signal
y_ID = randn(1000,1);   % output signal

% Configure model options
mod_type = 'ARX';
na1 = 1; na2 = 3;
nb1 = 1; nb2 = 3;
nl_ord_max = 2;
x_iOFR = [true,true];
stp_cri = {'PRESS_thresh', 'PRESS_thresh'};
D1_thresh = [1e-10, 10^0.9];
is_bias = 0;
n_inpts = 1;
KSA_h = 20;
RCT = 4;
sim = [1,1];
displ = 0;
parall = [1,1];

% Run NonSysID
[model, Mod_Val_dat, iOFR_table_lin, iOFR_table_nl, ...
 best_mod_ind_lin, best_mod_ind_nl, val_stats] = ...
    NonSysID(mod_type, u_ID, y_ID, ...
             na1, na2, nb1, nb2, ...
             nl_ord_max, is_bias, n_inpts, KSA_h, RCT, ...
             x_iOFR, stp_cri, D1_thresh, displ, sim, parall);
```

---

## Notes

- `nl_ord_max = 1` yields purely **linear** models. Higher orders allow polynomial nonlinearities.  
- Stopping criteria (`PRESS_thresh` or `BIC_thresh`) strongly affect model complexity.  
- Use parallel processing (`parall`) for large datasets to significantly speed up iOFR iterations.  
- Setting `sim = [1,1]` will run and display simulations for both linear and nonlinear models.  

---

