function [trm_lag_char_tot,trm_chsn_nl,X_main_org] = rm_crs_trms_AR_NFIR(trm_lag_char_tot,trm_chsn_nl,X_main_org,nl_ord_AR,nl_ord_NFIR)

%Restricts a candidate term dictionary to the AR-NFIR model class. Every
%nonlinear candidate term that mixes output-lagged (AR) factors with
%input-lagged (NFIR) factors is discarded, and the separate maximum
%polynomial orders of the two additive parts of the model are applied.
%Linear terms match neither condition and are always retained. The
%surviving entries of trm_chsn_nl keep their original values, as these
%index the unpruned superset of nonlinear terms that is rebuilt by
%sim_model_reg_2, one_step_pred_model_reg and k_step_pred_model_reg.

pat_y = 'y\d+\(t-?\d+\)'; % Character pattern of an output-lagged (AR) factor
pat_u = 'u\d+\(t-?\d+\)'; % Character pattern of an input-lagged (NFIR) factor

n_trms = length(trm_lag_char_tot); % Total no. of candidate terms without bias
n_lin_trms = n_trms - length(trm_chsn_nl); % No. of linear terms leading the dictionary
keep_ind = true(1,n_trms); % Candidate terms retained in the AR-NFIR dictionary

% ------------- Identify the inadmissible nonlinear terms ------------------
for i = n_lin_trms+1:n_trms
    trm_str = trm_lag_char_tot{1,i}; % Term identification string
    n_y_fctr = length(regexp(trm_str,pat_y)); % No. of output-lagged factors
    n_u_fctr = length(regexp(trm_str,pat_u)); % No. of input-lagged factors

    is_crs = (n_y_fctr > 0) && (n_u_fctr > 0); % Cross-term between the AR and NFIR parts
    is_AR_ovr = (n_u_fctr == 0) && (n_y_fctr > nl_ord_AR); % (N)AR part above Np_AR
    is_NFIR_ovr = (n_y_fctr == 0) && (n_u_fctr > nl_ord_NFIR); % NFIR part above Np_NFIR

    if is_crs || is_AR_ovr || is_NFIR_ovr;keep_ind(i) = false;end
end
% --------------------------------------------------------------------------

% ------------------- Prune the candidate dictionary -----------------------
trm_lag_char_tot = trm_lag_char_tot(keep_ind);
trm_chsn_nl = trm_chsn_nl(keep_ind(n_lin_trms+1:end)); % Original term indices are preserved
X_main_org = X_main_org(:,keep_ind);
% --------------------------------------------------------------------------

end
