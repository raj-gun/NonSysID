%addpath('C:\Users\Rajintha\OneDrive - Coventry University\PhD project\Matlab files\SEM_PRESS_REG_iFRO2 - Req');
load('C:\Users\gunawardes\OneDrive - Coventry University\PhD project\Matlab files\SEM_PRESS_REG_iFRO2 - Req\test_data.mat');

u = u - mean(u);
y = y - mean(y);
u = u ./ std(u); y = y ./ std(y);
%%
a1 = 1;
a2 = 10; % lagged terms output
b1 = 1;
b2 = 10; % lagged terms input
nl_ord_max = 2;
is_bias = 1;
displ = 0;
plt = 0;
sim = 0;
t = 1:length(u);
n_inpts = 1;
inpt0 = ones(1,n_inpts).*0;
tic
[model] = sys_ID_NARX(u,y,a1,a2,b1,b2,nl_ord_max,is_bias,displ,plt,sim,n_inpts,inpt0,t);
toc
a1=model{1};a2=model{2};b1=model{3};b2=model{4};theta_procss=model{5};trm_chsn_lin=model{6};trm_chsn_lin_org=model{7};
n_lin_trms_org=model{8};nl_ord_max=model{9};trm_chsn_nl=model{10};bias=model{11};inpt0=model{12};
%%

