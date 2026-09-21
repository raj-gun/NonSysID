function [clstr_table] = trm_clstr(iOFR_table_lin,iOFR_table_nl,best_mod_ind_lin,best_mod_ind_nl,displ)

%Represents a model identified by NonSysID, NonSysID-i or NonSysID-AR-NFIR
%in terms of its term clusters (Aguirre and Billings, 1995). A term cluster
%is the set of model terms that share the same monomial structure once the
%lags are ignored, e.g. u1(t-1)u1(t-3), u1(t-1)^2 and u1(t-5)^2 all belong
%to the cluster Σ_{u1^2}, while y1(t-1)u1(t-2)^2 belongs to Σ_{y1u1^2}. The
%cluster notation follows Gunawardena and He (arXiv:2603.08866). The
%coefficient of a cluster is the sum of the coefficients (theta) of its
%member terms, and the ERR of a cluster is the sum of the ERRs of its
%member terms. The best NARX model is used if one was identified
%(best_mod_ind_nl ~= 0), otherwise the best ARX model is used.
%
%Notes on interpretation:
% - The ERR of each term depends on the orthogonalisation path of the
%   iOFR, hence so does the ERR of each cluster.
% - Cluster coefficients are most informative when the sampling time is
%   short relative to the system dynamics (Aguirre and Billings, 1995,
%   eq. 7), such that the terms within a cluster are similar.
%
%Inputs:
% iOFR_table_lin   - iOFR results of the candidate linear models
% iOFR_table_nl    - iOFR results of the candidate nonlinear models (0 if none)
% best_mod_ind_lin - Index of the selected linear model
% best_mod_ind_nl  - Index of the selected nonlinear model (0 if none)
% displ            - 1 = display the term cluster table, 0 = no display
%
%Output:
% clstr_table      - Table with the variables ERR and theta, with the
%                    term cluster notations as the row names

sgma = char(931); % Σ, character code used to avoid source file encoding issues
var_ord = {'y','u','e'}; % Order of variables in a cluster notation: outputs, inputs, noise
pat_lag = '([a-zA-Z]+)(\d+)\(t-?\d+\)'; % Character pattern of a lagged term, e.g. u1(t-2)

% ----------------- Select the model table of the best model --------------
if best_mod_ind_nl ~= 0
    ERR_table = iOFR_table_nl{best_mod_ind_nl,1}; % Best NARX model
else
    ERR_table = iOFR_table_lin{best_mod_ind_lin,1}; % Best ARX model
end
trm_char = ERR_table.Properties.RowNames; % Character identifiers of the model terms
ERR = ERR_table.ERR; % ERR of each model term
theta = ERR_table.theta; % Coefficient of each model term
n_trms = length(trm_char); % No. of model terms
% -------------------------------------------------------------------------

% ------------- Identify the term cluster of each model term --------------
trm_clstr_char = cell(n_trms,1); % Cluster notation of each model term
trm_clstr_rnk = cell(n_trms,1); % Ordering ranks of the lagged terms of each model term
for i = 1:n_trms
    trm_str = trm_char{i}; % Term identification string
    if strcmp(trm_str,'bias')
        trm_clstr_char{i} = [sgma,'_{bias}'];
        trm_clstr_rnk{i} = []; % The bias cluster is placed last
        continue;
    end

    tkn = regexp(trm_str,pat_lag,'tokens'); % Variable letter and index of each lagged term
    lag_rnk = cellfun(@(c) lag_rnk_var(c,var_ord),tkn); % Ordering rank of each lagged term, e.g. y1 -> 1001, u2 -> 2002
    [lag_rnk,srt_l] = sort(lag_rnk,'ascend'); % Canonical order of the lagged terms
    tkn = tkn(srt_l);
    trm_clstr_rnk{i} = lag_rnk;

    % ------ Compose the cluster notation, e.g. [y1,u1,u1] -> Σ_{y1u1^2} ------
    [unq_rnk,unq_ind] = unique(lag_rnk,'stable'); % Distinct variables of the term
    clstr_str = '';
    for j = 1:length(unq_rnk)
        n_pwr = sum(lag_rnk == unq_rnk(j)); % Power of the variable
        tkn_j = tkn{unq_ind(j)}; % Variable letter and index
        if n_pwr == 1
            clstr_str = [clstr_str,tkn_j{1},tkn_j{2}]; %#ok<AGROW>
        else
            clstr_str = [clstr_str,tkn_j{1},tkn_j{2},'^',num2str(n_pwr)]; %#ok<AGROW>
        end
    end
    trm_clstr_char{i} = [sgma,'_{',clstr_str,'}'];
end
% -------------------------------------------------------------------------

% ------- Sum the coefficients and ERRs of the terms in each cluster ------
[clstr_char,unq_trm_ind,clstr_ind] = unique(trm_clstr_char,'stable');
n_clstr = length(clstr_char); % No. of term clusters
ERR_clstr = accumarray(clstr_ind,ERR); % Cluster ERR
theta_clstr = accumarray(clstr_ind,theta); % Cluster coefficient
% -------------------------------------------------------------------------

% ---------- Order the clusters by degree and then by variable ------------
max_deg = max([cellfun(@length,trm_clstr_rnk);1]); % Maximum degree of the model
srt_key = zeros(n_clstr,max_deg+1); % [degree, lagged term ranks padded with zeros]
for i = 1:n_clstr
    lag_rnk = trm_clstr_rnk{unq_trm_ind(i)};
    if isempty(lag_rnk)
        srt_key(i,1) = inf; % bias
    else
        srt_key(i,1) = length(lag_rnk);
        srt_key(i,2:length(lag_rnk)+1) = lag_rnk;
    end
end
[~,srt_i] = sortrows(srt_key);
clstr_char = clstr_char(srt_i);
ERR = ERR_clstr(srt_i);
theta = theta_clstr(srt_i);
% -------------------------------------------------------------------------

clstr_table = table(ERR,theta,'RowNames',clstr_char);
if displ == 1
    disp(clstr_table);
    disp(['SERR = ',num2str(sum(ERR))]);
end

end



function lag_rnk = lag_rnk_var(tkn,var_ord)
%Ordering rank of a lagged term, i.e. (rank of its variable letter)x1e3 +
%(index of its variable), e.g. y1(t-1) -> 1001 and u2(t-3) -> 2002. It is
%used to order the lagged terms of a model term and the term clusters of a
%model, and is not an index into any array.
var_rnk = find(strcmp(var_ord,tkn{1})); % Rank of the variable letter
if isempty(var_rnk);var_rnk = length(var_ord)+1;end % Unknown variable letters are placed last
lag_rnk = var_rnk*1e3 + str2double(tkn{2});
end
