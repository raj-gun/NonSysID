function [Y_est_sim, error_SIM, Y_est, error_OSA, U_delay_mat] = sim_model_noise(u, y, prcss_model, model_ns)

%% Process model
a1=prcss_model{1};a2=prcss_model{2};b1=prcss_model{3};b2=prcss_model{4};theta_procss=prcss_model{5};trm_chsn_lin=prcss_model{6};trm_chsn_lin_org=prcss_model{7};
n_lin_trms_org=prcss_model{8};nl_ord_max=prcss_model{9};trm_chsn_nl=prcss_model{10};bias=prcss_model{11};inpt0=prcss_model{12};

n_terms_y = sum(a2);
%---------------------------
[~,~,~,X,Y] = info_mat_sysID(inpt0,b2,a2,u,y);
X = [ X(:,a1:a2), X(:,n_terms_y+b1:end) ];
%---------------------------
y_lag_lin_srt = X(1,1:n_terms_y);
U_delay_mat = X(:,n_terms_y+1:end);
%%
size_U_d_m = size(X);
dat_len = size_U_d_m(1);

y_lag_lin = y_lag_lin_srt;
Y_est = zeros(dat_len,1);
Y_est_sim = zeros(dat_len,1);
error_OSA = zeros(dat_len,1);
error_SIM = zeros(dat_len,1);
%% Noise model
% %a1E=model_ns{1};
% a2E=model_ns{2};%b1E=model_ns{3};b2E=model_ns{4};
% theta_ns=model_ns{5};trm_chsn_linE=model_ns{6};trm_chsn_lin_orgE=model_ns{7};
% %n_lin_trms_orgE=model_ns{8};
% nl_ord_maxE=model_ns{9};%trm_chsn_nlE=model_ns{10};%biasE=model_ns{11};inpt0=model_ns{12};
% n_terms_E = sum(a2E);

%a1E=model_ns{1};
% a2E=model_ns{2};%b1E=model_ns{3};b2E=model_ns{4};
% theta_ns=model_ns{5};trm_chsn_linE=model_ns{6};trm_chsn_lin_orgE=model_ns{7};
% n_lin_trms_orgE=model_ns{8};
% nl_ord_maxE=model_ns{9};trm_chsn_nlE=model_ns{10};%biasE=model_ns{11};inpt0=model_ns{12};
% n_terms_E = sum(a2E);

a2E=model_ns{2};b1E=model_ns{3};b2E=model_ns{4};
theta_ns=model_ns{5};trm_chsn_linE=model_ns{6};trm_chsn_lin_orgE=model_ns{7};
n_lin_trms_orgE=model_ns{8};
nl_ord_maxE=model_ns{9};trm_chsn_nlE=model_ns{10};inpt0E=model_ns{12}; mod_typeE=model_ns{17}; 

n_terms_E = sum(a2E);

%---------------------------
if mod_typeE == 'ErrMA'
    [~,~,Xe,~,~] = info_mat_sysID([],[],a2E,[],error_OSA);
elseif mod_typeE == 'ErrYU'
    len_diff = (length(y) - size(error_OSA,1))+1;
    [~,~,Xe,~,~] = info_mat_sysID(inpt0E,b2E,a2E,[y(len_diff:end),u(len_diff:end)],error_OSA); %inpt0,max_dyn_ord_u,max_dyn_ord_y,u,y
end
%---------------------------
Xe = Xe(1,:);
Xe_sim = Xe(1,:);

e_lag_lin_srt = Xe_sim(1,1:n_terms_E);
U_delay_matE = Xe_sim(1,n_terms_E+1:end);
%%

[unq_nl_comb] = nl_term_comb(nl_ord_max,n_lin_trms_org); % Evalutate nonlinear combinations
nl_terms = sum([unq_nl_comb{2:end,2}]); % Total no. of nonlinear terms
X_nl = zeros(1,nl_terms);

[unq_nl_combE] = nl_term_comb(nl_ord_maxE,n_lin_trms_orgE); % Evalutate nonlinear combinations
nl_termsE = sum([unq_nl_combE{2:end,2}]); % Total no. of nonlinear terms
X_nlE = zeros(1,nl_termsE);

