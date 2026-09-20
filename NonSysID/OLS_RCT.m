function [theta,ms_press_e,ERR,ERR_itr,MS_PRESS_E,MS_PRESS_E_itr,alpha,trm_chsn_logic_ind,trm_chsn_ind,ind_orth_wrt,ind_orth_wrt_org] ...
    = OLS_RCT(X,Y,frc_ind)
%#codegen

% Householder based implementation of the orthogonalisation used by the RCT
% stage. Drop in replacement for the original Gram-Schmidt version; identical
% inputs, outputs and term selection.
%
% NOTE ON THE ORTHOGONALISATION -------------------------------------------
% After m-1 steps the Householder working array holds Rm = H_(m-1)...H_1*Pi,
% i.e. the deflated regressors expressed in a REFLECTED frame. Inner products
% and norms survive that change of frame, so [ERRm]^{i} could be evaluated
% directly on Rm(m:end,:).
%
% The term selection here is by minimum PRESS, not by maximum ERR, and the
% PRESS quantities Em^{i} and PRESS_Wm^{i} are PER-SAMPLE: row t of the
% reflected array is a mixture of samples, not sample t, and the sub column is
% (dat_len-m+1) long rather than dat_len. Forming them from Rm(m:end,:) does
% not error, it simply selects the wrong terms.
%
% The candidate block is therefore reflected back into the original sample
% ordering before the PRESS quantities are formed. As a block this costs
% O(dat_len*n_terms*m) per step, the same order as the alpha_rm^{i} product it
% replaces, so there is no asymptotic penalty.
% -------------------------------------------------------------------------

size_X = size(X);
n_terms = size_X(2);
dat_len = size_X(1);
frc_ind_len = length(frc_ind);
n_end = 0;

alpha = zeros(n_terms,n_terms);
ERR = zeros(n_terms,1);
ERR_itr = 0;%zeros(n_terms,n_terms);
gm = zeros(n_terms,1);
MS_PRESS_E = zeros(n_terms,1); % Mean Square PRESS Error at each iteration ( Jn )
MS_PRESS_E_itr = 0;%zeros(n_terms,n_terms);
BIC = zeros(n_terms,1); % Beysian Information Criteria for maximum no. of terms to be selected

trm_index = [1:1:n_terms];% term library index
trm_chsn_ind = zeros(1,n_terms);%index of chosen terms
trm_chsn_logic_ind = zeros(1,n_terms);
ind_orth_wrt = zeros(1,n_terms); %term indecies in order of selection

sigma = Y'*Y;
PRESS_W = ones(dat_len,1); % The collective PRESS error weighting of the selected regresors

% ------ Householder working arrays --------------------------------------
% The orthogonal regressors Wm of the Gram-Schmidt version are never stored;
% the reflectors that generate them are stored instead, which also saves an
% (dat_len x n_terms) array.
Rm = X; % becomes the upper triangular factor R of the selected columns
Qty = Y; % becomes Q'*Y
Vm = zeros(size_X); % Householder vectors; the mth reflector occupies rows m:end of column m
piv = trm_index; % column permutation of Rm, i.e. Rm(:,j) derives from X(:,piv(j))
d_Rm = zeros(n_terms,1); % diagonal of Rm, i.e. d_Rm(r) = +/- norm( wr )
% ------------------------------------------------------------------------

