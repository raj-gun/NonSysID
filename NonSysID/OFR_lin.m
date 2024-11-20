function iOFR_table_lin = OFR_lin(k,X,Y,Y_sim,frc_ind,n_terms_y,U_delay_mat,n_lin_trms_org,y_lag_lin_srt,trm_lag_char_lin,stp_cri,D1_thresh,alph,displ)

dat_len = length(Y);
dat_len_y_sim = length(Y_sim);
size_X = size(X);
% ------------------- Force OLS-PRESS ------------------------
[theta_fro,ms_press_e,ERR,~,MS_PRESS_E,MS_PRESS_E2,~,~,~,~,ind_orth_wrt,~] = OLS_orthogonalisation_PRESS_frc(X,Y,frc_ind,stp_cri,alph,D1_thresh);
MS_PRESS_E_org = MS_PRESS_E;
ERR = ERR(1:length(theta_fro));
[ind_orth_wrt_chsn,srt_i] = sort(ind_orth_wrt,'ascend');
trm_chsn_lin_temp = ind_orth_wrt_chsn;
X_main = X(:,ind_orth_wrt_chsn);
theta = theta_fro(srt_i); ERR = ERR(srt_i); MS_PRESS_E = MS_PRESS_E(srt_i);
ERR_table = table(ERR,theta,'RowNames',trm_lag_char_lin(ind_orth_wrt_chsn)');
MS_PRESS_table = table(MS_PRESS_E,theta,'RowNames',trm_lag_char_lin(ind_orth_wrt_chsn)');

% ------------ Evaluate [MSSE, MSKPE, MPSE of current model ----------------
error_pred = Y - X_main*theta;
mspe = (error_pred'*error_pred)/dat_len;
if size_X(2) > n_lin_trms_org
    theta_sim = theta(1:end-1);
    bias = theta(end);
    trm_chsn_lin_temp_sim = trm_chsn_lin_temp(1:end-1);
else
    theta_sim = theta;
    bias = 0;
    trm_chsn_lin_temp_sim = trm_chsn_lin_temp;
end
[Y_est] = sim_model_reg_2(theta_sim,trm_chsn_lin_temp_sim,trm_chsn_lin_temp_sim,U_delay_mat,n_lin_trms_org,y_lag_lin_srt,0,[],bias);
[Y_kSA] = k_step_pred_model_reg(k,n_terms_y,X,theta_sim,trm_chsn_lin_temp_sim,trm_chsn_lin_temp_sim,n_lin_trms_org,0,[],bias);
error = Y_sim - Y_est;
msse = (error'*error)/dat_len_y_sim;
error_kSA = Y - Y_kSA;
mskpe = (error_kSA'*error_kSA)/dat_len_y_sim;

% ---------------------- Model Validation ---------------------------------
if ~isempty(U_delay_mat)
    [dat_sim, conf_inv_sim] = ac_cc_model_valid(error, U_delay_mat(:,1), size(error,1), 0);
    [dat_pred, conf_inv_pred] = ac_cc_model_valid(error_pred, U_delay_mat(:,1), size(error_pred,1), 0);
    [dat_kSA, conf_inv_kSA] = ac_cc_model_valid(error_kSA, U_delay_mat(:,1), size(error_kSA,1), 0);
    Mod_Val_dat = {cat(3, dat_sim, dat_pred, dat_kSA), [conf_inv_sim, conf_inv_pred, conf_inv_kSA]};
else
    [dat_sim, conf_inv_sim] = ac_cc_model_valid(error, [], size(error,1), 0);
    [dat_pred, conf_inv_pred] = ac_cc_model_valid(error_pred, [], size(error_pred,1), 0);
    [dat_kSA, conf_inv_kSA] = ac_cc_model_valid(error_kSA, [], size(error_kSA,1), 0);
    Mod_Val_dat = {cat(3, dat_sim, dat_pred, dat_kSA), [conf_inv_sim, conf_inv_pred, conf_inv_kSA]};
end
% ------------------------------------------------------------
iOFR_table_lin = cell(1,13);
SERR = sum(ERR_table.ERR);
if displ == 1
    disp(ERR_table);
    disp(['msse = ',num2str(msse)]); disp(['mspe = ',num2str(mspe)]);
    disp(['mskpe = ',num2str(mskpe)]); disp(['PRESS = ',num2str(ms_press_e)]);
    disp(['SERR = ',num2str(SERR)]);
end
iOFR_table_lin{1,1} = ERR_table; iOFR_table_lin{1,2} = msse;
iOFR_table_lin{1,3} = mspe; iOFR_table_lin{1,4} = mskpe;
iOFR_table_lin{1,5} = SERR; iOFR_table_lin{1,6} = ms_press_e;
iOFR_table_lin{1,7} = trm_chsn_lin_temp; iOFR_table_lin{1,8} = 0;
iOFR_table_lin{1,9} = MS_PRESS_table; iOFR_table_lin{1,10} = theta;
iOFR_table_lin{1,11} = MS_PRESS_E_org; iOFR_table_lin{1,12} = trm_chsn_lin_temp;
iOFR_table_lin{1,13} = Mod_Val_dat; iOFR_table_lin{1,14} = MS_PRESS_E2;
% ------------------------------------------------------------

end