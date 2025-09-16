# `model_simulation`

`model_simulation` simulates the output of an identified NARX (Nonlinear AutoRegressive with eXogenous input) model using given input/output data and a specified k-step-ahead horizon.  
It returns the simulated output, error, and delay matrix, and is typically used after identifying a model with [`NonSysID`](./NonSysID.md).

---

## Signature

```matlab
[sse, y_hat, error, U_delay_mat_sim] = model_simulation(model, u, y, KSA_h)
```

---

## Parameters

| Name    | Type     | Required | Description |
|---------|----------|----------|-------------|
| `model` | struct   | Yes | Identified NARX model structure, e.g. returned by `NonSysID`. |
| `u`     | vector / matrix | Yes | Input signal(s) used for simulation. The number of columns depends on the number of inputs in the model. |
| `y`     | column vector   | Yes | Actual measured output signal (for comparison with simulated output and for one-step-ahead/k-step-ahead predictions). If only model simulation is required, then set `y` to a column vector of zeros with the same length as `u` (`y=u(:,1).*0`)|
| `KSA_h` | int      | Yes | Horizon for **k-step-ahead prediction** in the simulation. |

---

## Returns

| Output             | Type     | Description |
|--------------------|----------|-------------|
| `sse`              | double   | Sum of squared errors between measured and simulated output. |
| `y_hat`            | matrix   | Model output. Columns represent multi-step-ahead (simulation/model predicted output), one-step-ahead and k-step-ahead predictions, respectively. |
| `error`            | vector   | Model errors against the actual output `y`. Columns represent the errors between `y` and the corresponding model outputs in `y_hat`|
| `U_delay_mat_sim`  | matrix   | Delay matrix for input(s) used in the simulation (aligned with model regressors). |

---

## Algorithm (High-Level)

1. **Input delay construction**: Builds delayed input matrix according to model order.  
2. **Simulation loop**: Uses the identified model to predict outputs over the horizon `KSA_h`.  
3. **Error computation**: Compares predicted outputs with measured data (`y`).  
4. **Performance measure**: Computes `sse` and optionally other error statistics.  

---

## Example Usage

```matlab
% Assume 'model' is obtained from NonSysID
[sse, y_hat, error, U_delay_mat_sim] = model_simulation(model, u, y, KSA_h);

% Plotting example
figure;
subplot(2,1,1);
plot(u, 'Color', '#0072BD');
ylabel('$u(t)$','Interpreter','latex','FontSize',12);

n = length(y);
subplot(2,1,2);
plot(1:n, y, 'Color', '#77AC30', 'LineWidth', 1.5); hold on;
plot(tt_splt, y_ID, 'Color', '#EDB120', 'LineWidth', 1.5); hold on;
plot((length(y)-length(y_hat)+1:n), y_hat(:,3), 'k-.', 'LineWidth', 1.25);

legend('$y(t)$ -- testing', ...
       '$y(t)$ -- training', ...
       '$\\hat{y}(t)$ -- model simulation', ...
       'Interpreter','latex','FontSize',12);
xlabel('Time Samples');
ylabel('$y(t)/\\hat{y}(t)$','Interpreter','latex','FontSize',12);
```

---

## Notes

- The third column of `y_hat` (`y_hat(:,3)`) is often used to represent the k-step-ahead simulated output.  
- Ensure that the horizon `KSA_h` matches the one used during model identification.  
- The function is designed for NARX models identified via `NonSysID`, but can be adapted for other compatible model structures.  

---

## See Also

- [`NonSysID`](./NonSysID_Documentation.md)  
- [`compare`](https://www.mathworks.com/help/ident/ref/compare.html)  
- [`forecast`](https://www.mathworks.com/help/ident/ref/forecast.html)  
