function [U_delay_mat,Y_delay_mat,X,X_ID,Y_ID] = info_mat_sysID(min_dyn_ord_u,min_dyn_ord_y,max_dyn_ord_u,max_dyn_ord_y,u,y)

%#codegen
dat_len = size(y,1); %Data length
no_outpts = length(max_dyn_ord_y); % No. of outputs
no_inpts = length(max_dyn_ord_u); % No. of inputs
n_terms_yi = max_dyn_ord_y-min_dyn_ord_y+1; %No. of lagged terms from each output
n_terms_ui = max_dyn_ord_u-min_dyn_ord_u+1; %No. of lgged terms from each input
n_terms_y = sum(n_terms_yi);
n_terms_u = sum(n_terms_ui);

Y_delay_mat = zeros(dat_len,n_terms_y);
for j = 1:no_outpts
    if j == 1
        y_delay_temp = diff_eq_mat(max_dyn_ord_y(j),y(:,j),'y',0);
        Y_delay_mat(:,1:n_terms_yi(j)) = y_delay_temp(:,min_dyn_ord_y(j):end);
    else
        y_delay_temp = diff_eq_mat(max_dyn_ord_y(j),y(:,j),'y',0);
        strt_ind = sum( n_terms_yi(1:j-1) )+1;
        end_ind = strt_ind + n_terms_yi(j)-1;
        Y_delay_mat(: , strt_ind:end_ind) = y_delay_temp(:,min_dyn_ord_y(j):end);        
    end
end

U_delay_mat = zeros(dat_len,n_terms_u);
if ~isempty(u)
    for j = 1:no_inpts
        if j == 1
            u_delay_temp = diff_eq_mat(max_dyn_ord_u(j),u(:,j),'u1',0);
            U_delay_mat(:,1:n_terms_ui(j)) = u_delay_temp(:,min_dyn_ord_u(j):end);
        else
            u_delay_temp = diff_eq_mat(max_dyn_ord_u(j),u(:,j),'u1',0);
            strt_ind = sum( n_terms_ui(1:j-1) )+1;
            end_ind = strt_ind + n_terms_ui(j)-1;
            U_delay_mat(: , strt_ind:end_ind) = u_delay_temp(:,min_dyn_ord_u(j):end);
        end
    end
else
    U_delay_mat = [];
end

X = [Y_delay_mat,U_delay_mat];

max_dyn_ord_yu = max([max_dyn_ord_u,max_dyn_ord_y]);
X_ID = X(max_dyn_ord_yu+1:end,:);
Y_ID = y(max_dyn_ord_yu+1:end,:);

end