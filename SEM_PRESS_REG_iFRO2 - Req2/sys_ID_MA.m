function [k, model_ns, prcss_mod, theta_osa_chck_D1, val_stats] = sys_ID_MA(n_inpts, e2, a2, b2, model, u, y, RMO, nl_ord_max, is_bias, displ, epsln_osa, mod_type)
%%
% b2 = [] if model type is ErrMA
inpt0 = ones(1,n_inpts).*0;
min_dyn_ord_u = ones(1,n_inpts).*1;
max_dyn_ord_u = b2;%[a2,b2];
min_dyn_ord_e = 1;
max_dyn_ord_e = e2;
n_terms_e = sum(max_dyn_ord_e);
k = 20; %KSA predic
err_k = 2;
[~, ~, error, ~] = model_simulation(model,u,y,k);
len_diff = (length(y) - size(error,1))+1;
if mod_type == 'ErrMA'
    [~,~,~,Xe_ID,E_ID] = info_mat_sysID([],[],max_dyn_ord_e,[],error(:,err_k));
    E_simID = E_ID; Xe_simID = Xe_ID;
    U_delay_mat_simID = Xe_simID(:,1);
    Sim_ini_valID = Xe_simID(1,1:n_terms_e);
elseif mod_type == 'ErrYU'
    [~,~,~,Xe_ID,E_ID] = info_mat_sysID(inpt0,max_dyn_ord_u,max_dyn_ord_e,[y(len_diff:end),u(len_diff:end)],error(:,err_k)); %inpt0,max_dyn_ord_u,max_dyn_ord_y,u,y
    E_simID = E_ID; Xe_simID = Xe_ID;
    U_delay_mat_simID = Xe_simID(:,n_terms_e+1:end);
    Sim_ini_valID = Xe_simID(1,1:n_terms_e);
end
%% System Identification - noise model structure identification
%err_type = 'mskpe';
err_type = 'msse';
lambda_ini = 0;%1e-20; % initial lambda for regularization
stp_cri = 'PRESS_thresh';
D1_thresh = 1e-4;
x_iFRO = false;

lamda_stp = 0.2; % Stop criteria for lambda
reg_itr_end = 2; % max number of lambda updating loops
alph = 5;

[theta,~,trm_chsn_lin,trm_chsn_lin_org,n_lin_trms_org,~,trm_chsn_nl,~,iFRO_table_lin,~,ERR_table_lin,ERR_table_nl,best_mod_ind_lin,~,~]...
    = Sys_ID_SEM_PRESS_LReg_iFRO(RMO,err_type,mod_type,U_delay_mat_simID,k,Xe_ID,E_ID,E_simID,Sim_ini_valID,min_dyn_ord_u,max_dyn_ord_u,min_dyn_ord_e,max_dyn_ord_e,nl_ord_max,is_bias,inpt0,reg_itr_end,lambda_ini,lamda_stp,stp_cri,alph,D1_thresh,displ,x_iFRO);

err_sse = cell2mat( iFRO_table_lin(best_mod_ind_lin,2:4) );
if size(ERR_table_nl) ~= [1,1]
    SERR = sum(ERR_table_nl.ERR);
else
    SERR = sum(ERR_table_lin.ERR);
end
if is_bias == 0; theta_ns = theta; bias = 0; else; theta_ns = theta(1:end-1); bias = theta(end); end
model_ns = {1,e2,min_dyn_ord_u,max_dyn_ord_u,theta_ns,trm_chsn_lin,trm_chsn_lin_org,n_lin_trms_org,nl_ord_max,trm_chsn_nl,bias,inpt0,err_sse(1),err_sse(2),err_sse(3),SERR, mod_type};

% [~, error_OSA] = sim_model_noise_osa(u, y, model, model_ns);
% sse_full = mean( error_OSA.^2 , 1);
% disp('============');disp(sse);disp(sse_full);disp(e2);
%% Iternative Extended Least-Squares (ELS) for (N)ARMAX 
prcss_mod = model;
Err_prev = error(:,err_k);
% 
cnt = 0;
theta_osa_chck = zeros(1000,2);

