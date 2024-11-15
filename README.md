# NonSysId: Nonlinear System Identification with Improved Model Term Selection for NARMAX Models  
*A MATLAB package for nonlinear system identification using ARX, NARX and NARMAX models, featuring improved term selection and robust long-term simulation capabilities.*

[![MATLAB](https://img.shields.io/badge/MATLAB-R2023b-blue)](https://www.mathworks.com/products/matlab.html)  
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## Overview 📖  
**NonSysId** is a MATLAB package designed for the identification of nonlinear dynamic systems using NARMAX models. It incorporates an enhanced Orthogonal Forward Regression (OFR) algorithm to improve model term selection and ensure robust long-term predictions. The package is particularly suited for applications where validation datasets are difficult to obtain, such as real-time fault diagnosis and neurological studies.

### Features  
- **Iterative OFR (iOFR)**: Improves term selection by iterating through multiple orthogonalisation paths.  
- **Simulation-based Model Selection**: Ensures simulation stability and enhances long-term prediction accuracy.  
- **PRESS-statistic Integration**: Includes leave-one-out cross-validation to minimize overfitting without requiring separate validation datasets.  
- **Reduced Computational Time (RCT)**: Optimized procedures to accelerate model term selection for complex NARX models.  

---

## Getting Started 🚀  

### Prerequisites  
- MATLAB R2023b or later.  
- Required MATLAB Toolboxes:  
  - **Signal Processing Toolbox** (for input-output analysis).  
  - **Optimization Toolbox** (optional for some routines).  

### Installation  
1. Clone the repository:  
   ```bash
   git clone https://github.com/username/NonSysId.git
   cd NonSysId
