function [model, Mod_Val_dat, iFRO_table_lin, iFRO_table_nl, best_mod_ind_lin, best_mod_ind_nl, val_stats] = sys_ID_NARX(u,y,a1,a2,b1,b2,nl_ord_max,is_bias,displ,sim,n_inpts,inpt0,RMO)

%%
min_dyn_ord_u = ones(1,n_inpts).*b1;
max_dyn_ord_u = ones(1,n_inpts).*b2;
min_dyn_ord_y = a1;
max_dyn_ord_y = a2;
n_terms_y = sum(max_dyn_ord_y);
%---------------------------------------

[~,~,~,X_ID,Y_ID] = info_mat_sysID(inpt0,max_dyn_ord_u,max_dyn_ord_y,u,y);

X_ID = [ X_ID(:,min_dyn_ord_y:max_dyn_ord_y).*0, X_ID(:,n_terms_y+min_dyn_ord_u:end) ];
n_terms_y = (max_dyn_ord_y - min_dyn_ord_y)+1;

Y_simID = Y_ID;
X_simID = X_ID;
U_delay_mat_simID = X_simID(:,n_terms_y+1:end);
Sim_ini_valID = X_simID(1,1:n_terms_y).*1;

%% System Identification - model identification

mod_type = 'ARX';
%err_type = 'mskpe';
err_type = 'msse';
k = 20; %KSA predic
% RMO = 0; % Reduced model order for nonlinear term generation |  20-expanded search 21-expanded search with choosen lin terms
lambda_ini = 0;%1e-20; % initial lambda for regularization
stp_cri = 'PRESS_thresh';
D1_thresh = 1e-4;
x_iFRO = false;

lamda_stp = 0.2; % Stop criteria for lambda
reg_itr_end = 2; % max number of lambda updating loops
alph = 5;
% tic
[theta,~,trm_chsn_lin,trm_chsn_lin_org,n_lin_trms_org,~,trm_chsn_nl,~,iFRO_table_lin,iFRO_table_nl,ERR_table_lin,ERR_table_nl,best_mod_ind_lin,best_mod_ind_nl,Mod_Val_dat]...
    = Sys_ID_SEM_PRESS_LReg_iFRO(RMO,err_type,mod_type,U_delay_mat_simID,k,X_ID,Y_ID,Y_simID,Sim_ini_valID,min_dyn_ord_u,max_dyn_ord_u,min_dyn_ord_y,max_dyn_ord_y,nl_ord_max,is_bias,inpt0,reg_itr_end,lambda_ini,lamda_stp,stp_cri,alph,D1_thresh,displ,x_iFRO);
% toc

if size(ERR_table_nl) ~= [1,1]
    SERR = sum(ERR_table_nl.ERR);
    val_stats = iFRO_table_nl{best_mod_ind_nl,16};
else
    SERR = sum(ERR_table_lin.ERR);
    val_stats = 0;
end

% -----------------------------------------
if is_bias == 0;theta_procss = theta;bias = 0;else;theta_procss = theta(1:end-1);bias = theta(end);end

%% Simulation - OSP and MPO
if sim(1) == 1
    %---------------------------
    Y_sim = Y_ID;%Y_trim_ID2;
    Xsim_ID = X_ID;%X_trim_ID2;
    y_lag_lin_srt = Xsim_ID(1,1:n_terms_y);
    U_delay_mat_sim = Xsim_ID(:,n_terms_y+1:end);
    %---------------------------
    [y_pred] = one_step_pred_model_reg(Xsim_ID,theta_procss,trm_chsn_lin,trm_chsn_lin_org,n_lin_trms_org,nl_ord_max,trm_chsn_nl,bias);

    [y_est] = sim_model_reg_2(theta_procss,trm_chsn_lin,trm_chsn_lin_org,U_delay_mat_sim,n_lin_trms_org,y_lag_lin_srt,nl_ord_max,trm_chsn_nl,bias);

    [Y_kSA] = k_step_pred_model_reg(k,n_terms_y,Xsim_ID,theta_procss,trm_chsn_lin,trm_chsn_lin_org,n_lin_trms_org,nl_ord_max,trm_chsn_nl,bias);
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
        subplot(3,1,1);plot(Y_sim);hold on;plot(y_est);hold off;
        subplot(3,1,2);plot(Y_sim);hold on;plot(Y_kSA);hold off;
        subplot(3,1,3);plot(Y_sim);hold on;plot(y_pred);hold off;

        disp('--------------------');
        disp(['MSSE = ',num2str(msse)]);
        disp(['MSkPE = ',num2str(mskpe)]);
        disp(['MSPE = ',num2str(mspe)]);
        disp('--------------------');
    end
end
%%

%%
if sim(1) == 0
    model = {a1,a2,b1,b2,theta_procss,trm_chsn_lin,trm_chsn_lin_org,n_lin_trms_org,nl_ord_max,trm_chsn_nl,bias,inpt0,Sim_ini_valID,SERR};
else
    model = {a1,a2,b1,b2,theta_procss,trm_chsn_lin,trm_chsn_lin_org,n_lin_trms_org,nl_ord_max,trm_chsn_nl,bias,inpt0,Sim_ini_valID,msse,mspe,mskpe,SERR};
end
end