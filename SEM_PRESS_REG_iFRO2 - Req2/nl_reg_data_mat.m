function [X_comp] = nl_reg_data_mat(X,unq_comb)
%#codegen
%Returns the data matrix with all possible nonlinear combinations. 

size_X = size(X);
no_trm = size(unq_comb,1);
t_len = size_X(1);

X_comp = zeros(t_len,no_trm);

%----- Compose the non-linear regression data matrix of the non-linearity ------
for i2 = 1:no_trm
    X_comp(:,i2) = prod(X(:,unq_comb(i2,:)),2);
end


end