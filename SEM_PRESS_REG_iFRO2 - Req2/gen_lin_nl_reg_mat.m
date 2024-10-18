function [X_main] = gen_lin_nl_reg_mat(X,trm_chsn_lin,trm_chsn_lin_org,n_lin_trms,nl_ord,trm_chsn_nl)

% Generate linear and nonlinear lagged terms 
% n_lin_trms - number of linear terms
% trm_chsn_lin - term indecies of chosen linear terms from the superset of terms
% max_dyn_ord - maximum dynamic order of the original superset of terms
% U_delay_mat - Matrix containing all the linear input lagged terms (superset)

%%
size_X = size(X);
dat_len = size_X(1);

[unq_nl_comb] = nl_term_comb(nl_ord,n_lin_trms); % Evalutate nonlinear combinations
nl_terms = sum([unq_nl_comb{2:end,2}]); % Total no. of nonlinear terms
X_nl = zeros(dat_len,nl_terms);


X_sub_lin = X(:,trm_chsn_lin); % Linear subset of terms
X_sub_lin_org = X(:,trm_chsn_lin_org); % Initial linear subset of terms

% ---------- Nonlinear regressors are formed from X_sub_lin -----------
if nl_ord >= 2
    nl_ind_end = 0;
    for n = 2:nl_ord
        unq_comb = unq_nl_comb{(n),1};
        [X_comp] = nl_reg_data_mat(X_sub_lin_org,unq_comb);
        
        nl_ind = nl_ind_end + unq_nl_comb{(n),2};
                    
        X_nl(:,nl_ind_end+1:nl_ind) = X_comp;
        
        nl_ind_end = nl_ind ;
    end
    
    X_main_sup = [X_sub_lin_org , X_nl];
    X_main = [X_sub_lin , X_main_sup(:,trm_chsn_nl)];
else
    X_main = X_sub_lin;
end
% ---------------------------------------------------------------------



end