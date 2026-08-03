function [model,Mod_Val_dat,iOFR_table_lin,iOFR_table_nl,...
    best_mod_ind_lin,best_mod_ind_nl,val_stats] = NonSysID_i(...
    mod_type,u,y,a1,a2,b1,b2,nl_ord_max,is_bias,n_inpts,...
    KSA_h,RCT,x_iOFR,stp_cri,D1_thresh,displ,sim,parall)
%NONSYSID_I Input-only extension of NonSysID.
%
% Model type:
%   'ARX-i' - polynomial input-only model. Candidate regressors contain
%             lagged inputs only; lagged outputs are never included.
%
% The a1 and a2 inputs are retained for call compatibility with NonSysID,
% but they are not used to form the ARX-i candidate dictionary.
%
% For ARX-i, OSA, k-step-ahead and free-run outputs are identical.

if ~strcmp(mod_type,'ARX-i')
    error('NonSysID-i:InvalidModelType',...
        'Use mod_type = ''ARX-i'' with NonSysID_i.');
end
if isempty(u)
    error('NonSysID-i:MissingInput',...
        'ARX-i requires at least one measured input.');
end
if size(u,2) ~= n_inpts
    error('NonSysID-i:InputCountMismatch',...
        'n_inpts must equal size(u,2).');
end
if numel(parall) ~= 2 || any((parall ~= 0) & (parall ~= 1))
    error('NonSysID-i:InvalidParallelOption',...
        'parall must be a two-element vector containing only 0 or 1.');
end

min_dyn_ord_u = ones(1,n_inpts).*b1;
max_dyn_ord_u = ones(1,n_inpts).*b2;
inpt0 = zeros(1,n_inpts);

[U_delay_mat_ID,X_ID,Y_ID] = info_mat_sysID_i(...
    min_dyn_ord_u,max_dyn_ord_u,u,y);
Y_simID = Y_ID;

[theta,~,trm_chsn_lin,trm_chsn_lin_org,n_lin_trms_org,...
    ~,trm_chsn_nl,~,iOFR_table_lin,iOFR_table_nl,...
    ERR_table_lin,ERR_table_nl,best_mod_ind_lin,...
    best_mod_ind_nl,Mod_Val_dat] = Sys_ID_iOFRs_PRESS_i(...
    RCT,mod_type,U_delay_mat_ID,X_ID,Y_ID,Y_simID,...
    min_dyn_ord_u,max_dyn_ord_u,nl_ord_max,is_bias,inpt0,...
    stp_cri,5,D1_thresh,displ,x_iOFR,parall);

if ~isequal(size(ERR_table_nl),[1,1])
    SERR = sum(ERR_table_nl.ERR);
    ERR_table = ERR_table_nl;
    MS_PRESS_E = min(iOFR_table_nl{best_mod_ind_nl,10}.MS_PRESS_E);
    val_stats = iOFR_table_nl{best_mod_ind_nl,16};
else
    SERR = sum(ERR_table_lin.ERR);
    ERR_table = ERR_table_lin;
    MS_PRESS_E = min(iOFR_table_lin{best_mod_ind_lin,9}.MS_PRESS_E);
    val_stats = 0;
end

if is_bias == 0
    theta_process = theta;
    bias = 0;
else
    theta_process = theta(1:end-1);
    bias = theta(end);
end

if sim(1) == 1
    y_pred = one_step_pred_model_reg(X_ID,theta_process,...
        trm_chsn_lin,trm_chsn_lin_org,n_lin_trms_org,...
        nl_ord_max,trm_chsn_nl,bias);

    y_est = y_pred;
    Y_kSA = y_pred;

    error = Y_ID-y_est;
    msse = (error'*error)/length(Y_ID);
    mspe = msse;
    mskpe = msse;

    if sim(2) == 1
        figure;
        subplot(3,1,1);
        plot(Y_ID,'LineWidth',1.5);
        hold on;
        plot(y_est,'k-.','LineWidth',1.25);
        hold off;
        title('MPO/Free-run (identical for ARX-i)');
        legend('Actual Output','Model generated');

        subplot(3,1,2);
        plot(Y_ID,'LineWidth',1.5);
        hold on;
        plot(Y_kSA,'k-.','LineWidth',1.25);
        hold off;
        title([num2str(KSA_h),...
            '-steps Ahead Prediction (identical for ARX-i)']);

        subplot(3,1,3);
        plot(Y_ID,'LineWidth',1.5);
        hold on;
        plot(y_pred,'k-.','LineWidth',1.25);
        hold off;
        title('One-step Ahead Prediction');

        disp('--------------------');
        disp(['MSSE = ',num2str(msse)]);
        disp(['MSkPE = ',num2str(mskpe)]);
        disp(['MSPE = ',num2str(mspe)]);
        disp('--------------------');
    end
end

% a1/a2 are retained in the model cell to preserve the established layout.
if sim(1) == 0
    model = {a1,a2,b1,b2,theta_process,trm_chsn_lin,trm_chsn_lin_org,n_lin_trms_org,nl_ord_max,trm_chsn_nl,bias,n_inpts,[],SERR,MS_PRESS_E,ERR_table};
else
    model = {a1,a2,b1,b2,theta_process,trm_chsn_lin,trm_chsn_lin_org,n_lin_trms_org,nl_ord_max,trm_chsn_nl,bias,n_inpts,[],msse,mspe,mskpe,SERR,MS_PRESS_E,ERR_table};
end
