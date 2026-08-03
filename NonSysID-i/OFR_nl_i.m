function iOFR_table_nl = OFR_nl_i(X,Y,Y_sim,frc_ind,...
    U_delay_mat,trm_chsn_lin,n_lin_trms,trm_chsn_nl,trm_lag_char_tot,...
    stp_cri,alph,D1_thresh,displ)
%OFR_NL_I Evaluate an input-only nonlinear candidate model.

dat_len = length(Y);
trms_chsn_tot = [trm_chsn_lin,trm_chsn_nl];
n_terms = length(trms_chsn_tot);
size_X = size(X);

[theta_fro,ms_press_e,ERR,~,MS_PRESS_E,MS_PRESS_E2,~,~,~,~,...
    ind_orth_wrt,~] = OLS_orthogonalisation_PRESS_frc(...
    X,Y,frc_ind,stp_cri,alph,D1_thresh);

MS_PRESS_E_org = MS_PRESS_E;
ERR = ERR(1:length(theta_fro));
[ind_orth_wrt_chsn,srt_i] = sort(ind_orth_wrt,'ascend');
X_main = X(:,ind_orth_wrt_chsn);
theta = theta_fro(srt_i);
ERR = ERR(srt_i);
MS_PRESS_E = MS_PRESS_E(srt_i);

ERR_table = table(ERR,theta,'RowNames',...
    trm_lag_char_tot(ind_orth_wrt_chsn)');
ERR_itr_table = 0;
MS_PRESS_table = table(MS_PRESS_E,theta,'RowNames',...
    trm_lag_char_tot(ind_orth_wrt_chsn)');

trm_chsn_lin_temp = trms_chsn_tot(...
    ind_orth_wrt_chsn(ind_orth_wrt_chsn<=n_lin_trms));
if n_terms == size_X(2)
    trm_chsn_nl_temp = trms_chsn_tot(...
        ind_orth_wrt_chsn(ind_orth_wrt_chsn>n_lin_trms));
else
    tmp_ind = ind_orth_wrt_chsn(1:end-1);
    trm_chsn_nl_temp = trms_chsn_tot(...
        tmp_ind(tmp_ind>n_lin_trms));
end

error_pred = Y-X_main*theta;
mspe = (error_pred'*error_pred)/dat_len;
Y_est = X_main*theta;
Y_kSA = Y_est;
error = Y_sim-Y_est;
error_kSA = Y-Y_kSA;
msse = (error'*error)/length(Y_sim);
mskpe = (error_kSA'*error_kSA)/dat_len;

if ~isempty(U_delay_mat)
    [dat_sim,conf_inv_sim] = ac_cc_model_valid_nl(...
        error,U_delay_mat(:,1),size(error,1),0);
    [dat_pred,conf_inv_pred] = ac_cc_model_valid_nl(...
        error_pred,U_delay_mat(:,1),size(error_pred,1),0);
    [dat_kSA,conf_inv_kSA] = ac_cc_model_valid_nl(...
        error_kSA,U_delay_mat(:,1),size(error_kSA,1),0);
else
    [dat_sim,conf_inv_sim] = ac_cc_model_valid_nl(error,[],size(error,1),0);
    [dat_pred,conf_inv_pred] = ac_cc_model_valid_nl(error_pred,[],size(error_pred,1),0);
    [dat_kSA,conf_inv_kSA] = ac_cc_model_valid_nl(error_kSA,[],size(error_kSA,1),0);
end
Mod_Val_dat = {cat(3,dat_sim,dat_pred,dat_kSA),...
    [conf_inv_sim,conf_inv_pred,conf_inv_kSA]};
val_stats = mod_val_stats(Mod_Val_dat);

SERR = sum(ERR_table.ERR);
if displ == 1
    disp(ERR_table);
    disp(['msse = ',num2str(msse)]);
    disp(['mspe = ',num2str(mspe)]);
    disp(['mskpe = ',num2str(mskpe)]);
    disp(['PRESS = ',num2str(ms_press_e)]);
    disp(['SERR = ',num2str(SERR)]);
end

iOFR_table_nl = cell(1,16);
iOFR_table_nl{1,1} = ERR_table;
iOFR_table_nl{1,2} = msse;
iOFR_table_nl{1,3} = mspe;
iOFR_table_nl{1,4} = mskpe;
iOFR_table_nl{1,5} = SERR;
iOFR_table_nl{1,6} = ms_press_e;
iOFR_table_nl{1,7} = trm_chsn_lin_temp;
iOFR_table_nl{1,8} = trm_chsn_nl_temp;
iOFR_table_nl{1,9} = ERR_itr_table;
iOFR_table_nl{1,10} = MS_PRESS_table;
iOFR_table_nl{1,11} = theta;
iOFR_table_nl{1,12} = ind_orth_wrt_chsn;
iOFR_table_nl{1,13} = MS_PRESS_E_org;
iOFR_table_nl{1,14} = Mod_Val_dat;
iOFR_table_nl{1,15} = MS_PRESS_E2;
iOFR_table_nl{1,16} = val_stats;
end
