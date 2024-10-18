% addpath('C:\Users\Rajintha\OneDrive - Coventry University\PhD project\Matlab files\SEM_PRESS_REG_iFRO2 - Req');

%%
% u = u ./ max(abs(u)); u = u';
% y = y ./ max(abs(y)); y = y';

% f1=10;
% u = sin(2*pi*f1*tspan); u = u';

% u = data_norm_phs;
% y = data_norm_amp;


% u = data_norm_phs(1:20000,1);
% y = data_norm_amp(1:20000,1);

% u = DR_sel;
% y = X_sel(:,1); %X_sel_dwn_surrgt(:,7); %

% u = DR_filt;
% y = X_filt(:,1);

% u = sub01_lac_dwn_sel(2,:)';
% y = sub01_lac_dwn_sel(1,:)';
%
%
% u = u - mean(u);
% y = y - mean(y);
% % u = u ./ max(abs(u));% u = u';
% % y = y ./ max(abs(y));% y = y';
% u = u ./ std(u);% u = u';
% y = y ./ std(y);% y = y';

%% Search space determination



% tot_search_space = combvec(search_space, search_space, search_space, search_space); tot_search_space = tot_search_space';
% tot_search_space = tot_search_space( ( tot_search_space(:,1) <= tot_search_space(:,2) ) & ( tot_search_space(:,3) <= tot_search_space(:,4) ) , : );

tot_search_space = combvec(1, [30:50]); tot_search_space = tot_search_space';
% tot_search_space = tot_search_space(31:end,:);

no_search_items = length(tot_search_space);
lag_trm_data = zeros(no_search_items,10);

%%

nl_ord_max = 2;
is_bias = 1;
displ = 0;
sv_nm = 't_5_10_a2_1_b2_30_50_';
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

cnt = 0;
%%
for sp_i = 1:no_search_items
    disp('==============');
    disp(['sp_i - ',num2str(sp_i)]);
    
    a1 = 1;%tot_search_space(sp_i,1);
    a2 = tot_search_space(sp_i,1);%tot_search_space(sp_i,2); % lagged terms output
    b1 = 1;%tot_search_space(sp_i,3);
    b2 = tot_search_space(sp_i,2);%tot_search_space(sp_i,4); % lagged terms input
    
    %% System Identification - initialisation and information matrix formulation
    
    %---------------------------------------
    n_inpts = 1;
    inpt0 = ones(1,n_inpts).*0;
    
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
    
    [theta,X_main,trm_chsn_lin,trm_chsn_lin_org,n_lin_trms_org,trm_lag_char_lin_incld,trm_chsn_nl,trm_lag_char_tot,...
        iFRO_table_lin,iFRO_table_nl,ERR_table_lin,ERR_table_nl,best_mod_ind_lin,best_mod_ind_nl]...
        = Sys_ID_SEM_PRESS_LReg_iFRO(RMO,err_type,mod_type,U_delay_mat_simID,k,X_ID,Y_ID,Y_simID,Sim_ini_valID,min_dyn_ord_u,max_dyn_ord_u,min_dyn_ord_y,max_dyn_ord_y,nl_ord_max,is_bias,inpt0,reg_itr_end,lambda_ini,lamda_stp,stp_cri,alph,displ);
    
    % -----------------------------------------
    if is_bias == 0
        theta_procss = theta;
        bias = 0;
    else
        theta_procss = theta(1:end-1);
        bias = theta(end);
    end
    
    
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
    %---------------------------
    error = Y_sim - y_est;
    dat_len_y_sim = length(Y_sim);
    msse = (error'*error)/dat_len_y_sim;
    
    error_pred = Y_sim - y_pred;
    mspe = (error_pred'*error_pred)/length(error_pred);
    
    error_kSA = Y_sim - Y_kSA;
    mskpe = (error_kSA'*error_kSA)/length(error_kSA);
    
    
    %%
    if size(ERR_table_nl,2) == 1
        no_terms = size(ERR_table_lin,1);
    else
        no_terms = size(ERR_table_nl,1);
    end
    BIC = log((1 + (length(u)./no_terms).*log(no_terms)) .* msse);
    lag_trm_data(sp_i,:) = [a1,a2,b1,b2,msse,mspe,mskpe,size(ERR_table_lin,1),size(ERR_table_nl,1),BIC]; 
    
    cnt = cnt+1;
    if cnt >= 10 || sp_i ==no_search_items
        writematrix(lag_trm_data, ['C:\Users\gunawardes\OneDrive - Coventry University\PhD project\Documents\Results\Jensen\Hyojin\lag_trm_data_',sv_nm,'msse','.csv']);
        cnt = 0;
    end
    
end
%%


