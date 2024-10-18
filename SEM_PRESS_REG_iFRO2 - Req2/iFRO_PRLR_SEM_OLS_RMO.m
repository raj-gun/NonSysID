function [theta_sim,trm_chsn_lin_temp,trm_chsn_nl_temp,ind_orth_wrt,X_main,ERR,MS_PRESS_E,trm_lag_char_tot] = iFRO_PRLR_SEM_OLS_RMO(X,Y,trm_chsn_lin,n_lin_trms,nl_ord_max,trm_lag_char_tot,alph)

[trm_lag_char_tot,trm_chsn_nl,X,~] = generate_nl_reg(nl_ord_max,X,X,n_lin_trms,n_lin_trms,trm_lag_char_tot,trm_lag_char_tot);
trms_chsn_tot = [trm_chsn_lin,trm_chsn_nl];
n_terms = length(trms_chsn_tot); % Total number of candidate linear and nonlinear terms without bias
size_X = size(X);

% ------------------- Force OLS-ERR ------------------------
frc_ind = 1;
stp_cri = 1;
[theta_fro,~,ERR,~,MS_PRESS_E,~,~,~,~,ind_orth_wrt,~] = OLS_orthogonalisation_reg_press_frc_RMO(X,Y,0,frc_ind,0,0,stp_cri,alph);

ERR = ERR(1:length(theta_fro));
[ind_orth_wrt_chsn,srt_i] = sort(ind_orth_wrt,'ascend');
trm_lag_char_tot = trm_lag_char_tot(ind_orth_wrt_chsn);
X_main = X(:,ind_orth_wrt_chsn);
theta = theta_fro(srt_i);

trm_chsn_lin_temp = trms_chsn_tot(ind_orth_wrt_chsn(ind_orth_wrt_chsn <= n_lin_trms));

if n_terms == size_X(2)
    trm_chsn_nl_temp =  trms_chsn_tot(ind_orth_wrt_chsn(ind_orth_wrt_chsn > n_lin_trms));
    theta_sim = theta;
    bias = 0;
else
    ind_orth_wrt_chsn_temp = ind_orth_wrt_chsn(1:end-1);
    trm_chsn_nl_temp =  trms_chsn_tot(ind_orth_wrt_chsn_temp(ind_orth_wrt_chsn_temp > n_lin_trms));
    theta_sim = theta(1:end-1);
    bias = theta(end);
end

end