function [U_delay_mat,Y_delay_mat,X,X_ID,Y_ID] = info_mat_sysID(inpt0,max_dyn_ord_u,max_dyn_ord_y,u,y)

%#codegen
dat_len = size(y,1); %Data length
no_outpts = length(max_dyn_ord_y); % No. of outputs
no_inpts = length(max_dyn_ord_u); % No. of inputs
n_terms_y = sum(max_dyn_ord_y);
n_terms_u = sum(max_dyn_ord_u);


Y_delay_mat = zeros(dat_len,n_terms_y);
for j = 1:no_outpts
    if j == 1
        Y_delay_mat(:,1:max_dyn_ord_y(j)) = diff_eq_mat(max_dyn_ord_y(j),y(:,j),'y',0);
    else
        Y_delay_mat(:, sum( max_dyn_ord_y(1:(j-1)) )+1 : sum( max_dyn_ord_y(1:j) ) ) = diff_eq_mat(max_dyn_ord_y(j),y(:,j),'y',0);
    end
end

U_delay_mat = zeros(dat_len,n_terms_u);
if ~isempty(u)
    for j = 1:no_inpts
        if j == 1
            if inpt0(j) == 0
                U_delay_mat(:,1:max_dyn_ord_u(j)) = diff_eq_mat(max_dyn_ord_u(j),u(:,j),'u1',0);
            else
                U_delay_mat(:,1:max_dyn_ord_u(j)) = diff_eq_mat(max_dyn_ord_u(j),u(:,j),'u',0);
            end
        else
            if inpt0(j) == 0
                U_delay_mat(:, sum( max_dyn_ord_u(1:(j-1)) )+1 : sum( max_dyn_ord_u(1:j) ) ) = diff_eq_mat(max_dyn_ord_u(j),u(:,j),'u1',0);
            else
                U_delay_mat(:, sum( max_dyn_ord_u(1:(j-1)) )+1 : sum( max_dyn_ord_u(1:j) ) ) = diff_eq_mat(max_dyn_ord_u(j),u(:,j),'u',0);
            end
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