function [sse,y_hat,error,U_delay_mat_sim] = ...
    model_simulation_i(model,u,y,~)

%MODEL_SIMULATION_I Simulate or predict an identified ARX-i model.
%
% Syntax:
%   [sse,y_hat,error,U_delay_mat_sim] = ...
%       model_simulation_i(model,u,y,k)
%
% Inputs:
%   model - Model cell array returned by NonSysID_i
%   u     - N-by-n_inpts input matrix
%   y     - N-by-1 measured output vector
%   k     - Prediction horizon retained for interface compatibility
%
% Outputs:
%   sse   - [MSSE, MSPE, MSkPE]
%   y_hat - [free-run, one-step-ahead, k-step-ahead] outputs
%   error - Corresponding prediction errors
%   U_delay_mat_sim - Trimmed input-lag information matrix
%
% For ARX-i models there are no lagged-output feedback terms. Therefore,
% free-run simulation, one-step-ahead prediction and k-step-ahead
% prediction are identical. The value of k does not affect the result.

% Extract model information
b1 = model{3};
b2 = model{4};
theta_process = model{5};
trm_chsn_lin = model{6};
trm_chsn_lin_org = model{7};
n_lin_trms_org = model{8};
nl_ord_max = model{9};
trm_chsn_nl = model{10};
bias = model{11};
n_inpts = model{12};

% Form the input lag ranges
min_dyn_ord_u = ones(1,n_inpts).*b1;
max_dyn_ord_u = ones(1,n_inpts).*b2;

% Form the input-only information matrix
[U_delay_mat_sim,X_sim,Y_sim] = info_mat_sysID_i(...
    min_dyn_ord_u,max_dyn_ord_u,u,y);

% Evaluate the identified ARX-i model
y_est = one_step_pred_model_reg(...
    X_sim,theta_process,trm_chsn_lin,trm_chsn_lin_org,...
    n_lin_trms_org,nl_ord_max,trm_chsn_nl,bias);

% Evaluate the model error
error_i = Y_sim-y_est;
mse = (error_i'*error_i)/length(error_i);

% Free-run, one-step and k-step predictions are identical for ARX-i
sse = [mse,mse,mse];
y_hat = [y_est,y_est,y_est];
error = [error_i,error_i,error_i];

end