for t = 1:dat_len
    X_main = OSA_t( X(t,:), trm_chsn_lin, trm_chsn_lin_org, nl_ord_max, unq_nl_comb, X_nl, trm_chsn_nl );
    X_ns = OSA_t(Xe, trm_chsn_linE, trm_chsn_lin_orgE, nl_ord_maxE, unq_nl_combE, X_nlE, trm_chsn_nlE);
    Y_est(t) = [X_main, X_ns] * [theta_procss; theta_ns] + bias; % One-step ahead prediction (OSA)
    error_OSA(t) = Y(t) - Y_est(t);
    %---------------------------
    if mod_typeE == 'ErrMA'
        [~,~,Xe,~,~] = info_mat_sysID([],[],a2E,[],error_OSA);
    elseif mod_typeE == 'ErrYU'
        len_diff = (length(y) - size(error_OSA,1))+1;
        [~,~,Xe,~,~] = info_mat_sysID(inpt0E,b2E,a2E,[y(len_diff:end),u(len_diff:end)],error_OSA); %inpt0,max_dyn_ord_u,max_dyn_ord_y,u,y
    end
    %---------------------------
    Xe = Xe(t,:); % Update vector containing lagged predicted errors

    X_main_sim = SIM(y_lag_lin, U_delay_mat(t,:), trm_chsn_lin, trm_chsn_lin_org, nl_ord_max, unq_nl_comb, X_nl, trm_chsn_nl);
    X_ns_sim = SIM(e_lag_lin_srt, U_delay_matE, trm_chsn_linE, trm_chsn_lin_orgE, nl_ord_maxE, unq_nl_combE, X_nlE, trm_chsn_nlE);
    Y_est_sim(t) = [X_main_sim, X_ns_sim] * [theta_procss; theta_ns] + bias; % Simulate model (MPO)
    error_SIM(t) = Y(t) - Y_est_sim(t);
    %---------------------------
    if mod_typeE == 'ErrMA'
        [~,~,Xe_sim,~,~] = info_mat_sysID([],[],a2E,[],error_SIM);
    elseif mod_typeE == 'ErrYU'
        len_diff = (length(y) - size(error_SIM,1))+1;
        [~,~,Xe_sim,~,~] = info_mat_sysID(inpt0E,b2E,a2E,[y(len_diff:end),u(len_diff:end)],error_SIM); %inpt0,max_dyn_ord_u,max_dyn_ord_y,u,y
    end
    %---------------------------
    e_lag_lin_srt = Xe_sim(t,1:n_terms_E);
    U_delay_matE = Xe_sim(t,n_terms_E+1:end);
    %Xe_sim = [error_SIM(t), Xe_sim(1:end-1)]; % Update vector containing lagged simulated errors
    %y_lag_lin = [Y_est_sim(t) , y_lag_lin(1:end-1)]; % Update vector containing lagged simulated outputs
end

end
%%
%
%
function X_main = OSA_t(X_sup_lin, trm_chsn_lin, trm_chsn_lin_org, nl_ord_max, unq_nl_comb, X_nl, trm_chsn_nl)

X_sub_lin = X_sup_lin(:,trm_chsn_lin); % Linear subset of terms
X_sub_lin_org = X_sup_lin(:,trm_chsn_lin_org); % Initial linear subset of terms
% ---------- Nonlinear regressors are formed from X_sub_lin -----------
if nl_ord_max >= 2
    nl_ind_end = 0;
    for n = 2:nl_ord_max
        unq_comb = unq_nl_comb{(n),1};
        [X_comp] = nl_reg_data_mat(X_sub_lin_org,unq_comb);

        nl_ind = nl_ind_end + unq_nl_comb{(n),2};

        X_nl(nl_ind_end+1:nl_ind) = X_comp;

        nl_ind_end = nl_ind ;
    end

    X_main_sup = [X_sub_lin_org , X_nl];
    X_main = [X_sub_lin , X_main_sup(:,trm_chsn_nl)];
else
    X_main = X_sub_lin;
end
% ---------------------------------------------------------------------
end

function X_main = SIM(y_lag_lin, u_lag_lin, trm_chsn_lin, trm_chsn_lin_org, nl_ord, unq_nl_comb, X_nl, trm_chsn_nl)
% ------- Form linear superset of terms -----------
X_sup_lin = [y_lag_lin,u_lag_lin];
% -------------------------------------------------
X_sub_lin = X_sup_lin(:,trm_chsn_lin); % Linear subset of terms
X_sub_lin_org = X_sup_lin(:,trm_chsn_lin_org); % Initial linear subset of terms
% ---------- Nonlinear regressors are formed from X_sub_lin -----------
if nl_ord >= 2
    nl_ind_end = 0;
    for n = 2:nl_ord
        unq_comb = unq_nl_comb{(n),1};
        [X_comp] = nl_reg_data_mat(X_sub_lin_org,unq_comb);
        
        nl_ind = nl_ind_end + unq_nl_comb{(n),2};
        
        X_nl(nl_ind_end+1:nl_ind) = X_comp;
        
        nl_ind_end = nl_ind ;
    end
    
    X_main_sup = [X_sub_lin_org , X_nl];
    X_main = [X_sub_lin , X_main_sup(:,trm_chsn_nl)];
else
    X_main = X_sub_lin;
end
% ---------------------------------------------------------------------
end