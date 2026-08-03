function [trm_chsn_lin_temp,iOFR_table_nl,trm_chsn_nl,...
    best_mod_ind_nl,ERR_table_nl,trm_lag_char_tot_nl,theta_nl,...
    X_main_nl,Mod_Val_dat_nl] = iOFRs_nl_SysID_P_i(...
    trm_chsn_lin,n_trms_rem,is_bias,trms,bias_trms_ind,...
    X_main_org,Y,Y_sim,U_delay_mat,n_lin_trms,trm_chsn_nl,...
    trm_lag_char_tot,stp_cri,alph,D1_thresh,displ,dat_len,...
    x_iOFR,best_msse_prev,best_press_prev)
%IOFRS_NL_SYSID_P_I Parallel nonlinear iOFR model selection for ARX-i.

trm_chsn_lin_temp = trm_chsn_lin;
cnt = 0;

while true
    cnt = cnt+1;
    iOFR_table_nl = cell(n_trms_rem,16);

    parfor j = 1:n_trms_rem
        if is_bias == 0
            frc_ind_temp = trms(j);
        else
            frc_ind_temp = [bias_trms_ind,trms(j)];
        end

        iOFR_table_nl_temp = OFR_nl_i(...
            X_main_org,Y,Y_sim,frc_ind_temp,U_delay_mat,...
            trm_chsn_lin_temp,n_lin_trms,trm_chsn_nl,trm_lag_char_tot,...
            stp_cri,alph,D1_thresh,displ);

        iOFR_table_nl(j,:) = iOFR_table_nl_temp;
    end

    mod_msse = cell2mat(iOFR_table_nl(:,2));
    mod_size = zeros(length(mod_msse),1);
    for kk = 1:length(mod_msse)
        mod_size(kk) = size(iOFR_table_nl{kk,10},1);
    end

    BIC = dat_len.*log(mod_msse./dat_len)+mod_size.*log(dat_len);
    [~,msse_vec_min_i] = min(BIC);
    best_msse = mod_msse(msse_vec_min_i);
    best_press = cell2mat(iOFR_table_nl(msse_vec_min_i,6));

    if ~x_iOFR
        % A single nonlinear iOFR pass is accepted only when both model
        % simulation error and PRESS improve on the best linear model.
        if best_msse < best_msse_prev && best_press < best_press_prev
            best_mod_ind_nl = msse_vec_min_i;
            best_struc = cell2mat(...
                iOFR_table_nl(best_mod_ind_nl,12));
            theta_nl = cell2mat(...
                iOFR_table_nl(best_mod_ind_nl,11));
            ERR_table_nl = iOFR_table_nl{best_mod_ind_nl,1};
            trm_chsn_lin_temp = cell2mat(...
                iOFR_table_nl(best_mod_ind_nl,7));
            trm_chsn_nl = cell2mat(...
                iOFR_table_nl(best_mod_ind_nl,8));
            trm_lag_char_tot_nl = trm_lag_char_tot(best_struc);
            X_main_nl = X_main_org(:,best_struc);
            Mod_Val_dat_nl = iOFR_table_nl{best_mod_ind_nl,14};
        else
            [iOFR_table_nl,ERR_table_nl,trm_lag_char_tot_nl,...
                trm_chsn_nl,best_mod_ind_nl,trm_chsn_lin_temp,...
                theta_nl,Mod_Val_dat_nl,X_main_nl] = ...
                reject_nonlinear_model_i();
        end
        break;
    end

    if cnt == 1
        % For iterative nonlinear iOFR, the first nonlinear model must
        % improve the simulation error relative to the linear model.
        if best_msse < best_msse_prev
            msse_vec_min_i_prev = msse_vec_min_i;
            iOFR_table_nl_prev = iOFR_table_nl;
            best_msse_prev = best_msse;
            best_press_prev = best_press;

            best_struc = cell2mat(...
                iOFR_table_nl(msse_vec_min_i,12));
            trms = best_struc;
            if is_bias == 1
                trms = trms(1:end-1);
            end
            n_trms_rem = length(trms);
        else
            [iOFR_table_nl,ERR_table_nl,trm_lag_char_tot_nl,...
                trm_chsn_nl,best_mod_ind_nl,trm_chsn_lin_temp,...
                theta_nl,Mod_Val_dat_nl,X_main_nl] = ...
                reject_nonlinear_model_i();
            break;
        end
    elseif best_msse < best_msse_prev || ...
            best_press < best_press_prev
        % Save the improved iteration before reducing its selected
        % structure for the next iOFR pass.
        msse_vec_min_i_prev = msse_vec_min_i;
        iOFR_table_nl_prev = iOFR_table_nl;
        best_msse_prev = best_msse;
        best_press_prev = best_press;

        best_struc = cell2mat(iOFR_table_nl(msse_vec_min_i,12));
        trms = best_struc;
        if is_bias == 1
            trms = trms(1:end-1);
        end
        n_trms_rem = length(trms);
    else
        % The current iteration did not improve either criterion. Return
        % the last saved iteration.
        best_mod_ind_nl = msse_vec_min_i_prev;
        iOFR_table_nl = iOFR_table_nl_prev;
        best_struc = cell2mat(...
            iOFR_table_nl(best_mod_ind_nl,12));
        theta_nl = cell2mat(...
            iOFR_table_nl(best_mod_ind_nl,11));
        ERR_table_nl = iOFR_table_nl{best_mod_ind_nl,1};
        trm_chsn_lin_temp = cell2mat(...
            iOFR_table_nl(best_mod_ind_nl,7));
        trm_chsn_nl = cell2mat(...
            iOFR_table_nl(best_mod_ind_nl,8));
        trm_lag_char_tot_nl = trm_lag_char_tot(best_struc);
        X_main_nl = X_main_org(:,best_struc);
        Mod_Val_dat_nl = iOFR_table_nl{best_mod_ind_nl,14};
        break;
    end
end
end

function [iOFR_table_nl,ERR_table_nl,trm_lag_char_tot_nl,...
    trm_chsn_nl,best_mod_ind_nl,trm_chsn_lin_temp,...
    theta_nl,Mod_Val_dat_nl,X_main_nl] = reject_nonlinear_model_i()
%REJECT_NONLINEAR_MODEL_I Return the established linear-model sentinel.

iOFR_table_nl = 0;
ERR_table_nl = 0;
trm_lag_char_tot_nl = 0;
trm_chsn_nl = [];
best_mod_ind_nl = 0;
trm_chsn_lin_temp = 0;
theta_nl = 0;
Mod_Val_dat_nl = 0;
X_main_nl = 0;
end
