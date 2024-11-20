# NonSysId: Nonlinear System Identification with Improved Model Term Selection for NARMAX Models  
*An open-source MATLAB package for system identification of ARX, NARX and (N)ARMAX models, featuring improved term selection and robust long-term simulation capabilities.*

[![MATLAB](https://img.shields.io/badge/MATLAB-R2023b-blue)](https://www.mathworks.com/products/matlab.html)  
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## Overview 📖  
**NonSysId** is a MATLAB package designed for the identification of nonlinear dynamic systems using (N)AR(MA)X models. It incorporates an enhanced Orthogonal Forward Regression (OFR) algorithm, iterative-OFR (iOFR), and PRESS-statistic based criterion to improve model term selection and ensure robust long-term predictions. The package is particularly suited for applications where separate validation datasets are difficult to obtain, such as real-time fault diagnosis and electrophysiological studies.

### Features  
- **Iterative OFR (iOFR)**: Improves term selection by iterating through multiple orthogonalisation paths to produce parsimonious models.  
- **Simulation-based Model Selection**: Ensures simulation stability and enhances long-term prediction accuracy.  
- **PRESS-statistic Integration**: Includes a PRESS-statistic-based term selection criterion that aims to minimise the leave-one-out cross-validation error. Therefore, the model can be validated without requiring separate validation datasets.  
- **Reduced Computational Time (RCT)**: Optimized procedures to accelerate model term selection for complex NARX models.  

---

## Getting Started 🚀  

### Prerequisites  
- MATLAB R2017a or later.  
- Required MATLAB Toolboxes:  
  - **Signal Processing Toolbox** (required if using earlier than Matlab 2019a, for correlation analysis).

### Installation  
1. Clone the repository:  
   ```bash
   git clone https://github.com/username/NonSysId.git
   ```
   or manually download the folder 'NonSysId'.
   
2. In Matlab, either;
    - add the folder 'NonSysId' to the Matlab path permanently using the 'pathtool' (https://uk.mathworks.com/help/matlab/ref/pathtool.html).
    - or use the 'addpath' command in the Matlab script to add the folder 'NonSysId' and use the functions within.   
### References

