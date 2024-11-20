# NonSysId: Nonlinear System Identification with Improved Model Term Selection for NARMAX Models  
*An open-source MATLAB package for system identification of ARX, NARX and (N)ARMAX models, featuring improved term selection and robust long-term simulation capabilities.*

[![MATLAB](https://img.shields.io/badge/MATLAB-R2017a-blue)](https://www.mathworks.com/products/matlab.html) 
[![MATLAB](https://img.shields.io/badge/MATLAB-R2023b-blue)](https://www.mathworks.com/products/matlab.html) 
[![License](https://img.shields.io/badge/License-BSD_3--Clause-orange.svg)](https://opensource.org/licenses/BSD-3-Clause)

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

### Installation  
1. Clone the repository:  
   ```bash
   git clone https://github.com/username/NonSysId.git
   ```
   or manually download the folder 'NonSysId'.
   
2. In Matlab, either;
    - add the folder 'NonSysId' to the Matlab path permanently using the 'pathtool' (https://uk.mathworks.com/help/matlab/ref/pathtool.html).
    - or use the 'addpath' command in the Matlab script to add the folder 'NonSysId' and use the functions within (https://uk.mathworks.com/help/matlab/ref/addpath.html).

### Examples
Basic use

## References
[1] S. B. Yuzhu Guo, L.Z. Guo and H.-L. Wei, “An iterative orthogonal forward regression algorithm,” International Journal of Systems Science, vol. 46, no. 5, pp. 776–789, 2015.

[2] X. Hong, P. Sharkey, and K. Warwick, “Automatic nonlinear predictive model-construction algorithm using forward regression and the press statistic,” IEE Proceedings-Control Theory and Applications, vol. 150, no. 3, pp. 245–254, 2003.

[3] L. Ljung, System identification. Springer, 1998.

[4] S. Billings, Nonlinear System Identification: NARMAX Methods In The Time, Frequency, And Spatio-Temporal Domains, vol. 13. Chichester, UK: John Wiley & Sons, Ltd, 2013.

[5] S. Chen, S. Billings, and W. Luo, “Orthogonal least squares methods and their application to non-linear system identification,” Int. J. Control, vol. 50, no. 5, pp. 1873–1896„ 1989.

[6] S. Billings, M. Korenberg, and S. Chen, “Identification of non-linear output-affine systems using an orthogonal least squares algorithm,” 1987.

[7] M. Korenberg, S. Billings, Y. Liu, and P. McIlroy, “Orthogonal parameter estimation algorithm for non-linear stochastic systems,” Int. J. Control, vol. 48, no. 1, pp. 193–210„ 1988.


