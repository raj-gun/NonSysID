function  [unq_nl_comb] = nl_term_comb(max_nl_ord,n_abc)
%#codegen
%Provides the information vector for different nonlinear combinations of
%the linear information vector. max_nl_ord is the maximum order of non-linearity

 
%%

col_ind_X = (1:n_abc)'; %column indices of X

unq_nl_comb = cell(max_nl_ord,2); %cell array containing unique non-linear term combinations of each order of non-linearity
unq_nl_comb{1,1} = col_ind_X;
unq_nl_comb{1,2} = n_abc;

%% -------------- Form the superset of all possible non-linear terms ---------------------
for nl_ord = 2:max_nl_ord
    %----- Find the unique combinations of the current non-linearity ------
    nl_ord_trms = ceil(factorial(n_abc + nl_ord -1)/(factorial(nl_ord)*factorial(n_abc-1))); % no. of terms in each order of non-linearity
    unq_nl_comb{nl_ord,2} = nl_ord_trms;
    unq_nl_comb{(nl_ord),1} = zeros(nl_ord_trms,nl_ord);
    for i = 1:n_abc
        org_arry = unq_nl_comb{(nl_ord-1),1};
        str_ind = find( sum((org_arry == repmat(i,1,nl_ord-1)),2) == (nl_ord-1) );
        rpt_arry = unq_nl_comb{(nl_ord-1),1}(str_ind:end,:);
        len_rpt_arry = size(rpt_arry,1);
        
        if i == 1
            str_ind_unq_cmb = 1;
            end_ind_unq_cmb = len_rpt_arry;
        else
            str_ind_unq_cmb = end_ind_unq_cmb + 1;
            end_ind_unq_cmb = str_ind_unq_cmb + len_rpt_arry - 1;
        end
        
        unq_nl_comb{(nl_ord),1}(str_ind_unq_cmb:end_ind_unq_cmb,:) = [repmat(i,len_rpt_arry,1),rpt_arry];
       
    end
    
    nz_logic = unq_nl_comb{(nl_ord),1}(:,1) ~= 0;  
    unq_nl_comb{(nl_ord),1} = unq_nl_comb{(nl_ord),1}(nz_logic,:);
    unq_nl_comb{(nl_ord),2} = size(unq_nl_comb{(nl_ord),1}(nz_logic,:) , 1);
end

end