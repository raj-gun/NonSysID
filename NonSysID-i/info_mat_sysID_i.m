function [U_delay_mat,X_ID,Y_ID] = info_mat_sysID_i(min_dyn_ord_u,max_dyn_ord_u,u,y)
%INFO_MAT_SYSID_I Form an input-only ARX information matrix.
%
% The candidate dictionary contains lagged input terms only. Output data are
% used solely as the dependent variable.

%#codegen
dat_len = size(y,1);
no_inpts = length(max_dyn_ord_u);
n_terms_ui = max_dyn_ord_u-min_dyn_ord_u+1;
n_terms_u = sum(n_terms_ui);

U_delay_mat = zeros(dat_len,n_terms_u);
for j = 1:no_inpts
    u_delay_temp = diff_eq_mat(max_dyn_ord_u(j),u(:,j),'u1',0);
    if j == 1
        U_delay_mat(:,1:n_terms_ui(j)) = ...
            u_delay_temp(:,min_dyn_ord_u(j):end);
    else
        strt_ind = sum(n_terms_ui(1:j-1))+1;
        end_ind = strt_ind+n_terms_ui(j)-1;
        U_delay_mat(:,strt_ind:end_ind) = ...
            u_delay_temp(:,min_dyn_ord_u(j):end);
    end
end

max_dyn_ord_u_all = max(max_dyn_ord_u);
X_ID = U_delay_mat(max_dyn_ord_u_all+1:end,:);
Y_ID = y(max_dyn_ord_u_all+1:end,:);
U_delay_mat = X_ID;
end
