function [X_main, Y, is_bias, theta, bias] = mod_info_mat_extrct(model, u, y)
a1=model{1};a2=model{2};b1=model{3};b2=model{4}; theta=model{5};
trm_chsn_lin=model{6};trm_chsn_lin_org=model{7};n_lin_trms=model{8};
nl_ord=model{9};trm_chsn_nl=model{10};bias=model{11};inpt0=model{12};

n_terms_y = sum(a2);
%---------------------------
[~,~,~,X,Y] = info_mat_sysID(inpt0,b2,a2,u,y);
X = [ X(:,a1:a2), X(:,n_terms_y+b1:end) ];

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
if bias ~= 0 % If a bias is included in the model make the approriate changes
    is_bias = 1;%X_main = [X_main,ones(dat_len,1)];
else
    is_bias = 0;
end
end