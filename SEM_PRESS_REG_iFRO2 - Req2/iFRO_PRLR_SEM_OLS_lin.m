function iFRO_table_lin = iFRO_PRLR_SEM_OLS_lin(k,X,Y,Y_sim,frc_ind,n_terms_y,U_delay_mat,n_lin_trms_org,y_lag_lin_srt,trm_lag_char_lin,reg_itr_end,lambda_ini,lamda_stp,stp_cri,alph,displ)

dat_len = length(Y);
%dat_len_hlf = round(dat_len/2); % Half of data length
dat_len_y_sim = length(Y_sim);
%dat_len_hlf_y_sim = round(dat_len_y_sim/2); % Half of data length
size_X = size(X);
% stp_cri = 'PRESS_min';
stp_cri = 'PRESS_thresh';
D1_thresh = 1e-3;
% ------------------- Force OLS-ERR ------------------------
[theta_fro,ms_press_e,ERR,~,MS_PRESS_E,MS_PRESS_E2,~,~,~,~,ind_orth_wrt,~] = OLS_orthogonalisation_reg_press_frc(X,Y,lambda_ini,frc_ind,reg_itr_end,lamda_stp,stp_cri,alph,D1_thresh);
MS_PRESS_E_org = MS_PRESS_E;
ERR = ERR(1:length(theta_fro));
[ind_orth_wrt_chsn,srt_i] = sort(ind_orth_wrt,'ascend');
trm_chsn_lin_temp = ind_orth_wrt_chsn;
X_main = X(:,ind_orth_wrt_chsn);
theta = theta_fro(srt_i); ERR = ERR(srt_i); MS_PRESS_E = MS_PRESS_E(srt_i);
ERR_table = table(ERR,theta,'RowNames',trm_lag_char_lin(ind_orth_wrt_chsn)');
ERR_itr_table = 0;%array2table(ERR_itr,'RowNames',trm_lag_char_lin);
% MS_PRESS_E_itr_table = array2table(MS_PRESS_E_itr,'RowNames',trm_lag_char_lin);
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
[dat_sim, conf_inv_sim] = ac_cc_model_valid(error, U_delay_mat(:,1), size(error,1), 0);
[dat_pred, conf_inv_pred] = ac_cc_model_valid(error_pred, U_delay_mat(:,1), size(error_pred,1), 0);
[dat_kSA, conf_inv_kSA] = ac_cc_model_valid(error_kSA, U_delay_mat(:,1), size(error_kSA,1), 0);
Mod_Val_dat = {cat(3, dat_sim, dat_pred, dat_kSA), [conf_inv_sim, conf_inv_pred, conf_inv_kSA]};

% ------------------------------------------------------------
iFRO_table_lin = cell(1,13);
SERR = sum(ERR_table.ERR);
if displ == 1
    disp(ERR_table);
    disp(['msse = ',num2str(msse)]); disp(['mspe = ',num2str(mspe)]);
    disp(['mskpe = ',num2str(mskpe)]); disp(['PRESS = ',num2str(ms_press_e)]);
    disp(['SERR = ',num2str(SERR)]);
end
iFRO_table_lin{1,1} = ERR_table; iFRO_table_lin{1,2} = msse;
iFRO_table_lin{1,3} = mspe; iFRO_table_lin{1,4} = mskpe;
iFRO_table_lin{1,5} = SERR; iFRO_table_lin{1,6} = ms_press_e; 
iFRO_table_lin{1,7} = trm_chsn_lin_temp; iFRO_table_lin{1,8} = ERR_itr_table; 
iFRO_table_lin{1,9} = MS_PRESS_table; iFRO_table_lin{1,10} = theta; 
iFRO_table_lin{1,11} = MS_PRESS_E_org; iFRO_table_lin{1,12} = trm_chsn_lin_temp;
iFRO_table_lin{1,13} = Mod_Val_dat; iFRO_table_lin{1,14} = MS_PRESS_E2;
% ------------------------------------------------------------

end