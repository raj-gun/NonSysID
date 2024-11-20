function [trm_lag_char_tot,trm_chsn_nl,X_main_org,unq_nl_comb] = generate_nl_reg(nl_ord_max,X_main_lin,X_main_org,n_lin_trms,n_lin_trms_org,trm_lag_char_lin_incld,trm_lag_char_tot)

nl_loop_cnt = 0;
nl_ord = 2;

[unq_nl_comb] = nl_term_comb(nl_ord_max,n_lin_trms_org); % Evalutate nonlinear combinations 

while true 

nl_loop_cnt = nl_loop_cnt + 1;

unq_comb = unq_nl_comb{nl_ord}; % Nonlinear combination of lagged terms
nl_terms_temp = unq_nl_comb{nl_ord,2}; % Number of nonlinear lagged terms in the current nonlinearity 


% ----------------- Compose nonlinear lagged terms ----------------------
if ~isempty(X_main_lin)
    [X_nl_temp] = nl_reg_data_mat(X_main_lin,unq_comb); % Nonlinear regressors of the current nonlinearity
    
    X_main_org_temp = [X_main_org , X_nl_temp]; % Update superset of regressors
    X_main_org = X_main_org_temp;
end
% -----------------------------------------------------------------------


% ----- Charater identifiers of the nonlinear lagged terms --------------
if ~isempty(trm_lag_char_tot)
    trm_lag_char_nl = cell(1,nl_terms_temp);
    char_temp = trm_lag_char_lin_incld(unq_comb);
    for i = 1:nl_terms_temp
        trm_lag_char_nl{i} = [char_temp{i,:}];
    end
    trm_lag_char_tot_temp = [trm_lag_char_tot , trm_lag_char_nl]; % Character identifiers of all the current linear and nonlinear lagged terms
    trm_lag_char_tot =  trm_lag_char_tot_temp;
end
% -----------------------------------------------------------------------


% ----------- Indecies of all current nonlinear terms --------------------
if nl_loop_cnt == 1
    trm_chsn_nl = ([1:nl_terms_temp] + n_lin_trms);
else
    trm_chsn_nl_temp = [trm_chsn_nl , ([1:nl_terms_temp] + trm_chsn_nl_end)];
    trm_chsn_nl = trm_chsn_nl_temp;
end
trm_chsn_nl_end = trm_chsn_nl(end);

if nl_ord == nl_ord_max
    break;
end
nl_ord = nl_ord + 1;
% ------------------------------------------------------------------------

end




end