[X_prcs, Y_prsc, is_bias, theta_procss, bias] = mod_info_mat_extrct(prcss_mod, u, y); X_prcs_sz = size(X_prcs);
while true
    cnt = cnt+1;
    % ------- Form Extended Regressor set -------
    [X_ns, ~, ~, theta_ns, ~] = mod_info_mat_extrct(model_ns, [y(len_diff:end),u(len_diff:end)], Err_prev);
    X_main1 = [X_prcs(e2+1:end,:), X_ns]; Y_main = Y_prsc(e2+1:end); dat_len = length(Y_main);
    % ------- Evalauate new process and noise model parameters -------
    theta_prev1 = [theta_procss;theta_ns];
    if is_bias == 1; X_main = [X_main1,ones(dat_len,1)]; theta_prev = [theta_prev1;bias]; end
    theta = (X_main' * X_main) \ (X_main' * Y_main);
    theta_chck = sum( abs(theta - theta_prev)./abs(theta) );
    % Update process and noise model parameters
    if is_bias == 0; theta_prcs_ns = theta; bias = 0; else; theta_prcs_ns = theta(1:end-1); bias = theta(end); end
    theta_procss = theta_prcs_ns( 1:X_prcs_sz(2) );
    theta_ns = theta_prcs_ns( X_prcs_sz(2)+1:end );
    prcss_mod{5} = theta_procss; prcss_mod{11} = bias;
    model_ns{5} = theta_ns; model_ns{11} = 0;
    % ------- Evaluate new one-step-ahead Noise -------
    [~, Err] = sim_model_noise_osa(u, y, prcss_mod, model_ns);
    Err_chck = sum( abs(Err - Err_prev).^2 );
    Err_prev = Err;
    % ------- Check if convergence is true -------
    theta_osa_chck(cnt,1) = theta_chck; theta_osa_chck(cnt,2) = Err_chck;
    if cnt >= 2
        Err_chck_D1 = Err_chck - Err_chck_prev;
        if (Err_chck_D1 <= 0) && (Err_chck_D1 >= epsln_osa); break; end
    end
    Err_chck_prev = Err_chck;
    if cnt == 1000;break;end
end
theta_osa_chck_D1 = diff(theta_osa_chck);

%% Model Validation
[~, error_SIM, ~, error_OSA, U_delay_mat] = sim_model_noise(u, y, prcss_mod, model_ns);
[dat_sim, conf_inv_sim] = ac_cc_model_valid_nl(error_SIM, U_delay_mat(:,1), size(error_SIM,1), 0);
[dat_pred, conf_inv_pred] = ac_cc_model_valid_nl(error_OSA, U_delay_mat(:,1), size(error_OSA,1), 0);
Mod_Val_dat = {cat(3, dat_sim, dat_pred), [conf_inv_sim, conf_inv_pred]};
val_stats = mod_val_stats(Mod_Val_dat);
%%
end


%%
% function noise_modl_info_mat(mod_type, max_dyn_ord_e, Err_prev)
%     if mod_type == 'ErrMA'
%         [~,~,~,Xe_ID,E_ID] = info_mat_sysID([],[],max_dyn_ord_e,[],Err_prev);
%         E_simID = E_ID; Xe_simID = Xe_ID;
%         U_delay_mat_simID = Xe_simID(:,1);
%         Sim_ini_valID = Xe_simID(1,1:n_terms_e);
%     elseif mod_type == 'ErrYU'
%         [~,~,~,Xe_ID,E_ID] = info_mat_sysID(inpt0,max_dyn_ord_u,max_dyn_ord_e,[y(len_diff:end),u(len_diff:end)],Err_prev); %inpt0,max_dyn_ord_u,max_dyn_ord_y,u,y
%         E_simID = E_ID; Xe_simID = Xe_ID;
%         U_delay_mat_simID = Xe_simID(:,n_terms_e+1:end);
%         Sim_ini_valID = Xe_simID(1,1:n_terms_e);
%     end
% end