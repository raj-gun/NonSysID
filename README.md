# NonSysId: Nonlinear System Identification with Improved Model Term Selection for NARMAX Models  
*An open-source MATLAB package for system identification of ARX, NARX and (N)ARMAX models, featuring improved term selection and robust long-term simulation capabilities.*

Authors: [Rajintha Gunawardena](https://github.com/raj-gun)<sup>1</sup>, [Zi-Qiang Lang](https://sheffield.ac.uk/eee/people/academic-staff/zi-qiang-lang)<sup>2</sup>, [Fei He](https://github.com/feihelab)<sup>1</sup>
1. Centre for Computational Science and Mathematical Modelling, Coventry University, Coventry CV15FB, UK.
2. School of Electrical and Electronic Engineering, The University of Sheffield, Western Bank, Sheffield S10 2TN, UK.

[![MATLAB](https://img.shields.io/badge/MATLAB-R2017a-blue)](https://www.mathworks.com/products/matlab.html) 
[![MATLAB](https://img.shields.io/badge/MATLAB-R2023b-blue)](https://www.mathworks.com/products/matlab.html) 
[![License](https://img.shields.io/badge/License-BSD_3--Clause-orange.svg)](https://opensource.org/licenses/BSD-3-Clause)
[![DOI](https://joss.theoj.org/papers/10.21105/joss.08028/status.svg)](https://doi.org/10.21105/joss.08028)
[![arXiv](https://img.shields.io/badge/arXiv-1234.56789-b31b1b.svg)](https://doi.org/10.48550/arXiv.2411.16475)


---

## Overview 📖  
**NonSysId** is a MATLAB package designed for the identification of nonlinear dynamic systems using (N)AR(MA)X models. It incorporates an enhanced Orthogonal Forward Regression (OFR) algorithm, iterative-OFR (iOFR), and PRESS-statistic based criterion to improve model term selection and ensure robust long-term predictions. The package is particularly suited for applications where separate validation datasets are difficult to obtain, such as real-time fault diagnosis and electrophysiological studies.

### Features  
- **Iterative OFR (iOFR)**: Improves term selection by iterating through multiple orthogonalisation paths to produce parsimonious models.  
- **Simulation-based Model Selection**: Ensures simulation stability and enhances long-term prediction accuracy.  
- **PRESS-statistic Integration**: Includes a PRESS-statistic based term selection criterion that aims to minimise the leave-one-out cross-validation error. Therefore, the model can be validated without requiring separate validation datasets.  
- **Reduced Computational Time (RCT)**: Optimized procedures to accelerate model term selection for complex NARX models.  

---

## Getting Started 🚀  

### Prerequisites  
- MATLAB R2017a or later.  
- Required MATLAB Toolboxes:  
  - **Signal Processing Toolbox** (required if using earlier than Matlab 2019a, for correlation analysis).
  - **Parallel Computing Toolbox** (required for accelerating system identification procedures).

### Installation  
1. Clone the repository:  
   ```bash
   git clone https://github.com/raj-gun/NonSysId.git
   ```
   or manually download the folder 'NonSysId'.
   
2. In Matlab, either;
    - add the folder 'NonSysId' to the Matlab path permanently using the 'pathtool' (https://uk.mathworks.com/help/matlab/ref/pathtool.html).
    - or use the 'addpath' command in the Matlab script to add the folder 'NonSysId' and use the functions within (https://uk.mathworks.com/help/matlab/ref/addpath.html).

### Documentation
Brief documentation explaining the main functions and a code structure for identifying a model, simulating and validating an identified model is given in the [`doc`](/doc) folder.

### Examples
- Basic use of identifying a SISO NARX model from real data, see the example in [`Examples/Electro-mechanical system`](Examples/Electro-mechanical_system/).
- An example of identifying a MISO NARX model is shown in [`Examples/Hysteresis_model_MISO`](Examples/Hysteresis_model_MISO).

## Paper

If you are using the NonSysId package for academic purposes, kindly reference our paper as follows:

**NonSysId: Nonlinear System Identification with Improved Model Term Selection for NARMAX Models**

Rajintha Gunawardena, Zi-Qiang Lang, Fei He

DOI: [10.21105/joss.08028](https://doi.org/10.21105/joss.08028)

```
@article{Gunawardena2025,
doi = {10.21105/joss.08028},
url = {https://doi.org/10.21105/joss.08028},
year = {2025}, publisher = {The Open Journal},
volume = {10},
number = {114},
pages = {8028},
author = {Gunawardena, Rajintha and Lang, Zi-Qiang and He, Fei},
title = {NonSysId: Nonlinear System Identification with Improved Model Term Selection for NARMAX Models},
journal = {Journal of Open Source Software}
}
```      

## References
[1] M. Korenberg, S. Billings, Y. Liu, and P. McIlroy, “Orthogonal parameter estimation algorithm for non-linear stochastic systems,” Int. J. Control, vol. 48, no. 1, pp. 193–210„ 1988.

[2] S. Chen, S. Billings, and W. Luo, “Orthogonal least squares methods and their application to non-linear system identification,” Int. J. Control, vol. 50, no. 5, pp. 1873–1896„ 1989.

[3] S. Billings, Nonlinear System Identification: NARMAX Methods In The Time, Frequency, And Spatio-Temporal Domains, vol. 13. Chichester, UK: John Wiley & Sons, Ltd, 2013.

[4] S. B. Yuzhu Guo, L.Z. Guo and H.-L. Wei, “An iterative orthogonal forward regression algorithm,” International Journal of Systems Science, vol. 46, no. 5, pp. 776–789, 2015.

[5] X. Hong, P. Sharkey, and K. Warwick, “Automatic nonlinear predictive model-construction algorithm using forward regression and the press statistic,” IEE Proceedings-Control Theory and Applications, vol. 150, no. 3, pp. 245–254, 2003.

[6] L. Ljung, System identification. Springer, 1998.


