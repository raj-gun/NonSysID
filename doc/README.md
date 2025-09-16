# NonSysID Package Documentation

This repository provides MATLAB functions and examples for **system identification** of linear and nonlinear ARX/AR models using the `NonSysID` package.  
The workflow includes identifying a model, simulating it, and validating the results.

---

## Documentation

- [**NonSysID**](./NonSysID.md)  
  Main function for identifying ARX/NARX or AR/NAR models using iterative Orthogonal Forward Regression (iOFR).  
  Describes function signature, parameters, outputs, and example usage.

- [**model_simulation**](./model_simulation.md)  
  Function for simulating the identified NARX/ARX model and comparing outputs with measured data.  
  Includes details on simulation modes (multi-step, one-step, k-step-ahead).

- [**Example Code Structure**](./Example_code_structure.md)  
  A step-by-step guide to applying the `NonSysID` package in MATLAB.  
  Shows how to prepare data, configure parameters, identify models, simulate results, and validate models.

---

## Getting Started

1. Prepare your input (`u`) and output (`y`) data.  
2. Use [`NonSysID`](./NonSysID.md) to identify an appropriate ARX or NARX model.  
3. Run [`model_simulation`](./model_simulation.md) to simulate and evaluate model performance.  
4. Follow the workflow in the [Example Code Structure](./Example_code_structure.md) for a complete system identification pipeline.  

---

## See Also

- MATLAB System Identification Toolbox (`arx`, `nlarx`, `compare`)  
- Correlation-based validation functions for residual analysis.  
