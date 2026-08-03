function [theta,ms_press_e,ERR,ERR_itr,MS_PRESS_E,MS_PRESS_E2,MS_PRESS_E_itr,alpha,trm_chsn_logic_ind,trm_chsn_ind,ind_orth_wrt,ind_orth_wrt_org] ...
    = OLS_orthogonalisation_PRESS_frc(X,Y,frc_ind,stp_cri,alph,D1_thresh)
%#codegen
%
% Householder QR version of OLS_orthogonalisation_PRESS_frc.
%
% The term selection logic is kept the same as the original function:
% forced regressors are selected first using frc_ind, and once all forced
% regressors have been selected, the next free regressor is selected using
% minimum mean-square PRESS error.
%
% The Gram-Schmidt block used to form Wm_temp has been replaced by a
% Householder QR orthogonalisation path.  The accumulated Householder
% transformations orthogonalise every remaining candidate with respect to
% all previously selected regressors.  For PRESS, the current orthogonal
% candidate direction is transformed back to the original data coordinates
% so that the sample-wise PRESS weighting is evaluated in the same way as
% in the original implementation.

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
MS_PRESS_E = zeros(n_terms,1); % Mean Square PRESS Error at each iteration ( Jn )
MS_PRESS_E_itr = 0;%zeros(n_terms,n_terms);
BIC = zeros(n_terms,1); % Beysian Information Criteria for maximum no. of terms to be selected
APRESS = zeros(n_terms,1); % APRESS, Adjustable PRESS

trm_index = [1:1:n_terms];% term library index
trm_chsn_ind = zeros(1,n_terms);%index of chosen terms
trm_chsn_logic_ind = zeros(1,n_terms);
ind_orth_wrt = zeros(1,n_terms); %term indecies in order of selection

sigma = Y'*Y;
PRESS_W = ones(dat_len,1); % The collective PRESS error weighting of the selected regresors

% Householder QR working copies.  A and Y_hh are transformed in-place by
% the accumulated Householder reflectors.  perm maps the current columns of
% A back to the original regressor indices in X.
A = X;
Y_hh = Y;
perm = trm_index;
V_hh = zeros(dat_len,n_terms); % stored Householder vectors
beta_hh = zeros(n_terms,1);    % stored Householder scale factors

% Rank tolerance used only to avoid division by zero for numerically
% dependent candidate regressors.
rank_tol = max(size_X) * eps(max(1,max(sum(X.^2,1))));
PRESS_min = 1;

%% ------ 1st term selection ---------

m = 1;
r_n = 0;
cand_pos = m:n_terms;
trm_lft_chsn = perm(cand_pos); % terms that are left to be chosen

[Wm_temp,g_temp,ERR_temp,error_pred_temp,PRESS_W_temp,MS_PRESS_E_temp] = ...
    local_HH_candidate_eval(A,Y_hh,sigma,m,cand_pos,V_hh,beta_hh,r_n,error_pred_init(Y),PRESS_W,dat_len,rank_tol);

% ------ Select the approriate attributes of the first forced term --------

trm_lft_chsn_frc = (trm_lft_chsn == frc_ind(1));
frc_local_ind = find(trm_lft_chsn_frc,1);

ERR(1) = ERR_temp(frc_local_ind); % ERR value
Wm(:,1) = Wm_temp(:,frc_local_ind); % Orthogonal regressor
gm(1) = g_temp(frc_local_ind); % Orthogonal parameter

