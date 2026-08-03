function [trm_lag_char_lin,X] = iOFR_trm_char_i(no_inpts,inpt0,...
    max_dyn_ord_u,is_bias,min_dyn_ord_u,X,dat_len)
%IOFR_TRM_CHAR_I Character identifiers for input-only ARX-i regressors.

n_terms_ui = max_dyn_ord_u-min_dyn_ord_u+1;
n_terms_u = sum(n_terms_ui);

trm_delay_U = cell(1,no_inpts);
for j = 1:no_inpts
    if inpt0(j) == 0
        trm_delay_U{j} = -1.*(min_dyn_ord_u(j):max_dyn_ord_u(j))';
    else
        trm_delay_U{j} = -1.*(0:max_dyn_ord_u(j)-1)';
    end
end

u_lag_char = cell(n_terms_u,1);
loop_cnt = 1;
for j = 1:no_inpts
    for i = 1:n_terms_ui(j)
        u_lag_char{loop_cnt} = sprintf('u%d(t%d)',j,trm_delay_U{j}(i));
        loop_cnt = loop_cnt+1;
    end
end

if is_bias == 0
    trm_lag_char_lin = u_lag_char';
else
    trm_lag_char_lin = [u_lag_char','bias'];
    X = [X,ones(dat_len,1)];
end
end
