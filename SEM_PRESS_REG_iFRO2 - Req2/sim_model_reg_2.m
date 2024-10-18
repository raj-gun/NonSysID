function [Y_est] = sim_model_reg_2(theta,trm_chsn_lin,trm_chsn_lin_org,U_delay_mat,n_lin_trms,y_lag_lin_srt,nl_ord,trm_chsn_nl,bias)

% Simulate ploynomial ARX and NARX type different equation models
% n_lin_trms - number of linear terms 
% trm_chsn_lin - term indecies of chosen linear terms from the superset of terms
% max_dyn_ord - maximum dynamic order of the original superset of terms 
% U_delay_mat - Matrix containing all the linear input lagged terms (superset)
%% test
% n_lin_trms = length(trm_chsn);
% max_dyn_ord = 3;
% U_delay_mat = diff_eq_mat(nb,U,'u1');

%%
size_U_d_m = size(U_delay_mat);
dat_len = size_U_d_m(1);

y_lag_lin = y_lag_lin_srt;
Y_est = zeros(dat_len,1);

[unq_nl_comb] = nl_term_comb(nl_ord,n_lin_trms); % Evalutate nonlinear combinations 
nl_terms = sum([unq_nl_comb{2:end,2}]); % Total no. of nonlinear terms
X_nl = zeros(1,nl_terms);

for t = 1:dat_len
    
    % ------- Form linear superset of terms -----------
    u_lag_lin = U_delay_mat(t,:);
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
    
    if isempty(X_main)
        Y_est(t) = bias; % Simulate model
    else
        Y_est(t) = X_main*theta + bias; % Simulate model
    end
    
    y_lag_lin = [Y_est(t) , y_lag_lin(1:end-1)]; % Update vector containing lagged outputs
    
  
end



end