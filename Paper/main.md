# NonSysId: Nonlinear System Identification with Improved Model Term Selection for NARMAX Models

## Authors
- **Rajintha Gunawardena**<sup>1</sup>  
- **Zi-Qiang Lang**<sup>2</sup>  
- **Fei He**<sup>1</sup>  
    Correspondence email: [fei.he@coventry.ac.uk](mailto:fei.he@coventry.ac.uk)  

### Affiliations
1. Centre for Computational Science and Mathematical Modelling, Coventry University, Coventry CV1 5FB, UK  
2. School of Electrical and Electronic Engineering, The University of Sheffield, Western Bank, Sheffield S10 2TN, UK  

---

## Abstract

### Summary
System identification develops mathematical representations of dynamic systems using input-output data. This approach models the system's behavior for analysis in time and frequency domains. Accurate modeling enables better understanding of system dynamics, essential for simulations and predictions. 

This paper introduces `NonSysId`, a MATLAB package focused on nonlinear system identification with improved term selection for NARMAX models. The methodology includes cross-validation without a separate dataset, ideal for real-time applications like structural health monitoring, fault diagnosis, and neurological studies.

---

## Keywords
- **System Identification**
- **NARMAX**
- **Orthogonal Least Squares**

---

## Statement of Need

System identification intersects control theory and machine learning, deriving mathematical models of dynamic systems from input-output data. It achieves two goals:

1. Accurately mapping inputs to outputs for prediction.  
2. Capturing system dynamics in discrete or continuous time, with a focus on discrete-time NARX/NARMAX models.  

NARX models predict outputs based on historical inputs and outputs, finding applications in control, fault diagnosis, structural health monitoring, and physiology. Extending NARX to include noise results in the NARMAX model, equivalent to a recurrent neural network.

---

## Features in `NonSysId`

### Iterative Orthogonal Forward Regression (iOFR)
The iterative-OFR algorithm addresses limitations of traditional OFR algorithms, such as overfitting and sensitivity to input signals. The `NonSysId` package implements simulation-based model selection (iOFR<sub>S</sub>), ensuring simulation stability and long-term prediction capabilities.

### PRESS-Statistic Based Term Selection
Using the PRESS-statistic criterion with leave-one-out cross-validation allows the selection of model terms that minimize errors without requiring additional validation data.

### Computational Time Reduction
`NonSysId` includes techniques to reduce computational overhead:
1. Reducing candidate model terms.
2. Iteratively refining model term selection.

---

## Example: DC Motor NARX Model Identification

### System Description
A NARX model for a DC motor is expressed as:

\[
y(t) = 1.7813y(t-1) - 0.7962y(t-2) + 0.0339u(t-1) + 0.0338u(t-2) - 0.1597y(t-1)u(t-1) + \dots
\]

### Inputs
- **Input (a):** White noise signal \( u(t) \sim \mathcal{N}(0,1) \).  
- **Input (b):** Multi-tone sinusoidal \( u(t) = 0.2(4\sin(\pi t) + 1.2\sin(4\pi t) + \dots) \).

### Results
- The identified models closely replicate the system dynamics.  
- PRESS-statistics validate the accuracy, and simulation results confirm stability.  

### Validation
Nonlinear correlation-based statistical validation confirms the models, with residual analysis showing minimal bias.

---

## Future Work

- Extend to Multi-Input Multi-Output (MIMO) models.
- Include regularization methods for improved generalization.
- Support for additional basis functions.
- Release a Python-based open-source package.

---

## References

1. Ljung, L. (1998). System Identification: Theory for the User. *Prentice Hall.*  
2. Billings, S. (2013). Nonlinear System Identification: NARMAX Methods in the Time, Frequency, and Spatio-Temporal Domains. *Wiley.*  
3. [Additional references as needed...]