%% ------ 1st term selection ---------
Wm_temp = X; % no reflections have been applied yet, so Wm^{i} = Pi
lam_temp = diag( Wm_temp' * Wm_temp ); % < wm^{i} , wm^{i} >
g_temp = ( Wm_temp' * Y ) ./ lam_temp;
ERR_temp = ( g_temp.^2 ) .* lam_temp ./ sigma;
error_pred_temp = Y - ( Wm_temp .* g_temp' );
PRESS_W_temp = PRESS_W - ( (Wm_temp.^2) ./ lam_temp' );
MS_PRESS_E_temp = (1 / dat_len) .* sum( (error_pred_temp ./ PRESS_W_temp).^2 , 1);


% ------ Select the approriate attributes of the first forced term --------

ERR(1) = ERR_temp(frc_ind(1)); % ERR value
gm(1) = g_temp(frc_ind(1)); % Orthogonal parameter

PRESS_W =  PRESS_W_temp(:,frc_ind(1)); % Update PRESS error weighting
MS_PRESS_E(1) = MS_PRESS_E_temp(frc_ind(1)); % Mean Square PRESS Error
error_pred = error_pred_temp(:,frc_ind(1)); % Update the predicted errors
BIC(1) = dat_len*log((error_pred'*error_pred)/dat_len) + 1*log(dat_len);
% -------------------------------------------------------------------------

trm_chsn_ind(frc_ind(1)) = trm_index(frc_ind(1)); % Update the indecies of chosen terms
trm_chsn_logic_ind(frc_ind(1)) = 1; % Logical array; which terms are chosen
ind_orth_wrt(1) = frc_ind(1); % terms chosen in the order they are chosen
trm_lft_chsn = trm_index(~logical(trm_chsn_logic_ind)); % terms that are left to be chosen

% ------ Rotate the chosen regressor into column 1 and deflate ------------
% A cyclic rotation is used rather than a swap so that the unselected columns
% retain their ascending library ordering, i.e. piv(m+1:end) is identical to
% trm_lft_chsn at every step. This matters because min() breaks ties on first
% occurrence: a swap based pivot would silently reorder the candidate list and
% so change which of two tied candidates is selected.
Rm(: , 1:frc_ind(1)) = Rm(: , [frc_ind(1) , 1:(frc_ind(1)-1)]);
piv(1:frc_ind(1)) = piv([frc_ind(1) , 1:(frc_ind(1)-1)]);

v = house_vec( Rm(1:end , 1) ); % Householder vector that zeros Rm(2:end,1)
Vm(1:end , 1) = v;
Rm(1:end , 1:end) = row_house( Rm(1:end , 1:end) , v );
Qty(1:end) = row_house( Qty(1:end) , v );

alpha(1,1) = 1;
d_Rm(1) = Rm(1,1);
% -------------------------------------------------------------------------

frc_ind_len_rem = frc_ind_len - 1;
m = 1;
%% ----------------------------------

%% ------ Selection other terms ---------

for m = 2:n_terms  %(frc_ind(end)+1)

    i_n = n_terms-(m-1); % No. of terms left to check
    r_n = m - 1; % r = 1, ... , m-1

    Wm_temp = zeros(dat_len , i_n); % Wm^{i}

    % -------------- Evaluate Wm^{i} ----------------
    % The deflated candidate regressors are already held in Rm(m:end,m:end),
    % but in the frame defined by H_(m-1)...H_1. Reflecting that block back,
    %     Wm^{i} = H_1*...*H_(m-1) * [ 0_(m-1) ; Rm(m:end,m:end) ] ,
    % recovers, to machine precision, exactly the Wm^{i} that the Gram-Schmidt
    % version formed as Pi - sum_r alpha_rm^{i}*wr. Each H_r is symmetric and
    % its own inverse, so the reflectors are simply re-applied in reverse order.
    % This is the step that makes the per-sample PRESS quantities below valid.
    Wm_temp(m:end , :) = Rm(m:end , m:end);
    for r = r_n:-1:1
        v = Vm(r:end , r);
        Wm_temp(r:end , :) = Wm_temp(r:end , :) - ( (2/(v'*v)).*v ) * ( v' * Wm_temp(r:end , :) );
    end
    % -----------------------------------------------

    % -------------- Evaluate < wm^{i} , wm^{i} > ----------------
    lam_temp = diag( Wm_temp' * Wm_temp );
    % ------------------------------------------------------------

    % -------------- Evaluate gm^{i} ----------------
    g_temp = ( Wm_temp' * Y ) ./ lam_temp;
    % -----------------------------------------------

    % -------------- Evaluate [ERRm]^{i} ----------------
    ERR_temp = ( g_temp.^2 ) .* lam_temp ./ sigma;
    % ---------------------------------------------------

    % --------------- Evaluate Em^{i} -----------------
    error_pred_temp = error_pred - ( Wm_temp .* g_temp' );
    % -------------------------------------------------

    % --------------- Evaluate PRESS_Wm^{i} -----------------
    PRESS_W_temp = PRESS_W - ( (Wm_temp.^2) ./ lam_temp' );
    % -------------------------------------------------------

    % --------------- Evaluate Jm^{i} -----------------
    MS_PRESS_E_temp = (1 / dat_len) .* sum( (error_pred_temp ./ PRESS_W_temp).^2 , 1);
    % -------------------------------------------------

    if frc_ind_len_rem == 0 % if all forced parameters are choosen
        [~,min_press_ind] = min(MS_PRESS_E_temp);%max(ERR_temp);
    else % if forced parameters are still left
        min_press_ind = find( trm_lft_chsn == frc_ind(m) , 1 );
        frc_ind_len_rem = frc_ind_len_rem - 1;
    end

    % ------ Select the approriate attributes of the chosen term -------
    % Unlike the Gram-Schmidt version the two branches above share this block:
    % the deflation that follows must be carried out once and once only.
    ERR(m) = ERR_temp(min_press_ind);
    gm(m) = g_temp(min_press_ind);

    PRESS_W =  PRESS_W_temp(:,min_press_ind); % Update PRESS error weighting
    MS_PRESS_E(m) = MS_PRESS_E_temp(min_press_ind); % Mean Square PRESS Error
    error_pred = error_pred_temp(:,min_press_ind); % Update the predicted errors
    BIC(m) = dat_len*log((error_pred'*error_pred)/dat_len) + m*log(dat_len);

    trm_chsn_ind( trm_lft_chsn(min_press_ind) ) = trm_lft_chsn(min_press_ind);
    trm_chsn_logic_ind( trm_lft_chsn(min_press_ind) ) = 1;
    ind_orth_wrt(m) = trm_lft_chsn(min_press_ind);
    trm_lft_chsn = trm_index(~logical(trm_chsn_logic_ind));
    % -------------------------------------------------------------------

    % ------ Rotate the chosen regressor into column m and deflate ------
    trm_chsn_col = (m-1) + min_press_ind; % its current column in Rm
    Rm(: , m:trm_chsn_col) = Rm(: , [trm_chsn_col , m:(trm_chsn_col-1)]);
    piv(m:trm_chsn_col) = piv([trm_chsn_col , m:(trm_chsn_col-1)]);

    v = house_vec( Rm(m:end , m) ); % Householder vector that zeros Rm(m+1:end,m)
    Vm(m:end , m) = v;
    Rm(m:end , m:end) = row_house( Rm(m:end , m:end) , v );
    Qty(m:end) = row_house( Qty(m:end) , v );
    % -------------------------------------------------------------------

    % -------------- Evaluate alpha_rm ----------------
    % alpha_rm = < pm , wr > / < wr , wr >, which in the triangular factor is
    % simply Rm(r,m)/Rm(r,r): wr = qr*Rm(r,r) gives < pm , wr > = Rm(r,r)*Rm(r,m)
    % and < wr , wr > = Rm(r,r)^2. Rows 1:r_n of column m are already final
    % before this step (the mth reflection only touches rows m:end), so alpha
    % is filled in column by column exactly as in the Gram-Schmidt version.
    % Element-wise scalar divisions only; no matrix inverse is formed.
    alpha(1:r_n,m) = Rm(1:r_n,m) ./ d_Rm(1:r_n);
    alpha(m,m) = 1;
    d_Rm(m) = Rm(m,m);
    % -------------------------------------------------

    if m > 5 % stopping criteria invoked only after two terms are selected
        if ( sum(ERR(1:m)) - sum(ERR(1:m-4)) ) < 1e-4 %(MS_PRESS_E(m) >= MS_PRESS_E(m-1)) % PRESS statistic
            n_end = 0;
            break;
        end
    end

end

gm = gm(1:(m-n_end));
alpha = alpha(1:(m-n_end),1:(m-n_end));
theta = zeros((m-n_end),1);

ms_press_e = MS_PRESS_E(m-n_end);

MS_PRESS_E = MS_PRESS_E(1:m-n_end);
ERR = ERR(1:m-n_end);

ind_orth_wrt_org = ind_orth_wrt;

if n_end ~=0
    trm_chsn_logic_ind(ind_orth_wrt(m)) = 0;
    trm_chsn_ind(ind_orth_wrt(m)) = 0;
    ind_orth_wrt(m) = 0;
end
%% ------ Form final parameters ---------

theta(end) = gm(end);
for i = (m-1-n_end):-1:1
    theta(i) = gm(i) - alpha(i , (i+1):end ) * theta((i+1):end);
end

%%
ind_orth_wrt = ind_orth_wrt(logical(ind_orth_wrt));
ind_orth_wrt_org = ind_orth_wrt_org(logical(ind_orth_wrt_org));
end

%% ------ Householder vector ---------
function v = house_vec(x)
% Returns v, with v(1) = 1, such that ( I - 2*v*v'/(v'*v) )*x = -s*norm(x)*e1.
% The sign is taken explicitly: the usual v(1) = x(1) + sign(x(1))*norm(x)
% divides by zero whenever x(1) is exactly zero, since sign(0) = 0 in MATLAB.
nu = norm(x,2);
v = x;
if nu > 0
    if x(1) >= 0; s = 1; else; s = -1; end
    v = v ./ ( x(1) + s*nu );
end
v(1) = 1;
end

%% ------ Apply a Householder reflection from the left ---------
function A = row_house(A,v)
% A <- ( I - 2*v*v'/(v'*v) )*A , formed as a rank one update so that the
% reflector is never built explicitly. v'*v is a scalar, so the division is
% scalar arithmetic and no matrix is inverted.
A = A - ( (2/(v'*v)).*v ) * ( v' * A );
end
