function [trm_chsn_lin_temp, iFRO_table_nl, trm_chsn_nl, best_mod_ind_nl, ERR_table_nl, trm_lag_char_tot_nl, theta_nl, X_main_nl, Mod_Val_dat_nl] = iFRO_nl_SysID...
    (trm_chsn_lin, n_trms_rem, is_bias, trms, bias_trms_ind, k, X, X_main_org, Y, Y_sim, n_terms_y, U_delay_mat, trm_chsn_lin_org, n_lin_trms_org, n_lin_trms,...
    y_lag_lin_srt, nl_ord_max, trm_chsn_nl, trm_lag_char_tot, reg_itr_end, lambda_ini, lamda_stp, stp_cri, alph, D1_thresh, displ, dat_len, x_iFRO, best_msse_prev, best_press_prev)
    trm_chsn_lin_temp = trm_chsn_lin;
    cnt = 0;
    while true
        cnt = cnt + 1;
        iFRO_table_nl = cell(n_trms_rem,16);
        parfor j = 1:n_trms_rem
            if is_bias == 0
                frc_ind_temp = trms(j);
            else                % if a bias is needed then the bias term is chosen first followed by other terms
                frc_ind_temp = [bias_trms_ind , trms(j)];
            end
            [iFRO_table_nl_temp] = iFRO_PRLR_SEM_OLS_nl(k,X,X_main_org,Y,Y_sim,frc_ind_temp,n_terms_y,U_delay_mat,trm_chsn_lin_org,trm_chsn_lin_temp,n_lin_trms_org,n_lin_trms,y_lag_lin_srt,nl_ord_max,trm_chsn_nl,trm_lag_char_tot,...
                reg_itr_end,lambda_ini,lamda_stp,stp_cri,alph,D1_thresh,displ);
            for jj=1:16;iFRO_table_nl{j,jj} = iFRO_table_nl_temp{jj};end
        end
        %-------------------
        %[msse_vec_min_c,msse_vec_min_i] = min( cell2mat(iFRO_table_nl(:,2)) );
        %-------------------
        %[msse_vec_min_c,msse_vec_min_i] = min(cell2mat(iFRO_table_nl(better_msse_logic, 6))); msse_vec_min_c = msse_vec(msse_vec_min_i);
        %-------------------
        mod_msse = cell2mat(iFRO_table_nl(:,2));
        mod_size = zeros(length(mod_msse), 1); for k=1:length(mod_msse); mod_size(k) = size( iFRO_table_nl{k,10} , 1);end
        BIC = ( dat_len .* log(mod_msse ./ dat_len) ) + ( mod_size .* log(dat_len) );
        [~,msse_vec_min_i] = min(BIC); msse_vec_min_c = mod_msse(msse_vec_min_i);
        %-------------------
        best_msse = msse_vec_min_c; best_press = cell2mat(iFRO_table_nl(msse_vec_min_i, 6));
        if ~x_iFRO && (best_msse < best_msse_prev) && (best_press < best_press_prev)
            best_mod_ind_nl = msse_vec_min_i;
            best_struc = cell2mat(iFRO_table_nl(best_mod_ind_nl,12));
            best_theta = cell2mat(iFRO_table_nl(best_mod_ind_nl,11));
            ERR_table_nl = iFRO_table_nl{best_mod_ind_nl,1};
            trm_chsn_lin_temp = cell2mat(iFRO_table_nl(best_mod_ind_nl,7));
            trm_chsn_nl =  cell2mat(iFRO_table_nl(best_mod_ind_nl,8));
            trm_lag_char_tot_nl = trm_lag_char_tot(best_struc);
            theta_nl = best_theta;
            X_main_nl = X_main_org(:,best_struc);
            Mod_Val_dat_nl = iFRO_table_nl{:,14};
            break;
        elseif (cnt ~= 1) && ( (best_msse < best_msse_prev) || (best_press < best_press_prev) ) % Continue while loop----------
            msse_vec_min_i_prev = msse_vec_min_i; iFRO_table_nl_prev = iFRO_table_nl;
            best_msse_prev = best_msse; best_press_prev = best_press;
            best_struc = cell2mat(iFRO_table_nl(msse_vec_min_i,12));
            trms = best_struc;
            if is_bias == 1;trms = trms(1:end-1);end
            n_trms_rem = length(trms); %----------
        elseif (cnt == 1) && (best_msse >= best_msse_prev) %&& (best_press >= best_press_prev) % 1st iFRO interation, if best MSSE is from linear model -- output linear model as chosen structure
            iFRO_table_nl = 0; ERR_table_nl = 0;
            trm_lag_char_tot_nl = 0;
            trm_chsn_nl = []; best_mod_ind_nl = 0; trm_chsn_lin_temp = 0;
            theta_nl = 0; Mod_Val_dat_nl = 0; X_main_nl = 0;
            % if is_bias == 1; X_main_nl = 0; end
            %disp('Linear model is the best possible');
            break;
        elseif (cnt ~= 1) && (best_msse >= best_msse_prev) && (best_press >= best_press_prev) % iFRO interation, if best MSSE is from previous iteration
            best_mod_ind_nl = msse_vec_min_i_prev; iFRO_table_nl = iFRO_table_nl_prev;
            best_struc = cell2mat(iFRO_table_nl(best_mod_ind_nl,12));
            best_theta = cell2mat(iFRO_table_nl(best_mod_ind_nl,11));
            ERR_table_nl = iFRO_table_nl{best_mod_ind_nl,1};
            trm_chsn_lin_temp = cell2mat(iFRO_table_nl(best_mod_ind_nl,7));
            trm_chsn_nl =  cell2mat(iFRO_table_nl(best_mod_ind_nl,8));
            trm_lag_char_tot_nl = trm_lag_char_tot(best_struc);
            theta_nl = best_theta;
            X_main_nl = X_main_org(:,best_struc);
            Mod_Val_dat_nl = iFRO_table_nl{:,14};
            %disp([err_type,' of best model = ',num2str(best_msse)]);
            break;
        end
    end
end