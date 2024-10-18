function [Y_kSA] = k_step_pred_model_reg(k,n_terms_y,X,theta,trm_chsn_lin,trm_chsn_lin_org,n_lin_trms,nl_ord,trm_chsn_nl,bias)

% One step ahead predictions of ploynomial ARX and NARX type models
% n_lin_trms - number of linear terms
% trm_chsn_lin - term indecies of chosen linear terms from the superset of terms
% max_dyn_ord - maximum dynamic order of the original superset of terms
% U_delay_mat - Matrix containing all the linear input lagged terms (superset)

%% data mats
size_X = size(X);
dat_len = size_X(1);
n_steps = floor(dat_len/k);
rem_steps = dat_len - (n_steps*k);
Y_kSA = zeros(dat_len,1);


%% kSA prediction

for i = 1:n_steps
    
    %---------------------------
    Xsim_ID = X( ((i-1)*k + 1):(i*k) , : );
    y_lag_lin_srt = Xsim_ID(1,1:n_terms_y);
    U_delay_mat_sim = Xsim_ID(:,n_terms_y+1:end);
    %---------------------------
    
    [Y_est] = sim_model_reg_2(theta,trm_chsn_lin,trm_chsn_lin_org,U_delay_mat_sim,n_lin_trms,y_lag_lin_srt,nl_ord,trm_chsn_nl,bias);
    
    Y_kSA( ((i-1)*k + 1):(i*k) ) = Y_est;
    
end

if rem_steps ~= 0
    
    i = n_steps;
    %---------------------------
    Xsim_ID = X( (i*k + 1):dat_len , : );
    y_lag_lin_srt = Xsim_ID(1,1:n_terms_y);
    U_delay_mat_sim = Xsim_ID(:,n_terms_y+1:end);
    %---------------------------
    
    [Y_est] = sim_model_reg_2(theta,trm_chsn_lin,trm_chsn_lin_org,U_delay_mat_sim,n_lin_trms,y_lag_lin_srt,nl_ord,trm_chsn_nl,bias);
    
    Y_kSA( (i*k + 1):dat_len ) = Y_est;
       
end





end