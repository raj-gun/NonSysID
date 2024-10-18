
u = u ./ max(abs(u));
y = y ./ max(abs(y));

%% System Identification - initialisation and information matrix formulation

%---------------------------------------
n_inpts = 1;
inpt0 = ones(1,n_inpts).*0;

max_dyn_ord_u = ones(1,n_inpts).*5;
max_dyn_ord_y = 5;
k = 100;
n_terms_y = sum(max_dyn_ord_y);
n_terms_u = sum(max_dyn_ord_u);
max_dyn_ord_yu = max([max_dyn_ord_u,max_dyn_ord_y]);
%---------------------------------------



[U_delay_mat,Y_delay_mat,X,X_ID,Y_ID] = info_mat_sysID(inpt0,max_dyn_ord_u,max_dyn_ord_y,u,y);

% a = 42; b = 60;
% [~,~,~,X_trim_ID,Y_trim_ID] = info_mat_sysID(inpt0,max_dyn_ord_u,max_dyn_ord_y,u(a:b,:),y(a:b,:));
% %[~,~,~,X_trim_ID,Y_trim_ID] = info_mat_sysID(inpt0,max_dyn_ord_u,max_dyn_ord_y,[],y(a:b));
% 
% 
% a2 = a; b2 = b;
% [~,~,~,X_trim_ID2,Y_trim_ID2] = info_mat_sysID(inpt0,max_dyn_ord_u,max_dyn_ord_y,u(a2:b2,:),y(a2:b2,:));
% 
% 
% 
% X_ID = X_trim_ID;%X_all_ID;%
% Y_ID = Y_trim_ID;%Y_all_ID;%

%---------------------------------

Y_simID = Y_ID;%Y_trim_ID2;%Y_all_ID;%
X_simID = X_ID;%X_trim_ID2;%X_all_ID;%
U_delay_mat_simID = X_simID(:,n_terms_y+1:end);
Sim_ini_valID = X_simID(1,1:n_terms_y);


%% System Identification - model identification

nl_ord_max = 2;
is_bias = 1;
displ = 1;

mod_type = 'ARX';
%err_type = 'mskpe';
err_type = 'msse';
RMO = 0;
lambda_ini = 0;%1e-5; % initial lambda for regularization 
stp_cri = 'PRESS';

lamda_stp = 0.2; % Stop criteria for lambda 
reg_itr_end = 1; % max number of lambda updating loops
alph = 10;
%tic
[theta,X_main,trm_chsn_lin,trm_chsn_lin_org,n_lin_trms_org,trm_lag_char_lin_incld,trm_chsn_nl,trm_lag_char_tot,...
    iFRO_table_lin,iFRO_table_nl,ERR_table_lin,ERR_table_nl,best_mod_ind_lin,best_mod_ind_nl]...
    = Sys_ID_SEM_PRESS_LReg_iFRO(RMO,err_type,mod_type,U_delay_mat_simID,k,X_ID,Y_ID,Y_simID,Sim_ini_valID,max_dyn_ord_u,max_dyn_ord_y,nl_ord_max,is_bias,inpt0,reg_itr_end,lambda_ini,lamda_stp,stp_cri,alph,displ);
%toc

disp(ERR_table_lin);
disp(ERR_table_nl);

% -----------------------------------------
if is_bias == 0
    theta_procss = theta;
    bias = 0;
else
    theta_procss = theta(1:end-1);
    bias = theta(end);
end



%%

%% Simulation - OSP and MPO

%---------------------------
Y_sim = Y_ID;%Y_trim_ID2;
Xsim_ID = X_ID;%X_trim_ID2;
Sim_ini_val = Xsim_ID(1,1:n_terms_y);
U_delay_mat_sim = Xsim_ID(:,n_terms_y+1:end);
%---------------------------


[y_pred] = one_step_pred_model_reg(Xsim_ID,theta_procss,trm_chsn_lin,trm_chsn_lin_org,n_lin_trms_org,nl_ord_max,trm_chsn_nl,bias);

if length(Sim_ini_val) == 1
    if Sim_ini_val == 1 || Sim_ini_val == 0
        y_lag_lin_srt = Xsim_ID(1,1:n_terms_y).*Sim_ini_val;
    else
        y_lag_lin_srt = Sim_ini_val;
    end
else
    y_lag_lin_srt = Sim_ini_val;
end

[y_est] = sim_model_reg_2(theta_procss,trm_chsn_lin,trm_chsn_lin_org,U_delay_mat_sim,n_lin_trms_org,y_lag_lin_srt,nl_ord_max,trm_chsn_nl,bias);

[Y_kSA] = k_step_pred_model_reg(k,n_terms_y,Xsim_ID,theta_procss,trm_chsn_lin,trm_chsn_lin_org,n_lin_trms_org,nl_ord_max,trm_chsn_nl,bias);


error = Y_sim - y_est;
dat_len_y_sim = length(Y_sim);
msse = (error'*error)/dat_len_y_sim;
disp(['msse = ' , num2str(msse)]);

error_pred = Y_sim - y_pred;
mspe = (error_pred'*error_pred)/length(error_pred);
disp(['mspe = ' , num2str(mspe)]);

error_kSA = Y_sim - Y_kSA;
mskpe = (error_kSA'*error_kSA)/length(error_kSA);
disp(['mskpe = ' , num2str(mskpe)]);


figure;plot(y_est,'-o');hold on
plot(Y_sim,'-o');title('MPO');

figure;plot(y_pred,'-o');hold on
plot(Y_sim,'-o');title('OSA');

figure;plot(Y_kSA,'-o');hold on
plot(Y_sim,'-o');title('kSA');



