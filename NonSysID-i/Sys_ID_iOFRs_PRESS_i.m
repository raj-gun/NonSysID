function [theta,X_main,trm_chsn_lin,trm_chsn_lin_org,...
    n_lin_trms_org,trm_lag_char_lin_incld,trm_chsn_nl,...
    trm_lag_char_tot,iOFR_table_lin,iOFR_table_nl,ERR_table_lin,...
    ERR_table_nl,best_mod_ind_lin,best_mod_ind_nl,Mod_Val_dat] = ...
    Sys_ID_iOFRs_PRESS_i(RCT,mod_type,U_delay_mat,X,Y,Y_sim,...
    min_dyn_ord_u,max_dyn_ord_u,nl_ord_max,is_bias,inpt0,...
    stp_cri,alph,D1_thresh,displ,x_iOFR,parall)
%SYS_ID_IOFRS_PRESS_I Input-only PRESS/iOFR model identification.
%
% parall(1) controls parallel linear candidate evaluation.
% parall(2) controls parallel nonlinear candidate evaluation.

%#codegen
warning('off');

if ~strcmp(mod_type,'ARX-i')
    error('NonSysID-i:InvalidModelType',...
        'NonSysID-i supports mod_type = ''ARX-i'' only.');
end

size_X = size(X);
dat_len = size_X(1);
no_inpts = length(max_dyn_ord_u);

[trm_lag_char_lin,X] = iOFR_trm_char_i(no_inpts,inpt0,...
    max_dyn_ord_u,is_bias,min_dyn_ord_u,X,dat_len);

size_X = size(X);
if is_bias == 1
    n_terms = size_X(2)-1;
else
    n_terms = size_X(2);
end

trm_chsn_lin = 1:n_terms;
n_lin_trms = n_terms;
trm_chsn_lin_org = trm_chsn_lin;
n_lin_trms_org = n_lin_trms;
X_main = X;
n_lin_trms_rem = n_lin_trms;
best_msse_prev = 1;
best_press_prev = 1;

if parall(1) == 0
    [iOFR_table_lin,trm_chsn_lin,best_press,best_msse,...
        theta_lin,ERR_table_lin,best_mod_ind_lin] = ...
        iOFRs_lin_SysID_i(n_lin_trms_rem,is_bias,trm_chsn_lin,...
        n_terms,X_main,Y,Y_sim,U_delay_mat,...
        trm_lag_char_lin,stp_cri{1},D1_thresh(1),alph,displ,...
        dat_len,x_iOFR(1),best_msse_prev,best_press_prev);
else
    [iOFR_table_lin,trm_chsn_lin,best_press,best_msse,...
        theta_lin,ERR_table_lin,best_mod_ind_lin] = ...
        iOFRs_lin_SysID_P_i(n_lin_trms_rem,is_bias,trm_chsn_lin,...
        n_terms,X_main,Y,Y_sim,U_delay_mat,...
        trm_lag_char_lin,stp_cri{1},D1_thresh(1),alph,displ,...
        dat_len,x_iOFR(1),best_msse_prev,best_press_prev);
end

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

Mod_Val_dat = iOFR_table_lin{best_mod_ind_lin,13};
theta = theta_lin;
trm_chsn_lin_prev = trm_chsn_lin;
X_main_prev = X_main;

if nl_ord_max >= 2
    [trm_lag_char_tot,X_main_org,trm_chsn_lin_org,...
        trm_chsn_lin,n_lin_trms_org,n_lin_trms,trm_chsn_nl,...
        n_nl_trms,trms] = RCT_sel(RCT,trm_lag_char_lin_incld,...
        X_main,trm_chsn_lin_org,trm_chsn_lin,n_lin_trms_org,...
        n_lin_trms,nl_ord_max,trm_lag_char_lin,X,Y,alph,...
        is_bias,dat_len);

    n_trms = n_lin_trms+n_nl_trms;
    n_trms_rem = length(trms);

    if is_bias == 1
        bias_trms_ind = n_trms+1;
    else
        bias_trms_ind = 0;
    end

    if parall(2) == 0
        [trm_chsn_lin_temp,iOFR_table_nl,trm_chsn_nl,...
            best_mod_ind_nl,ERR_table_nl,trm_lag_char_tot_nl,...
            theta_nl,X_main_nl,Mod_Val_dat_nl] = ...
            iOFRs_nl_SysID_i(trm_chsn_lin,n_trms_rem,is_bias,...
            trms,bias_trms_ind,X_main_org,Y,Y_sim,U_delay_mat,...
            n_lin_trms,trm_chsn_nl,trm_lag_char_tot,stp_cri{2},alph,...
            D1_thresh(2),displ,dat_len,x_iOFR(2),best_msse,...
            best_press);
    else
        [trm_chsn_lin_temp,iOFR_table_nl,trm_chsn_nl,...
            best_mod_ind_nl,ERR_table_nl,trm_lag_char_tot_nl,...
            theta_nl,X_main_nl,Mod_Val_dat_nl] = ...
            iOFRs_nl_SysID_P_i(trm_chsn_lin,n_trms_rem,is_bias,...
            trms,bias_trms_ind,X_main_org,Y,Y_sim,U_delay_mat,...
            n_lin_trms,trm_chsn_nl,trm_lag_char_tot,stp_cri{2},alph,...
            D1_thresh(2),displ,dat_len,x_iOFR(2),best_msse,...
            best_press);
    end

    if length(theta_nl) ~= 1
        trm_lag_char_tot = trm_lag_char_tot_nl;
        trm_chsn_lin = trm_chsn_lin_temp;
        Mod_Val_dat = Mod_Val_dat_nl;
        theta = theta_nl;
        X_main = X_main_nl;
    else
        trm_lag_char_tot = trm_lag_char_lin_incld;
        trm_chsn_lin = trm_chsn_lin_prev;
        Mod_Val_dat = iOFR_table_lin{best_mod_ind_lin,13};
        theta = theta_lin;
        X_main = X_main_prev;
    end
else
    iOFR_table_nl = 0;
    ERR_table_nl = 0;
    trm_lag_char_tot = trm_lag_char_lin_incld;
    trm_chsn_nl = [];
    best_mod_ind_nl = 0;

    if is_bias == 1
        X_main = [X_main,ones(dat_len,1)];
    end
end
end
