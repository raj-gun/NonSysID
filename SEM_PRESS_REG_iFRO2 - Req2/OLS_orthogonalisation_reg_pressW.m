function [PRESS_W] = OLS_orthogonalisation_reg_pressW(X,Y,lambda_ini,frc_ind,reg_itr_end,lamda_stp,stp_cri,alph,D1_thresh)
%#codegen

size_X = size(X);
n_terms = size_X(2);
dat_len = size_X(1);
frc_ind_len = length(frc_ind);
n_end = 0;

alpha = zeros(n_terms,n_terms);
Wm = zeros(size_X);
ERR = zeros(n_terms,1);
ERR_itr = 0;%zeros(n_terms,n_terms);
gm = zeros(n_terms,1);
lambda = ones(n_terms,1).*lambda_ini; % Regularization parameter
MS_PRESS_E = zeros(n_terms,1); % Mean Square PRESS Error at each iteration ( Jn )
MS_PRESS_E_itr = 0;%zeros(n_terms,n_terms);
BIC = zeros(n_terms,1); % Beysian Information Criteria for maximum no. of terms to be selected
APRESS = zeros(n_terms,1); % APRESS, Adjustable PRESS

% ERR_temp = zeros(n_terms,1);
% Wm_temp = zeros(size_X);
% g_temp = zeros(n_terms,1);
% PRESS_W_temp = zeros(dat_len,n_terms); % PRESS error weighting of each regressor
% MS_PRESS_E_temp = zeros(n_terms,1);
% error_pred_temp = zeros(dat_len,n_terms);

trm_index = [1:1:n_terms];% term library index
trm_chsn_ind = zeros(1,n_terms);%index of chosen terms
trm_chsn_logic_ind = zeros(1,n_terms);
ind_orth_wrt = zeros(1,n_terms); %term indecies in order of selection

sigma = Y'*Y;
PRESS_W = ones(dat_len,1); % The collective PRESS error weighting of the selected regresors

