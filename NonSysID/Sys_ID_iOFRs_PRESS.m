function [theta,X_main,trm_chsn_lin,trm_chsn_lin_org,n_lin_trms_org,trm_lag_char_lin_incld,trm_chsn_nl,trm_lag_char_tot,...
    iOFR_table_lin,iOFR_table_nl,ERR_table_lin,ERR_table_nl,best_mod_ind_lin,best_mod_ind_nl,Mod_Val_dat]...
    = Sys_ID_iOFRs_PRESS(RCT,mod_type,U_delay_mat,k,X,Y,Y_sim,Sim_ini_val,min_dyn_ord_u,max_dyn_ord_u,min_dyn_ord_y,max_dyn_ord_y,nl_ord_max,is_bias,inpt0,stp_cri,alph,D1_thresh,displ,x_iOFR)
%#codegen
%% Initialisation
warning('off');
size_X = size(X);
n_terms_y = sum(max_dyn_ord_y);
n_terms_u = sum(max_dyn_ord_u);
dat_len = size_X(1); %Data length
no_outpts = length(max_dyn_ord_y); % No. of outputs
no_inpts = length(max_dyn_ord_u); % No. of inputs

if length(Sim_ini_val) == 1
    if Sim_ini_val == 1 || Sim_ini_val == 0
        y_lag_lin_srt = X(1,1:n_terms_y).*Sim_ini_val;
    else
        y_lag_lin_srt = Sim_ini_val;
    end
else
    y_lag_lin_srt = Sim_ini_val;
end

n_terms_y = (max_dyn_ord_y - min_dyn_ord_y)+1; % Total number of linear output lagged terms
% Form the character-based identifiers for model terms
[trm_lag_char_lin, X] = iOFR_trm_char(no_outpts, max_dyn_ord_y, no_inpts, inpt0, max_dyn_ord_u, n_terms_y, n_terms_u, mod_type, is_bias, min_dyn_ord_y, min_dyn_ord_u, X, dat_len);
size_X = size(X);
if is_bias == 1; n_terms = size_X(2)-1; else; n_terms = size_X(2); end
dat_len = size_X(1);
% --------------------------------------------------------------------
%% --------- Model structure determination of the linear model ------------

%disp('Identifying linear model terms');
% ----------------------------------------------------------------------
trm_chsn_lin = 1:n_terms; % Linear terms currently selected
n_lin_trms = n_terms; % No. of linear terms
trm_chsn_lin_org = trm_chsn_lin;
n_lin_trms_org = n_lin_trms;
X_main = X;
n_lin_trms_rem = n_lin_trms; % No. of linear terms remaining without bias
best_msse_prev = 1;
best_press_prev = 1;

%Identify linear model
[iOFR_table_lin, trm_chsn_lin, best_press, best_msse, theta_lin, ERR_table_lin, best_mod_ind_lin] = iOFRs_lin_SysID...
    (n_lin_trms_rem, is_bias, trm_chsn_lin, n_terms, k, X_main, Y, Y_sim, n_terms_y, U_delay_mat, n_lin_trms_org,...
    y_lag_lin_srt, trm_lag_char_lin, stp_cri{1}, D1_thresh(1), alph, displ, dat_len, x_iOFR(1), best_msse_prev, best_press_prev);

if is_bias == 0
    X_main = X_main(:,trm_chsn_lin);
    trm_lag_char_lin_incld = trm_lag_char_lin(trm_chsn_lin);
    n_lin_trms = length(trm_chsn_lin);
else
    trm_chsn_lin = trm_chsn_lin(1:end-1);
    X_main = X_main(:,trm_chsn_lin);
    trm_lag_char_lin_incld = trm_lag_char_lin(trm_chsn_lin);
    n_lin_trms = length(trm_chsn_lin);

    trm_lag_char_lin = trm_lag_char_lin(1:end-1);
    X = X(:,1:end-1);
end

Mod_Val_dat = iOFR_table_lin{:,13};
theta = theta_lin;
msse_prev_best_mod_lin = best_msse;
trm_chsn_lin_prev = trm_chsn_lin;
X_main_prev = X_main;
%disp([err_type,' of best model = ',num2str(msse_prev_best_mod_lin)]);

% ---------------------------------------------------------------------------
%% --------- Model structure determination of the nonlinear model ------------
% ---------------------------------------------------------------------------

if nl_ord_max >= 2    
    % ------------- Select RCT (Reduced Computational Time) method ---------------
    [trm_lag_char_tot, X_main_org, trm_chsn_lin_org, trm_chsn_lin, n_lin_trms_org, n_lin_trms, trm_chsn_nl, n_nl_trms, trms]...
        = RCT_sel(RCT, trm_lag_char_lin_incld, X_main, trm_chsn_lin_org, trm_chsn_lin, n_lin_trms_org, n_lin_trms, nl_ord_max, trm_lag_char_lin, X, Y, alph, is_bias, dat_len);
    % ----------------------------------------------------------------------------

    % --------------- Identify Nonlinear model structure ------------------
    best_msse = msse_prev_best_mod_lin;
    n_trms = n_lin_trms + n_nl_trms; % Total no. of terms remaining without bias
    best_msse_prev = best_msse;
    best_press_prev = best_press;
    n_trms_rem = length(trms);
    if is_bias == 1;bias_trms_ind = n_trms+1;else;bias_trms_ind = 0;end

    %Identify nonlinear model
    [trm_chsn_lin_temp, iOFR_table_nl, trm_chsn_nl, best_mod_ind_nl, ERR_table_nl, trm_lag_char_tot_nl, theta_nl, X_main_nl, Mod_Val_dat_nl] = iOFRs_nl_SysID...
        (trm_chsn_lin, n_trms_rem, is_bias, trms, bias_trms_ind, k, X, X_main_org, Y, Y_sim, n_terms_y, U_delay_mat, trm_chsn_lin_org,...
        n_lin_trms_org, n_lin_trms, y_lag_lin_srt, nl_ord_max, trm_chsn_nl, trm_lag_char_tot, stp_cri{2}, alph, D1_thresh(2), displ, dat_len, x_iOFR(2), best_msse_prev, best_press_prev);
    %-------
    
    if length(theta_nl) ~= 1
        trm_lag_char_tot = trm_lag_char_tot_nl;
        trm_chsn_lin = trm_chsn_lin_temp;
        Mod_Val_dat = Mod_Val_dat_nl;
        theta = theta_nl;
        X_main = X_main_nl;
    else
        trm_lag_char_tot = trm_lag_char_lin_incld;
        trm_chsn_lin = trm_chsn_lin_prev;
        Mod_Val_dat = iOFR_table_lin{:,13};
        theta = theta_lin;
        X_main = X_main_prev;
    end
 % ---------------------------------------------------------------------
else
    iOFR_table_nl = 0; ERR_table_nl = 0; trm_lag_char_tot = trm_lag_char_lin_incld;
    trm_chsn_nl = []; best_mod_ind_nl = 0;
    if is_bias == 1; X_main = [X_main,ones(dat_len,1)]; end
end
%disp('done');
end






