function [AIC,BIC] = AIC_BIC(err_var,no_terms,N)
AIC = log((1 + 2.*(no_terms./N)) .* err_var);
BIC = log((1 + (N./no_terms).*log(no_terms)) .* err_var);
end