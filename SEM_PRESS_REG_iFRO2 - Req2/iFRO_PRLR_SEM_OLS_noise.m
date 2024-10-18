%function iFRO_table_nl = iFRO_PRLR_SEM_OLS_nl(k,X_org,X,Y,Y_sim,frc_ind,n_terms_y,U_delay_mat,trm_chsn_lin_org,trm_chsn_lin,n_lin_trms_org,n_lin_trms,y_lag_lin_srt,nl_ord_max,trm_chsn_nl,trm_lag_char_tot,reg_itr_end,lambda_ini,lamda_stp,stp_cri,alph,D1_thresh,displ)

%%
clear;clc;

% cd '/home/gunawardes/Documents/Matlab/Sheffield HC AD';
% addpath('/home/gunawardes/Documents/Matlab/SEM_PRESS_REG_iFRO2 - Req2');
% addpath('/home/gunawardes/Documents/Matlab/NOFRF');

% cd '/home/gunawardes/Matlab/Sheffield HC AD/';
% addpath('/home/gunawardes/Matlab/SEM_PRESS_REG_iFRO2 - Req2');
% addpath('/home/gunawardes/Matlab/NOFRF');

user = 'gunawardes';%'Rajintha';%
addpath(['C:\Users\', user, '\OneDrive - Coventry University\PhD project\Matlab files\SEM_PRESS_REG_iFRO2 - Req2']);
addpath(['C:\Users\', user, '\OneDrive - Coventry University\PhD project\Matlab files\NOFRF']);
load('mod_smpl.mat','model'); load('mod_smpl_tst_sim_data.mat','u','y');
%%
nl_ord_max = 1;
n_inpts = 0;
% e2 = 5;
is_bias = 0;
displ = 0;
epsln_osa = -8e-29;
RMO = 3; % Reduced model order for nonlinear term generation

E2=zeros(20-1,3);
Val_Sts = zeros(5,2,20-1);
for e2=2:20
    [k, model_ns, prcss_mod, ~, val_stats] = sys_ID_MA(n_inpts, e2, model, u, y, RMO, nl_ord_max, is_bias, displ, epsln_osa);
    [Y_est_sim, error_SIM, Y_est, error_OSA] = sim_model_noise(u, y, prcss_mod, model_ns);
    sse_full = [mean( error_OSA.^2 , 1) , mean( error_SIM.^2 , 1)];
    [sse, y_hat, error, ~] = model_simulation(prcss_mod,u,y,k);
    
    E2(e2-1,:) = [e2,sse_full]; Val_Sts(:,:,e2-1) = val_stats(:,1:2);
end
% disp(sse);
% disp(sse_full);
% disp([var(error_SIM)/var(Y_est_sim) , var(error_OSA)/var(Y_est)]);
% disp(var(error)./var(y_hat));
%%
% cnt = 0;
% epsln_osa = -8e-29;
% theta_osa_chck = zeros(1000,2);
% while true
%     cnt = cnt+1;
%     [X_ns, Y_ns, ~, theta_ns, ~] = mod_info_mat_extrct(model_ns, [], osa_err);
%     X_prcs_sz = size(X_prcs); X_ns_sz = size(X_ns);
%     X_main = [X_prcs(e2+1:end,:), X_ns]; Y_main = Y_prsc(e2+1:end); dat_len = length(Y_main); % form extended regressor set
%     theta_prev = [theta_procss;theta_ns];
%     if is_bias == 1; X_main = [X_main,ones(dat_len,1)]; theta_prev = [theta_prev;bias]; end
%     % ------- Evalauate new process and noise model parameters -------
%     theta = (X_main' * X_main) \ (X_main' * Y_main);
%     theta_chck = sum( abs(theta - theta_prev)./abs(theta) );
%     % ------- Update process and noise model parameters -------
%     if is_bias == 0; theta_prcs_ns = theta; bias = 0; else; theta_prcs_ns = theta(1:end-1); bias = theta(end); end
%     theta_procss = theta_prcs_ns( 1:X_prcs_sz(2) );
%     theta_ns = theta_prcs_ns( X_prcs_sz(2)+1:end );
%     prccss_mod{5} = theta_procss; prccss_mod{11} = bias;
%     model_ns{5} = theta_ns; model_ns{11} = 0;
%     % ------- Evaluate new one-step-ahead Noise -------
%     if is_bias == 1; X_prcs_temp = [X_prcs,ones(X_prcs_sz(1),1)]; theta_procss_temp = [theta_procss;bias]; end
%     osa_err = Y_prsc - X_prcs_temp*theta_procss_temp;
%     [X_ns, Y_ns, ~, theta_ns, ~] = mod_info_mat_extrct(model_ns, [], osa_err);
%     X_prcs_sz = size(X_prcs); X_ns_sz = size(X_ns);
%     X_main = [X_prcs(e2+1:end,:), X_ns]; Y_main = Y_prsc(e2+1:end); dat_len = length(Y_main); % form extended regressor set
%     theta_prev = [theta_procss;theta_ns];
%     if is_bias == 1; X_main = [X_main,ones(dat_len,1)]; theta_prev = [theta_prev;bias]; end
%     % ------- Evalauate new process and noise model parameters -------
%     error_main = Y_main - X_main*theta_prev;
%
%     theta = (X_main' * X_main) \ (X_main' * Y_main);
%
%     osa_err_chck = sum( abs(osa_err - osa_err_prev).^2 );
%     osa_err_prev = osa_err;
%     % ------- Check if convergence is true -------
%     theta_osa_chck(cnt,1) = theta_chck; theta_osa_chck(cnt,2) = osa_err_chck;
%     if cnt >= 2
%         osa_err_chck_D1 = osa_err_chck - osa_err_chck_prev;
%         if (osa_err_chck_D1 <= 0) && (osa_err_chck_D1 >= epsln_osa); break; end
%     end
%     osa_err_chck_prev = osa_err_chck;
%     if cnt == 1000;break;end
% end
% theta_osa_chck_D1 = diff(theta_osa_chck);
%
% [sse, ~, error_prcs, ~] = model_simulation(prccss_mod,u,y,k);
% [sse_ns, ~, error_ns, ~] = model_simulation(model_ns,[],error_prcs(:,1),k);
% error = error_prcs(e2+1:end,:) - error_ns;
% sse_full = mean( error.^2 , 1);
% figure;plot(error_prcs(e2+1:end,1));hold on;plot(error_ns(:,1));
% disp('============');
% disp(sse);
% disp(sse_full);
% disp('============');
%%
% prccss_mod = model;
% osa_err_prev = osa_err;
% % ------- Iternative Extended Least-Square (ELS) for (N)ARMAX -------
% [X_prcs, Y_prsc, is_bias, theta_procss, bias] = mod_info_mat_extrct(prccss_mod, u, y);
% cnt = 0;
% epsln_osa = -8e-29;
% theta_osa_chck = zeros(1000,2);
% while true
%     cnt = cnt+1;
%     [X_ns, Y_ns, ~, theta_ns, ~] = mod_info_mat_extrct(model_ns, [], osa_err);
%     X_prcs_sz = size(X_prcs); X_ns_sz = size(X_ns);
%     X_main = [X_prcs(e2+1:end,:), X_ns]; Y_main = Y_prsc(e2+1:end); dat_len = length(Y_main); % form extended regressor set
%     theta_prev = [theta_procss;theta_ns];
%     if is_bias == 1; X_main = [X_main,ones(dat_len,1)]; theta_prev = [theta_prev;bias]; end
%     % ------- Evalauate new process and noise model parameters -------
%     theta = (X_main' * X_main) \ (X_main' * Y_main);
%     theta_chck = sum( abs(theta - theta_prev)./abs(theta) );
%     % ------- Update process and noise model parameters -------
%     if is_bias == 0; theta_prcs_ns = theta; bias = 0; else; theta_prcs_ns = theta(1:end-1); bias = theta(end); end
%     theta_procss = theta_prcs_ns( 1:X_prcs_sz(2) );
%     theta_ns = theta_prcs_ns( X_prcs_sz(2)+1:end );
%     prccss_mod{5} = theta_procss; prccss_mod{11} = bias;
%     model_ns{5} = theta_ns; model_ns{11} = 0;
%     % ------- Evaluate new one-step-ahead Noise -------
%     if is_bias == 1; X_prcs_temp = [X_prcs,ones(X_prcs_sz(1),1)]; theta_procss_temp = [theta_procss;bias]; end
%     osa_err = Y_prsc - X_prcs_temp*theta_procss_temp;
%     osa_err_chck = sum( abs(osa_err - osa_err_prev).^2 );
%     osa_err_prev = osa_err;
%     % ------- Check if convergence is true -------
%     theta_osa_chck(cnt,1) = theta_chck; theta_osa_chck(cnt,2) = osa_err_chck;
%     if cnt >= 2
%         osa_err_chck_D1 = osa_err_chck - osa_err_chck_prev;
%         if (osa_err_chck_D1 <= 0) && (osa_err_chck_D1 >= epsln_osa); break; end
%     end
%     osa_err_chck_prev = osa_err_chck;
%     if cnt == 1000;break;end
% end
% theta_osa_chck_D1 = diff(theta_osa_chck);
%
% [sse, ~, error_prcs, ~] = model_simulation(prccss_mod,u,y,k);
% [sse_ns, ~, error_ns, ~] = model_simulation(model_ns,[],error_prcs(:,1),k);
% error = error_prcs(e2+1:end,:) - error_ns;
% sse_full = mean( error.^2 , 1);
% figure;plot(error_prcs(e2+1:end,1));hold on;plot(error_ns(:,1));
% disp('============');
% disp(sse);
% disp(sse_full);
% disp('============');
%%
% prccss_mod = model;
% osa_err_prev = osa_err(e2+1:end);
% % ------- Iternative Extended Least-Square (ELS) for (N)ARMAX -------
% [X_prcs, Y_prsc, is_bias, theta_procss, bias] = mod_info_mat_extrct(prccss_mod, u, y);
% cnt = 0;
% epsln_osa = -8e-30;
% while true
%     cnt = cnt+1;
%     [X_ns, Y_ns, ~, theta_ns, ~] = mod_info_mat_extrct(model_ns, [], osa_err);
%     X_prcs_sz = size(X_prcs); X_ns_sz = size(X_ns);
%     X_main = [X_prcs(e2+1:end,:), X_ns]; Y_main = Y_prsc(e2+1:end); dat_len = length(Y_main); % form extended regressor set
%     theta_prev = [theta_procss;theta_ns];
%     if is_bias == 1; X_main = [X_main,ones(dat_len,1)]; theta_prev = [theta_prev;bias]; end
%     % ------- Evalauate new process and noise model parameters -------
%     theta = (X_main' * X_main) \ (X_main' * Y_main);
%     theta_chck = sum( abs(theta - theta_prev)./abs(theta) );
%     % ------- Evaluate new one-step-ahead Noise -------
%     osa_err = Y_main - X_main*theta;
%     osa_err_chck = sum( abs(osa_err - osa_err_prev).^2 );
%     % ------- Update process and noise model parameters -------
%     if is_bias == 0; theta_prcs_ns = theta; bias = 0; else; theta_prcs_ns = theta(1:end-1); bias = theta(end); end
%     theta_procss = theta_prcs_ns( 1:X_prcs_sz(2) );
%     theta_ns = theta_prcs_ns( X_prcs_sz(2)+1:end );
%     prccss_mod{5} = theta_procss; prccss_mod{11} = bias;
%     model_ns{5} = theta_ns; model_ns{11} = 0;
%     % ------- Update new one-step-ahead Noise -------
%     if is_bias == 1; X_prcs_temp = [X_prcs,ones(X_prcs_sz(1),1)]; theta_procss_temp = [theta_procss;bias]; end
%     osa_err_temp = Y_prsc - X_prcs_temp*theta_procss_temp;
%     osa_err = [osa_err_temp(1:e2);osa_err];
%     osa_err_prev = osa_err(e2+1:end);
%     % ------- Check if convergence is true -------
%     if cnt >= 2
%         osa_err_chck_D1 = osa_err_chck - osa_err_chck_prev;
%         if (osa_err_chck_D1 <= 0) && (osa_err_chck_D1 >= epsln_osa); break; end
%     end
%     osa_err_chck_prev = osa_err_chck;
% end
%
% [sse, ~, error_prcs, ~] = model_simulation(prccss_mod,u,y,k);
% [sse_ns, ~, error_ns, ~] = model_simulation(model_ns,[],error_prcs(:,1),k);
% error = error_prcs(e2+1:end,:) - error_ns;
% sse_full = mean( error.^2 , 1);
% % figure;plot(error_prcs(e2+1:end,1));hold on;plot(error_ns(:,1));
% disp('============');
% disp(sse);
% disp(sse_full);
% disp('============');
%%
%end