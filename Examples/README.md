# Example code structure to use the NonSysID package
This document provides a code structure to do system identification using the NonSysID package. The examples shown here follow the same structure.

(1) In MATLAB, first clear the workspace and add the folder containing the `NonSydID` code to the search path

```matlab
close all;clear;clc
addpath('<add-path-to-NonSysID-folder>');
```

(2) Generate or import input-output data, and then, if required, process the data, such as downsampling, test-train data splitting. 
Note: When downsampling data, filtering up to the Nyquist frequency might be required to avoid anti-aliasing 

```matlab
% Import/generate input-output data
u = <input data>;
y = <output data>;

%--- Down sample data ---%
% Filter if required
dwn_smpl = 100; % Downsampling factor
u = u(1:dwn_smpl:end);
y = y(1:dwn_smpl:end);

%--- Data splitting ---%
tt_splt = 100:350; %Training samples of data
u_ID=u(tt_splt);
y_ID=y(tt_splt);
```

(3) Set up the options for the `NonSysID` system identification function. 

```matlab
% Model type ARX/AR
mod_type = 'ARX';

% Maximum and minimum output lags
na1=1;na2=3;

% Maximum and minimum input lags
nb1=1;nb2=3;

% Maximum order of polynomial nonlinearity considered
nl_ord_max=2;

% Run more than one iteration of iOFR for [linear model ,nonlinear model]
x_iOFR = [true,true];

% Stoping criteria for [linear model ,nonlinear model]. PRESS_thresh/BIC_thresh
stp_cri = {'PRESS_thresh', 'PRESS_thresh'};
% Set value for stopping criteria for [linear model ,nonlinear model]
% The stopping criteria relates to how many terms are added to the model
D1_thresh = [10^(-10),10^(0.9)];

% Specify if bias/DC off set is required, 0, or not, 1.
is_bias=0;

% Specify number of inputs
n_inpts=1;

% Specify the number of steps for k-steps ahead prediction
KSA_h=20;

% Specify which RCT (Reduce Computational Time) method to use, 1-4, 0 for
% no RCT.
RCT=4;

% Specify whether to simulate model and display results respectively
sim=[1,1];
% Set to 1 to display all models generated from iOFRs, 0 otherwise
displ=0;
% Set 1 or 0 to use parallel processing to accelerate iOFRs, for [linear model ,nonlinear model]
parall = [1,1];
```

