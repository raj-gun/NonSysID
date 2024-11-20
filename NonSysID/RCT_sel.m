function [trm_lag_char_tot, X_main_org, trm_chsn_lin_org, trm_chsn_lin, n_lin_trms_org, n_lin_trms, trm_chsn_nl, n_nl_trms, trms] = RCT_sel(RCT, trm_lag_char_lin_incld, X_main, trm_chsn_lin_org, trm_chsn_lin, n_lin_trms_org, n_lin_trms, nl_ord_max, trm_lag_char_lin, X, Y, alph, is_bias, dat_len)
if RCT == 1
    trm_chsn_lin_org = trm_chsn_lin;
    n_lin_trms_org = n_lin_trms;
    [trm_lag_char_tot,trm_chsn_nl,X_main_org,~] = generate_nl_reg(nl_ord_max,X_main,X_main,n_lin_trms,n_lin_trms,trm_lag_char_lin_incld,...
        trm_lag_char_lin_incld); % Generate the nonlinear lagged terms using different combinations of the chosen linear lagged terms from the ARX model
    n_lin_trms = length(trm_chsn_lin);
    n_nl_trms = length(trm_chsn_nl);
    n_trms_rem = n_lin_trms + n_nl_trms; % Total no. of terms remaining without bias
    trms = 1:n_trms_rem; %Pre-selected terms
elseif RCT == 2 
    [~,~,~,~,X_main,~,~,trm_lag_char_tot_RMO] = OFR_RCT(X,Y,trm_chsn_lin_org,n_lin_trms_org,nl_ord_max,trm_lag_char_lin); % Obtain overfitting NARX model
    [trm_lag_char_tot,trm_chsn_nl,X_main_org,~] = generate_nl_reg(nl_ord_max,X,X,n_lin_trms_org,n_lin_trms_org,trm_lag_char_lin,trm_lag_char_lin);
    n_nl_trms = length(trm_chsn_nl);
    trm_chsn_lin = trm_chsn_lin_org;
    n_lin_trms = n_lin_trms_org;

    rmo_len_char = length(trm_lag_char_tot_RMO);
    len_char = length(trm_lag_char_tot);
    trms = zeros(1,rmo_len_char);
    for j=1:rmo_len_char
        for i=1:len_char
            if strcmp(trm_lag_char_tot{1,i}, trm_lag_char_tot_RMO{1,j});trms(j) = i;end
        end
    end
elseif RCT == 3
    [~,~,~,~,~,~,~,trm_lag_char_tot_RMO] = OFR_RCT(X_main,Y,trm_chsn_lin,n_lin_trms,nl_ord_max,trm_lag_char_lin_incld);
    trm_chsn_lin_org = trm_chsn_lin;
    n_lin_trms_org = n_lin_trms;
    [trm_lag_char_tot,trm_chsn_nl,X_main_org,~] = generate_nl_reg(nl_ord_max,X_main,X_main,n_lin_trms,n_lin_trms,trm_lag_char_lin_incld,...
        trm_lag_char_lin_incld); % Generate the nonlinear lagged terms using different combinations of the chosen linear lagged terms
    n_lin_trms = length(trm_chsn_lin);
    n_nl_trms = length(trm_chsn_nl);

    rmo_len_char = length(trm_lag_char_tot_RMO);
    len_char = length(trm_lag_char_tot);
    trms = zeros(1,rmo_len_char);
    for j=1:rmo_len_char
        for i=1:len_char
            if strcmp(trm_lag_char_tot{1,i}, trm_lag_char_tot_RMO{1,j});trms(j) = i;end
        end
    end
elseif RCT == 4
    [~,~,~,~,~,~,~,trm_lag_char_tot_RMO] = OFR_RCT(X_main,Y,trm_chsn_lin,n_lin_trms,nl_ord_max,trm_lag_char_lin_incld);
    [trm_lag_char_tot,trm_chsn_nl,X_main_org,~] = generate_nl_reg(nl_ord_max,X,X,n_lin_trms_org,n_lin_trms_org,trm_lag_char_lin,trm_lag_char_lin); %full candidate dictionary
    n_nl_trms = length(trm_chsn_nl);
    trm_chsn_lin = trm_chsn_lin_org;
    n_lin_trms = n_lin_trms_org;

    rmo_len_char = length(trm_lag_char_tot_RMO);
    len_char = length(trm_lag_char_tot);
    trms = zeros(1,rmo_len_char);
    for j=1:rmo_len_char
        for i=1:len_char
            if strcmp(trm_lag_char_tot{1,i}, trm_lag_char_tot_RMO{1,j});trms(j) = i;end
        end
    end
else
    trm_lag_char_tot = [trm_lag_char_lin];
    % Generate the nonlinear lagged terms using different combinations of the chosen linear lagged terms
    [trm_lag_char_tot,trm_chsn_nl,X_main_org,~] = generate_nl_reg(nl_ord_max,X,X,n_lin_trms_org,n_lin_trms_org,trm_lag_char_lin,trm_lag_char_tot);
    n_nl_trms = length(trm_chsn_nl);
    n_trms_rem = n_lin_trms_org + n_nl_trms; % Total no. of terms remaining without bias
    trms = 1:n_trms_rem; % No. of candidate terms (without bias)
    trm_chsn_lin = trm_chsn_lin_org;
    n_lin_trms = n_lin_trms_org;
end

if is_bias == 1 % If a bias is included in the model make the approriate changes
    trm_lag_char_tot = [trm_lag_char_tot,'bias'];
    X_main_org = [X_main_org,ones(dat_len,1)];
end
end