model = DL_model{1,1}{1,1};
a1=model{1};a2=model{2};b1=model{3};b2=model{4};theta_procss=model{5};trm_chsn_lin=model{6};trm_chsn_lin_org=model{7};
n_lin_trms_org=model{8};nl_ord_max=model{9};trm_chsn_nl=model{10};bias=model{11};inpt0=model{12};
%%
%0{
min_dyn_ord_y = a1;
max_dyn_ord_y = a2;
min_dyn_ord_u = b1;
max_dyn_ord_u = b2;
n_terms_y = sum(max_dyn_ord_y);
%---------------------------------------
[~,~,X,X_ID,~] = info_mat_sysID(inpt0, max_dyn_ord_u, max_dyn_ord_y, u, y);
X = [ X(:,min_dyn_ord_y:max_dyn_ord_y), X(:,n_terms_y+min_dyn_ord_u:end) ];
% X_ID = [ X_ID(:,min_dyn_ord_y:max_dyn_ord_y), X_ID(:,n_terms_y+min_dyn_ord_u:end) ];
n_terms_y = (max_dyn_ord_y - min_dyn_ord_y)+1;

%%Simulation - OSP and MPO
%---------------------------
Xsim_ID = X;%X_trim_ID2;
Sim_ini_val = Xsim_ID(1,1:n_terms_y);
U_delay_mat_sim = Xsim_ID(:,n_terms_y+1:end);
%---------------------------
if length(Sim_ini_val) == 1
    if Sim_ini_val == 1 || Sim_ini_val == 0
        y_lag_lin_srt = Xsim_ID(1,1:n_terms_y).*Sim_ini_val;
    else
        y_lag_lin_srt = Sim_ini_val;
    end
else
    y_lag_lin_srt = Sim_ini_val;
end
y_test = sim_model_reg_2(theta_procss,trm_chsn_lin,trm_chsn_lin_org,U_delay_mat_sim,n_lin_trms_org,y_lag_lin_srt,nl_ord_max,trm_chsn_nl,bias);

error = Y_sim - y_est;
dat_len_y_sim = length(Y_sim);
msse = (error'*error)/dat_len_y_sim;
%}

%%
%{
min_dyn_ord_u = ones(1,n_inpts).*b1;
max_dyn_ord_u = ones(1,n_inpts).*b2;
min_dyn_ord_y = a1;
max_dyn_ord_y = a2;
n_terms_y = sum(max_dyn_ord_y);
%---------------------------------------

[U_delay_mat,Y_delay_mat,X,X_ID,Y_ID] = info_mat_sysID(inpt0,max_dyn_ord_u,max_dyn_ord_y,u,y);

X_ID = [ X_ID(:,min_dyn_ord_y:max_dyn_ord_y), X_ID(:,n_terms_y+min_dyn_ord_u:end) ];
n_terms_y = (max_dyn_ord_y - min_dyn_ord_y)+1;

Y_simID = Y_ID;
X_simID = X_ID;
U_delay_mat_simID = X_simID(:,n_terms_y+1:end);
Sim_ini_valID = X_simID(1,1:n_terms_y);

%% System Identification - model identification

mod_type = 'ARX';
%err_type = 'mskpe';
err_type = 'msse';
k = 20; %KSA predic
RMO = 1; % Reduced model order for nonlinear term generation
lambda_ini = 0;%1e-20; % initial lambda for regularization
stp_cri = 'PRESS';

lamda_stp = 0.2; % Stop criteria for lambda
reg_itr_end = 2; % max number of lambda updating loops
alph = 10;
tic
[theta,X_main,trm_chsn_lin,trm_chsn_lin_org,n_lin_trms_org,trm_lag_char_lin_incld,trm_chsn_nl,trm_lag_char_tot,...
    iFRO_table_lin,iFRO_table_nl,ERR_table_lin,ERR_table_nl,best_mod_ind_lin,best_mod_ind_nl]...
    = Sys_ID_SEM_PRESS_LReg_iFRO(RMO,err_type,mod_type,U_delay_mat_simID,k,X_ID,Y_ID,Y_simID,Sim_ini_valID,min_dyn_ord_u,max_dyn_ord_u,min_dyn_ord_y,max_dyn_ord_y,nl_ord_max,is_bias,inpt0,reg_itr_end,lambda_ini,lamda_stp,stp_cri,alph,displ);
toc

disp(ERR_table_lin);
disp(sum(ERR_table_lin.ERR));
writetable(ERR_table_lin,'C:\Users\gunawardes\Desktop\ERR_table_lin.xlsx','Sheet',1,'Range','A1','WriteRowNames',true);
disp(ERR_table_nl);
if ~isa(ERR_table_nl,'double')
    disp(sum(ERR_table_nl.ERR));
    writetable(ERR_table_nl,'C:\Users\gunawardes\Desktop\ERR_table_nl.xlsx','Sheet',1,'Range','A1','WriteRowNames',true);
end

% -----------------------------------------
if is_bias == 0
    theta_procss = theta;
    bias = 0;
else
    theta_procss = theta(1:end-1);
    bias = theta(end);
end


%% Simulation - OSP and MPO
if sim == 1
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
    %---------------------------
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
end
%%
if plt == 1
    figure; ax = cell(3,1);
    ax{1}=subplot(3,1,1);plot(t(max(max_dyn_ord_y,max_dyn_ord_u)+1:end), y_est,'r--');hold on;plot(t(max(max_dyn_ord_y,max_dyn_ord_u)+1:end), Y_sim,'b--');title('MPO');
    ax{2}=subplot(3,1,2);plot(t(max(max_dyn_ord_y,max_dyn_ord_u)+1:end), y_pred,'r--');hold on;plot(t(max(max_dyn_ord_y,max_dyn_ord_u)+1:end), Y_sim,'b--');title('OSA');
    ax{3}=subplot(3,1,3);plot(t(max(max_dyn_ord_y,max_dyn_ord_u)+1:end), Y_kSA,'r--');hold on;plot(t(max(max_dyn_ord_y,max_dyn_ord_u)+1:end), Y_sim,'b--');title('kSA');
    linkaxes([ax{1},ax{2},ax{3}],'x');
    
    ac_cc_model_valid_nl(error,U_delay_mat_sim(:,1),length(error));
    ac_cc_model_valid_nl(error_pred,U_delay_mat_sim(:,1),length(error_pred));
    ac_cc_model_valid_nl(error_kSA,U_delay_mat_sim(:,1),length(error_kSA));
end
%%
model = {a1,a2,b1,b2,theta_procss,trm_chsn_lin,trm_chsn_lin_org,n_lin_trms_org,y_lag_lin_srt,nl_ord_max,trm_chsn_nl,bias,inpt0};
%}
%%