%% ------ 1st term selection ---------
% for i = 1:n_terms % Obtain PRESS statistic for all regressors
%     Wm_temp(:,i) = X(:,i);
%     g_temp(i) = Wm_temp(:,i)'*Y / ( Wm_temp(:,i)' * Wm_temp(:,i) + lambda(i) );
%     ERR_temp(i) = (g_temp(i)^2) * ( Wm_temp(:,i)' * Wm_temp(:,i) + lambda(i) ) / sigma;
%     error_pred_temp(:,i) = (Y - Wm_temp(:,i)*g_temp(i));
%     PRESS_W_temp(:,i) = PRESS_W -  (Wm_temp(:,i).^2) ./ ( Wm_temp(:,i)' * Wm_temp(:,i) + lambda(i) );
%     MS_PRESS_E_temp(i) = (1/dat_len) * sum( (error_pred_temp(:,i) ./ PRESS_W_temp(:,i)).^2 );
% end
Wm_temp = X;
g_temp = ( Wm_temp' * Y ) ./ ( diag( Wm_temp' * Wm_temp ) + lambda );
ERR_temp = ( g_temp.^2 ) .* ( diag( Wm_temp' * Wm_temp ) + lambda ) ./ sigma;
error_pred_temp = Y - ( Wm_temp .* g_temp' );
PRESS_W_temp = PRESS_W - ( (Wm_temp.^2) ./ ( diag( Wm_temp' * Wm_temp ) + lambda )' );
MS_PRESS_E_temp = (1 / dat_len) .* sum( (error_pred_temp ./ PRESS_W_temp).^2 , 1);


% ------ Select the approriate attributes of the first forced term --------

ERR(1) = ERR_temp(frc_ind(1)); % ERR value
Wm(:,1) = Wm_temp(:,frc_ind(1)); % Orthogonal regressor
gm(1) = g_temp(frc_ind(1)); % Orthogonal parameter

PRESS_W =  PRESS_W_temp(:,frc_ind(1)); % Update PRESS error weighting
MS_PRESS_E(1) = MS_PRESS_E_temp(frc_ind(1)); % Mean Square PRESS Error
error_pred = error_pred_temp(:,frc_ind(1)); % Update the predicted errors
% MS_PRESS_E_itr(:,1) = MS_PRESS_E_temp;
%BIC(1) = ( 1 + ( log(dat_len)/(dat_len-1) ) )*((error_pred'*error_pred)/dat_len);
BIC(1) = dat_len*log((error_pred'*error_pred)/dat_len) + 1*log(dat_len);
APRESS(1) = ((error_pred'*error_pred)/dat_len) * (1/( 1 - (1*alph/dat_len) ))^2;
% -------------------------------------------------------------------------

trm_chsn_ind(frc_ind(1)) = trm_index(frc_ind(1)); % Update the indecies of chosen terms
trm_chsn_logic_ind(frc_ind(1)) = 1; % Logical array; which terms are chosen
ind_orth_wrt(1) = frc_ind(1); % terms chosen in the order they are chosen
trm_lft_chsn = trm_index(~logical(trm_chsn_logic_ind)); % terms that are left to be chosen
%ERR_itr(:,1) = ERR_temp;

alpha(1,1) = 1;
frc_ind_len_rem = frc_ind_len - 1;
%% ----------------------------------

%% ------ Selection other terms ---------

for m = 2:n_terms  %(frc_ind(end)+1)
    
    i_n = n_terms-(m-1); % No. of terms left to check
    r_n = m - 1; % r = 1, ... , m-1
    
    Wm_temp = zeros(dat_len , i_n); % Wm^{i}
    
    Pi = X(:,trm_lft_chsn); %regressors to be orthogonalised
    
    % -------------- Evaluate alpha_rm^{i} ----------------
    alpha_temp = ( Pi' * Wm(:, 1:r_n) ) ./ (diag( Wm(:, 1:r_n)' * Wm(:, 1:r_n) ))';
    % -----------------------------------------------------
    
    % -------------- Evaluate Wm^{i} ----------------
    for i = 1:i_n; Wm_temp(:, i) = sum(alpha_temp(i, :) .* Wm(:, 1:r_n) , 2); end
    Wm_temp = Pi - Wm_temp;
    % -----------------------------------------------
    
    % -------------- Evaluate gm^{i} ----------------
    g_temp = ( Wm_temp' * Y ) ./ ( diag( Wm_temp' * Wm_temp ) + lambda(m) );
    % -----------------------------------------------
    
    % -------------- Evaluate [ERRm]^{i} ----------------
    ERR_temp = ( g_temp.^2 ) .* ( diag( Wm_temp' * Wm_temp ) + lambda(m) ) ./ sigma;
    % ---------------------------------------------------
    
    % --------------- Evaluate Em^{i} -----------------
    error_pred_temp = error_pred - ( Wm_temp .* g_temp' );
    % -------------------------------------------------
    
    % --------------- Evaluate PRESS_Wm^{i} -----------------
    PRESS_W_temp = PRESS_W - ( (Wm_temp.^2) ./ ( diag( Wm_temp' * Wm_temp ) + lambda(m) )' );
    % -------------------------------------------------------
    
    % --------------- Evaluate Jm^{i} -----------------
    MS_PRESS_E_temp = (1 / dat_len) .* sum( (error_pred_temp ./ PRESS_W_temp).^2 , 1);
    % -------------------------------------------------
    
    %ERR_itr(trm_lft_chsn,m) =  ERR_temp;
    %MS_PRESS_E_itr(trm_lft_chsn,m) = MS_PRESS_E_temp;
    
    if frc_ind_len_rem == 0 % if all forced parameters are choosen
        
        [~,min_press_ind] = min(MS_PRESS_E_temp);%max(ERR_temp);
        
        ERR(m) = ERR_temp(min_press_ind);
        Wm(:,m) = Wm_temp(:,min_press_ind);
        gm(m) = g_temp(min_press_ind);
        alpha(1:r_n,m) = alpha_temp(min_press_ind,:);
        alpha(m,m) = 1;
        
        PRESS_W =  PRESS_W_temp(:,min_press_ind); % Update PRESS error weighting
        MS_PRESS_E(m) = MS_PRESS_E_temp(min_press_ind); % Mean Square PRESS Error
        error_pred = error_pred_temp(:,min_press_ind); % Update the predicted errors
        %BIC(m) = ( 1 + ( m*log(dat_len)/(dat_len-m) ) )*((error_pred'*error_pred)/dat_len);
        BIC(m) = dat_len*log((error_pred'*error_pred)/dat_len) + m*log(dat_len);
        APRESS(m) = ((error_pred'*error_pred)/dat_len) * (1/( 1 - (m*alph/dat_len) ))^2;
        
        trm_chsn_ind( trm_lft_chsn(min_press_ind) ) = trm_lft_chsn(min_press_ind);
        trm_chsn_logic_ind( trm_lft_chsn(min_press_ind) ) = 1;
        ind_orth_wrt(m) = trm_lft_chsn(min_press_ind);
        trm_lft_chsn = trm_index(~logical(trm_chsn_logic_ind));
        
    else % if forced parameters are still left
        
        trm_lft_chsn_frc = (trm_lft_chsn == frc_ind(m));
        ERR(m) = ERR_temp(trm_lft_chsn_frc);
        Wm(:,m) = Wm_temp(:,trm_lft_chsn_frc);
        gm(m) = g_temp(trm_lft_chsn_frc);
        alpha(1:r_n,m) = alpha_temp(trm_lft_chsn_frc,:);
        alpha(m,m) = 1;
        
        PRESS_W =  PRESS_W_temp(:,trm_lft_chsn_frc); % Update PRESS error weighting
        MS_PRESS_E(m) = MS_PRESS_E_temp(trm_lft_chsn_frc); % Mean Square PRESS Error
        error_pred = error_pred_temp(:,trm_lft_chsn_frc); % Update the predicted errors
        %BIC(m) = ( 1 + ( m*log(dat_len)/(dat_len-m) ) )*((error_pred'*error_pred)/dat_len);
        BIC(m) = dat_len*log((error_pred'*error_pred)/dat_len) + m*log(dat_len);
        APRESS(m) = ((error_pred'*error_pred)/dat_len) * (1/( 1 - (m*alph/dat_len) ))^2;
        
        trm_chsn_ind( trm_lft_chsn(trm_lft_chsn_frc) ) = trm_lft_chsn(trm_lft_chsn_frc);
        trm_chsn_logic_ind( trm_lft_chsn(trm_lft_chsn_frc) ) = 1;
        ind_orth_wrt(m) = trm_lft_chsn(trm_lft_chsn_frc);
        trm_lft_chsn = trm_index(~logical(trm_chsn_logic_ind));
        frc_ind_len_rem = frc_ind_len_rem - 1;
        
    end
    
    PRESS_min = 1;
    if m > 2 % stopping criteria invoked only after two terms are selected
        switch stp_cri
            case 'PRESS_thresh'
                D1_msprss = MS_PRESS_E(m) - MS_PRESS_E(m-1);
                D1_ms_prss_lgc = D1_msprss < D1_thresh && D1_msprss > -D1_thresh;
                if D1_ms_prss_lgc
                    n_end=1; PRESS_min = 0;
                    break;
                end
            case 'PRESS_min'
                PRESS_min = 1;
                continue;
        end
    end
    
end
 
if PRESS_min == 1
    [~,m]=min(MS_PRESS_E); n_end=0;
end

gm = gm(1:(m-n_end));
Wm = Wm(:,1:(m-n_end));
alpha = alpha(1:(m-n_end),1:(m-n_end));
theta = zeros((m-n_end),1);

%ERR_itr = ERR_itr(:,1:(m-n_end));
%MS_PRESS_E_itr = MS_PRESS_E_itr(:,1:(m-n_end));
MS_PRESS_E2 = MS_PRESS_E;
ms_press_e = MS_PRESS_E(m-n_end);
MS_PRESS_E = MS_PRESS_E(1:m-n_end);
ERR = ERR(1:m-n_end);

ind_orth_wrt = ind_orth_wrt(1:m);
ind_orth_wrt_org = ind_orth_wrt;

if n_end ~=0
    trm_chsn_logic_ind(ind_orth_wrt(m)) = 0;
    trm_chsn_ind(ind_orth_wrt(m)) = 0;
    ind_orth_wrt(m) = 0;
end

%% -------------------------------------
%% ------ Local regularization of selected terms ---------

if lambda_ini ~= 0
    
    error_pred = Y - Wm*gm;
    lambda = lambda(1:(m-n_end));
    wTw = sum(Wm .* Wm)';
    wTy = sum( Wm .* repmat(Y,1,(m-n_end)) )';
    for reg_itr = 1:reg_itr_end
        
        lambda_prev = lambda;
        
        gamma = sum( wTw ./ (lambda + wTw) );
        lambda = ( ( gamma/(dat_len - gamma) ) * (error_pred'*error_pred) ) ./ (gm.^2);
        
        gm = wTy ./ (wTw + lambda); % Regularized orthogonal parameters
        error_pred = Y - Wm*gm; % Error predicted
        
        lambda(lambda > 1e20) = 1e20; % Cap the regularization parameters that exceed 1e20
        
        if (reg_itr > 2) && ( abs(lambda - lambda_prev) ./ lambda )*100 < lamda_stp
            break;
        end
        
    end
    
    gm(abs(gm) < 1e-16) = 0;
    
    % ------- Re-evaluate ERR and MS_PRESS_E values --------------
    ERR(1:(m-n_end)) = (gm.^2) .* ((wTw + lambda) ./ sigma); % Regularized ERR values
    
    error_pred = Y - Wm*gm; % Error predicted
    PRESS_W_reg = ones(dat_len,1) - sum(( (Wm.^2) ./ repmat((wTw + lambda)' ,dat_len,1) ) , 2); % Regularized PRESS error weighting
    ms_press_e = (1/dat_len)*sum( (error_pred ./ PRESS_W_reg).^2 ); % Regularized mean square PRESS error
    % ------------------------------------------------------------
    
end
%% ------------------------------------------------------------
%% ------ Form final parameters ---------

theta(end) = gm(end);
for i = (m-1-n_end):-1:1
    theta(i) = gm(i) - alpha(i , (i+1):end ) * theta((i+1):end);
end

if lambda_ini ~= 0
    logic_theta = (theta == 0);
    trm_chsn_logic_ind(ind_orth_wrt(logic_theta)) = 0;
    trm_chsn_ind(ind_orth_wrt(logic_theta)) = 0;
    ind_orth_wrt(logic_theta) = 0;
    theta = theta(theta ~= 0);
end
%%
ind_orth_wrt = ind_orth_wrt(logical(ind_orth_wrt));
ind_orth_wrt_org = ind_orth_wrt_org(logical(ind_orth_wrt_org));
end