PRESS_W =  PRESS_W_temp(:,frc_local_ind); % Update PRESS error weighting
MS_PRESS_E(1) = MS_PRESS_E_temp(frc_local_ind); % Mean Square PRESS Error
error_pred = error_pred_temp(:,frc_local_ind); % Update the predicted errors
BIC(1) = dat_len*log((error_pred'*error_pred)/dat_len) + 1*log(dat_len);
APRESS(1) = ((error_pred'*error_pred)/dat_len) * (1/( 1 - (1*alph/dat_len) ))^2;
% -------------------------------------------------------------------------

trm_chsn_ind(frc_ind(1)) = trm_index(frc_ind(1)); % Update the indecies of chosen terms
trm_chsn_logic_ind(frc_ind(1)) = 1; % Logical array; which terms are chosen
ind_orth_wrt(1) = frc_ind(1); % terms chosen in the order they are chosen

alpha(1,1) = 1;
frc_ind_len_rem = frc_ind_len - 1;

% Swap the forced term into the current QR pivot position and update the
% Householder factorisation for the next iteration.
chosen_pos = cand_pos(frc_local_ind);
[A,perm] = local_swap_columns(A,perm,m,chosen_pos);
[V_hh,beta_hh,A,Y_hh] = local_apply_new_householder(A,Y_hh,V_hh,beta_hh,m,dat_len);
%% ----------------------------------

%% ------ Selection other terms ---------

for m = 2:n_terms  %(frc_ind(end)+1)

    i_n = n_terms-(m-1); % No. of terms left to check
    r_n = m - 1; % r = 1, ... , m-1

    cand_pos = m:n_terms;
    trm_lft_chsn = perm(cand_pos); % terms that are left to be chosen

    Pi = X(:,trm_lft_chsn); % regressors to be orthogonalised

    % -------------- Evaluate alpha_rm^{i} ----------------
    % alpha is retained for compatibility with the original function.  The
    % Householder-transformed A matrix is used for the actual orthogonalisation.
    Wm_norm = diag( Wm(:, 1:r_n)' * Wm(:, 1:r_n) );
    Wm_norm(Wm_norm == 0) = eps;
    alpha_temp = ( Pi' * Wm(:, 1:r_n) ) ./ (Wm_norm)';
    % -----------------------------------------------------

    % -------------- Evaluate Wm^{i} ----------------
    % Householder QR equivalent of: Pi - projection onto selected Wm.
    [Wm_temp,g_temp,ERR_temp,error_pred_temp,PRESS_W_temp,MS_PRESS_E_temp] = ...
        local_HH_candidate_eval(A,Y_hh,sigma,m,cand_pos,V_hh,beta_hh,r_n,error_pred,PRESS_W,dat_len,rank_tol);
    % -----------------------------------------------

    % -------------- Evaluate gm^{i} ----------------
    % g_temp is evaluated inside local_HH_candidate_eval using the
    % Householder-transformed candidate residuals.
    % -----------------------------------------------

    % -------------- Evaluate [ERRm]^{i} ----------------
    % ERR_temp is evaluated inside local_HH_candidate_eval.
    % ---------------------------------------------------

    % --------------- Evaluate Em^{i} -----------------
    % error_pred_temp is evaluated inside local_HH_candidate_eval.
    % -------------------------------------------------

    % --------------- Evaluate PRESS_Wm^{i} -----------------
    % PRESS_W_temp is evaluated inside local_HH_candidate_eval.
    % -------------------------------------------------------

    % --------------- Evaluate Jm^{i} -----------------
    % MS_PRESS_E_temp is evaluated inside local_HH_candidate_eval.
    % -------------------------------------------------

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
        BIC(m) = dat_len*log((error_pred'*error_pred)/dat_len) + m*log(dat_len);
        APRESS(m) = ((error_pred'*error_pred)/dat_len) * (1/( 1 - (m*alph/dat_len) ))^2;

        trm_chsn_ind( trm_lft_chsn(min_press_ind) ) = trm_lft_chsn(min_press_ind);
        trm_chsn_logic_ind( trm_lft_chsn(min_press_ind) ) = 1;
        ind_orth_wrt(m) = trm_lft_chsn(min_press_ind);

        chosen_local_ind = min_press_ind;

    else % if forced parameters are still left

        trm_lft_chsn_frc = (trm_lft_chsn == frc_ind(m));
        frc_local_ind = find(trm_lft_chsn_frc,1);

        ERR(m) = ERR_temp(frc_local_ind);
        Wm(:,m) = Wm_temp(:,frc_local_ind);
        gm(m) = g_temp(frc_local_ind);
        alpha(1:r_n,m) = alpha_temp(frc_local_ind,:);
        alpha(m,m) = 1;

        PRESS_W =  PRESS_W_temp(:,frc_local_ind); % Update PRESS error weighting
        MS_PRESS_E(m) = MS_PRESS_E_temp(frc_local_ind); % Mean Square PRESS Error
        error_pred = error_pred_temp(:,frc_local_ind); % Update the predicted errors
        BIC(m) = dat_len*log((error_pred'*error_pred)/dat_len) + m*log(dat_len);
        APRESS(m) = ((error_pred'*error_pred)/dat_len) * (1/( 1 - (m*alph/dat_len) ))^2;

        trm_chsn_ind( trm_lft_chsn(frc_local_ind) ) = trm_lft_chsn(frc_local_ind);
        trm_chsn_logic_ind( trm_lft_chsn(frc_local_ind) ) = 1;
        ind_orth_wrt(m) = trm_lft_chsn(frc_local_ind);
        frc_ind_len_rem = frc_ind_len_rem - 1;

        chosen_local_ind = frc_local_ind;

    end

    % Swap the selected term into the current QR pivot position and update
    % the Householder factorisation for all following candidates.
    chosen_pos = cand_pos(chosen_local_ind);
    [A,perm] = local_swap_columns(A,perm,m,chosen_pos);
    [V_hh,beta_hh,A,Y_hh] = local_apply_new_householder(A,Y_hh,V_hh,beta_hh,m,dat_len);

    PRESS_min = 1;
    if m > 2 % stopping criteria invoked only after two terms are selected
        switch stp_cri
            case 'PRESS_thresh'
                D1_msprss = MS_PRESS_E(m) - MS_PRESS_E(m-1);
                D1_ms_prss_lgc = D1_msprss < D1_thresh && D1_msprss > -D1_thresh; %The difference when the curve is descending and ascending. This threshold
                if D1_ms_prss_lgc
                    n_end=1; PRESS_min = 0;
                    break;
                end
            case 'PRESS_min'
                PRESS_min = 1;
                continue;
            case 'BIC_thresh'
                D1_msprss = BIC(m) - BIC(m-1);
                D1_ms_prss_lgc = D1_msprss < D1_thresh && D1_msprss > -D1_thresh;
                if D1_ms_prss_lgc
                    n_end=1; PRESS_min = 0;
                    break;
                end
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
%% ------ Form final parameters ---------

% Form the final parameter vector using the original alpha/gm
% back-substitution method.
theta(end) = gm(end);
for i = (m-1-n_end):-1:1
    theta(i) = gm(i) - alpha(i,(i+1):end) * theta((i+1):end);
end

%%
ind_orth_wrt = ind_orth_wrt(logical(ind_orth_wrt));
ind_orth_wrt_org = ind_orth_wrt_org(logical(ind_orth_wrt_org));
end

function e = error_pred_init(Y)
% Helper used only to keep the first-term code close to the original style.
e = Y;
end

function [Wm_temp,g_temp,ERR_temp,error_pred_temp,PRESS_W_temp,MS_PRESS_E_temp] = ...
    local_HH_candidate_eval(A,Y_hh,sigma,m,cand_pos,V_hh,beta_hh,r_n,error_pred,PRESS_W,dat_len,rank_tol)
% Evaluate the candidate orthogonal regressors using the accumulated
% Householder QR factorisation.

    i_n = length(cand_pos);
    Z = A(m:end,cand_pos); % candidate residuals in Householder coordinates
    den = sum(Z.^2,1); % squared norm of each candidate residual
    valid_ind = den > rank_tol;

    Q_temp = zeros(dat_len,i_n);
    if any(valid_ind)
        Q_temp(m:end,valid_ind) = Z(:,valid_ind) ./ sqrt(den(valid_ind));
    end

    % Transform the normalised candidate directions back to the original
    % data coordinates.  This is needed only for PRESS_W and error_pred.
    Q_temp = local_apply_previous_householders(Q_temp,V_hh,beta_hh,r_n);

    sqrt_den = zeros(1,i_n);
    sqrt_den(valid_ind) = sqrt(den(valid_ind));
    Wm_temp = Q_temp .* sqrt_den;

    c_temp = Z' * Y_hh(m:end);
    g_temp = zeros(i_n,1);
    ERR_temp = zeros(i_n,1);

    if any(valid_ind)
        g_temp(valid_ind) = c_temp(valid_ind) ./ den(valid_ind)';
        ERR_temp(valid_ind) = (c_temp(valid_ind).^2) ./ (den(valid_ind)' .* sigma);
    end

    % --------------- Evaluate Em^{i} -----------------
    error_pred_temp = error_pred - ( Wm_temp .* g_temp' );
    % -------------------------------------------------

    % --------------- Evaluate PRESS_Wm^{i} -----------------
    PRESS_W_temp = PRESS_W - ( Q_temp.^2 );
    % -------------------------------------------------------

    % --------------- Evaluate Jm^{i} -----------------
    MS_PRESS_E_temp = (1 / dat_len) .* sum( (error_pred_temp ./ PRESS_W_temp).^2 , 1);
    MS_PRESS_E_temp(~valid_ind) = inf;
    % -------------------------------------------------
end

function Q_temp = local_apply_previous_householders(Q_temp,V_hh,beta_hh,n_prev)
% Map vectors from Householder coordinates back to the original data
% coordinates.  Since A = Hn_prev*...*H2*H1*X, the inverse mapping is
% H1*H2*...*Hn_prev and must be applied in reverse loop order.

    for j = n_prev:-1:1
        beta = beta_hh(j);
        if beta ~= 0
            v = V_hh(j:end,j);
            Q_temp(j:end,:) = Q_temp(j:end,:) - beta .* v * ( v' * Q_temp(j:end,:) );
        end
    end
end

function [A,perm] = local_swap_columns(A,perm,left_ind,right_ind)
% Swap columns in the transformed regressor matrix and the original-index map.

    if left_ind ~= right_ind
        A(:,[left_ind right_ind]) = A(:,[right_ind left_ind]);
        perm([left_ind right_ind]) = perm([right_ind left_ind]);
    end
end

function [V_hh,beta_hh,A,Y_hh] = local_apply_new_householder(A,Y_hh,V_hh,beta_hh,m,dat_len)
% Generate and apply the next Householder reflector.

    x = A(m:end,m);
    [v,beta] = local_householder_vector(x);

    V_hh(m:end,m) = v;
    beta_hh(m) = beta;

    if beta ~= 0
        A(m:end,m:end) = A(m:end,m:end) - beta .* v * ( v' * A(m:end,m:end) );
        Y_hh(m:end) = Y_hh(m:end) - beta .* v * ( v' * Y_hh(m:end) );
    end

    % Clean numerical round-off below the diagonal of the selected column.
    if m < dat_len
        A(m+1:end,m) = 0;
    end
end

function [v,beta] = local_householder_vector(x)
% Compute a Householder vector v and scale beta such that
% H = I - beta*v*v' transforms x to a multiple of e1.

    n_x = length(x);
    v = zeros(n_x,1);
    v(1) = 1;

    if n_x == 1
        beta = 0;
        return;
    end

    x_1 = x(1);
    x_tail = x(2:end);
    sigma_tail = x_tail' * x_tail;

    if sigma_tail == 0
        if x_1 >= 0
            beta = 0;
        else
            beta = 2;
        end
    else
        mu = sqrt(x_1*x_1 + sigma_tail);
        if x_1 <= 0
            v_1 = x_1 - mu;
        else
            v_1 = -sigma_tail / (x_1 + mu);
        end

        v(2:end) = x_tail / v_1;
        beta = 2 * v_1 * v_1 / (sigma_tail + v_1 * v_1);
    end
end
