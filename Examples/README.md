# Example code structure to use the NonSysID package
This document provides a code structure to do system identification using the NonSysID package. The examples shown follow the same structure.

## Identify (N)ARX model using NonSysID
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

% Stopping criteria for the OFR identification algorithm.
% Select which stopping criteria ('PRESS_thresh' or 'BIC_thresh')
% to use for deciding when to stop adding terms to a candidate model.
% 'stp_cri(1)' for linear model identification and
% 'stp_cri(2)' for nonlinear model identification.
stp_cri = {'PRESS_thresh', 'PRESS_thresh'};

% Set the terminating value ('D1_thresh') for the selected stopping criteria ('stp_cri').
% 'D1_thresh(1)' for linear model identification and 'D1_thresh(2)' for nonlinear model identification
D1_thresh = [10^(-10),10^(0.9)];

% Specify if bias/DC offset is required, 0, or not, 1.
is_bias=0;

% Specify number of inputs
n_inpts=1;

% Specify the number of steps for k-steps ahead prediction
KSA_h=20;

% Specify which RCT (Reduce Computational Time) method to use, 1-4, 0 for no RCT.
RCT=4;

% Specify whether to simulate the identified model and display the results, respectively.
% Set 'sim(1)' and 'sim(2)', with 0 for no and 1 for yes, for linear model and nonlinear models, respectively. 
sim=[1,1];

% Set to 1 to display all models generated from iOFRs, 0 otherwise
displ=0;

% Set 'parall(1)' and 'parall(2)', for linear model and nonlinear models respectively,
% with 1 or 0 to use parallel processing to accelerate iOFRs.
parall = [1,1];
```

(4) Run system identification using the `NonSysID` function. Here, the output variable 'model' contains the best (N)ARX model identified. 

```matlab
[model, Mod_Val_dat, iOFR_table_lin, iOFR_table_nl, best_mod_ind_lin, best_mod_ind_nl, val_stats] = ...
    NonSysID(mod_type,u_ID,y_ID,na1,na2,nb1,nb2,nl_ord_max,is_bias,n_inpts,KSA_h,RCT,x_iOFR,stp_cri,D1_thresh,displ,sim,parall);
```

(5) Display the identified model

```matlab
disp('ARX model:'); disp(iOFR_table_lin{best_mod_ind_lin,1}); % Print the best ARX model that fits the data
if best_mod_ind_nl~=0 % If a NARX model was identified, then display the best NARX model that fits the data
    disp('NARX model:'); 
    tbl_NARX = join(iOFR_table_nl{best_mod_ind_nl,10},iOFR_table_nl{best_mod_ind_nl,1});disp(tbl_NARX);
end
```

## Simulate an identify (N)ARX model using NonSysID

(1) Simulate the identified model ('model').

```matlab
[sse, y_hat, error, U_delay_mat_sim] = model_simulation(model,u,y,KSA_h);
```

(2) Plot the simulation results
```matlab
%----------
figure;
subplot(2,1,1); plot(u, 'Color', '#0072BD');
ylabel('$u(t)$','Interpreter','latex','FontSize',12);
%----------
n = length(y);
subplot(2,1,2);
plot(1:n, y,'Color', '#77AC30', 'LineWidth', 1.5); hold on;
plot(tt_splt, y_ID, 'Color', '#EDB120','LineWidth', 1.5); hold on;
plot((length(y)-length(y_hat)+1:n), y_hat(:,3), 'k-.', 'LineWidth',1.25);
legend('$y(t)$ -- testing', '$y(t)$ -- training','$\hat{y}(t)$ -- model simulation','Interpreter','latex','FontSize',12);
xlabel('Time Samples');
ylabel('$y(t)/\hat{y}(t)$','Interpreter','latex','FontSize',12);
%----------
```



