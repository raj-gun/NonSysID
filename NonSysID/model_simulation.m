function [sse, y_hat, error, U_delay_mat_sim] = model_simulation(model,u,y,k)

a1=model{1};a2=model{2};b1=model{3};b2=model{4};theta_procss=model{5};trm_chsn_lin=model{6};trm_chsn_lin_org=model{7};
n_lin_trms_org=model{8};nl_ord_max=model{9};trm_chsn_nl=model{10};bias=model{11};n_inpts=model{12};
%% Form the linear regressors/monomials/lagged-terms/model terms
min_dyn_ord_u = ones(1,n_inpts).*b1;
max_dyn_ord_u = ones(1,n_inpts).*b2;
min_dyn_ord_y = a1;
max_dyn_ord_y = a2;
inpt0=ones(1,n_inpts).*0;
n_terms_yi = max_dyn_ord_y-min_dyn_ord_y+1; %No. of lagged terms from each output
n_terms_ui = max_dyn_ord_u-min_dyn_ord_u+1; %No. of lgged terms from each input
n_terms_y = sum(n_terms_yi);
n_terms_u = sum(n_terms_ui);
%---------------------------------
[~,~,~,X_ID,Y_ID] = info_mat_sysID(min_dyn_ord_u,min_dyn_ord_y,max_dyn_ord_u,max_dyn_ord_y,u,y);
%---------------------------------
%---------------------------
Y_sim = Y_ID;%Y_trim_ID2;
Xsim_ID = X_ID;%X_trim_ID2;
y_lag_lin_srt = Xsim_ID(1,1:n_terms_y);
U_delay_mat_sim = Xsim_ID(:,n_terms_y+1:end);
%---------------------------
[y_est] = sim_model_reg_2(theta_procss,trm_chsn_lin,trm_chsn_lin_org,U_delay_mat_sim,n_lin_trms_org,y_lag_lin_srt,nl_ord_max,trm_chsn_nl,bias);
if sum(y) ~=0
    [y_pred] = one_step_pred_model_reg(Xsim_ID,theta_procss,trm_chsn_lin,trm_chsn_lin_org,n_lin_trms_org,nl_ord_max,trm_chsn_nl,bias);
    [Y_kSA] = k_step_pred_model_reg(k,n_terms_y,Xsim_ID,theta_procss,trm_chsn_lin,trm_chsn_lin_org,n_lin_trms_org,nl_ord_max,trm_chsn_nl,bias);
else
    y_pred = Y_sim;
    Y_kSA = Y_sim;
end
%---------------------------
error_sim = Y_sim - y_est;
dat_len_y_sim = length(Y_sim);
msse = (error_sim'*error_sim)/dat_len_y_sim;

error_pred = Y_sim - y_pred;
mspe = (error_pred'*error_pred)/length(error_pred);

error_kSA = Y_sim - Y_kSA;
mskpe = (error_kSA'*error_kSA)/length(error_kSA);
%%
sse = [msse, mspe, mskpe];
y_hat = [y_est, y_pred, Y_kSA];
error = [error_sim, error_pred, error_kSA];
end