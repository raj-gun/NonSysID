function [model, Mod_Val_dat, iOFR_table_lin, iOFR_table_nl, best_mod_ind_lin, best_mod_ind_nl, val_stats] = NonSysID(mod_type,u,y,a1,a2,b1,b2,nl_ord_max,is_bias,n_inpts,KSA_h,RCT,x_iOFR,stp_cri,D1_thresh,displ,sim,parall)

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
%---------------------------------------

[~,~,~,X_ID,Y_ID] = info_mat_sysID(min_dyn_ord_u,min_dyn_ord_y,max_dyn_ord_u,max_dyn_ord_y,u,y);

Y_simID = Y_ID;
X_simID = X_ID;
U_delay_mat_simID = X_simID(:,n_terms_y+1:end);
Sim_ini_valID = X_simID(1,1:n_terms_y);

%% System Identification - model identification

[theta,~,trm_chsn_lin,trm_chsn_lin_org,n_lin_trms_org,~,trm_chsn_nl,~,iOFR_table_lin,iOFR_table_nl,ERR_table_lin,ERR_table_nl,best_mod_ind_lin,best_mod_ind_nl,Mod_Val_dat]...
    = Sys_ID_iOFRs_PRESS(RCT,mod_type,U_delay_mat_simID,KSA_h,X_ID,Y_ID,Y_simID,Sim_ini_valID,min_dyn_ord_u,max_dyn_ord_u,min_dyn_ord_y,max_dyn_ord_y,nl_ord_max,is_bias,inpt0,stp_cri,5,D1_thresh,displ,x_iOFR,parall);

if size(ERR_table_nl) ~= [1,1]
    SERR = sum(ERR_table_nl.ERR);
    val_stats = iOFR_table_nl{best_mod_ind_nl,16};
else
    SERR = sum(ERR_table_lin.ERR);
    val_stats = 0;
end

% -----------------------------------------
if is_bias == 0;theta_procss = theta;bias = 0;else;theta_procss = theta(1:end-1);bias = theta(end);end

%% Simulation - OSA and MPO
if sim(1) == 1
    %---------------------------
    Y_sim = Y_ID;%Y_trim_ID2;
    Xsim_ID = X_ID;%X_trim_ID2;
    y_lag_lin_srt = Xsim_ID(1,1:n_terms_y);
    U_delay_mat_sim = Xsim_ID(:,n_terms_y+1:end);
    %---------------------------
    [y_pred] = one_step_pred_model_reg(Xsim_ID,theta_procss,trm_chsn_lin,trm_chsn_lin_org,n_lin_trms_org,nl_ord_max,trm_chsn_nl,bias);

    [y_est] = sim_model_reg_2(theta_procss,trm_chsn_lin,trm_chsn_lin_org,U_delay_mat_sim,n_lin_trms_org,y_lag_lin_srt,nl_ord_max,trm_chsn_nl,bias);

    [Y_kSA] = k_step_pred_model_reg(KSA_h,n_terms_y,Xsim_ID,theta_procss,trm_chsn_lin,trm_chsn_lin_org,n_lin_trms_org,nl_ord_max,trm_chsn_nl,bias);
    %---------------------------
    error = Y_sim - y_est;
    dat_len_y_sim = length(Y_sim);
    msse = (error'*error)/dat_len_y_sim;

    error_pred = Y_sim - y_pred;
    mspe = (error_pred'*error_pred)/length(error_pred);

    error_kSA = Y_sim - Y_kSA;
    mskpe = (error_kSA'*error_kSA)/length(error_kSA);

    if sim(2) == 1
        figure;
        subplot(3,1,1);plot(Y_sim, 'Color', '#77AC30', 'LineWidth', 1.5);hold on;plot(y_est,'k-.', 'LineWidth',1.25);hold off; title('MPO/Free-run');
        legend('Actual Output','Model generated');
        subplot(3,1,2);plot(Y_sim, 'Color', '#77AC30', 'LineWidth', 1.5);hold on;plot(Y_kSA,'k-.', 'LineWidth',1.25);hold off; title([num2str(KSA_h),'-steps Ahead Prediction']);
        subplot(3,1,3);plot(Y_sim, 'Color', '#77AC30', 'LineWidth', 1.5);hold on;plot(y_pred,'k-.', 'LineWidth',1.25);hold off; title('One-step Ahead Prediction/Free-run');

        disp('--------------------');
        disp(['MSSE = ',num2str(msse)]);
        disp(['MSkPE = ',num2str(mskpe)]);
        disp(['MSPE = ',num2str(mspe)]);
        disp('--------------------');
    end
end
%%

%% Output identyfied model with information related to the model
if sim(1) == 0
    model = {a1,a2,b1,b2,theta_procss,trm_chsn_lin,trm_chsn_lin_org,n_lin_trms_org,nl_ord_max,trm_chsn_nl,bias,n_inpts,Sim_ini_valID,SERR};
else
    model = {a1,a2,b1,b2,theta_procss,trm_chsn_lin,trm_chsn_lin_org,n_lin_trms_org,nl_ord_max,trm_chsn_nl,bias,n_inpts,Sim_ini_valID,msse,mspe,mskpe,SERR};
end
end