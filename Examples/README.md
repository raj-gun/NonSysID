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
% Model type ARX/AR. For linear/nonlinear input-output type models 'ARX',
% otherwise for linear/nonlinear autoregressive models use 'AR'
mod_type = 'ARX';

% Maximum ('na2') and minimum ('na1') output lags. This option specifies that the
% lagged-output terms (past outputs considered) will be between y(t-na1) upto y(t-na2)
na1=1;
na2=3;

% Maximum ('nb2') and minimum ('nb1') input lags. This option specifies that the
% lagged-input terms (past inputs considered) will be between u(t-nb1) upto u(t-nb2)
nb1=1;
nb2=3;

% Maximum order of polynomial nonlinearity considered 'nl_ord_max'.
% This sets the degree of polynomial nonlinearity; nl_ord_max=1 means linear.  
nl_ord_max=2;

% Run more than one iteration of iOFR.
% Set 'true' or 'false' in 'x_iOFR(1)' for the linear model and 'x_iOFR(2)' for the nonlinear model.
% Generally, one iteration of iOFR is enough.
% If set 'true', the algorithm will automatically stop when a convergence to a certain model is reached. 
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

