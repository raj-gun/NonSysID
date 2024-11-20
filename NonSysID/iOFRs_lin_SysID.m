function [iOFR_table_lin, trm_chsn_lin, best_press, best_msse, theta_lin, ERR_table_lin, best_mod_ind_lin] = iOFRs_lin_SysID...
    (n_lin_trms_rem, is_bias, trm_chsn_lin, n_terms, k, X_main, Y, Y_sim, n_terms_y, U_delay_mat, n_lin_trms_org, y_lag_lin_srt,...
    trm_lag_char_lin, stp_cri, D1_thresh, alph, displ, dat_len, x_iOFR, best_msse_prev, best_press_prev)
cnt = 1;
while true
    iOFR_table_lin = cell(n_lin_trms_rem,14);
    parfor j = 1:n_lin_trms_rem
        if is_bias == 0
            frc_ind_temp = trm_chsn_lin(j);
        else                 % if a bias is needed then the bias term is chosen first followed by other terms
            frc_ind_temp = [(n_terms+1) , trm_chsn_lin(j)];
        end 
        iOFR_table_lin_temp = OFR_lin(k,X_main,Y,Y_sim,frc_ind_temp,n_terms_y,U_delay_mat,n_lin_trms_org,y_lag_lin_srt,trm_lag_char_lin,stp_cri,D1_thresh,alph,displ);
        for jj=1:14;iOFR_table_lin{j,jj} = iOFR_table_lin_temp{jj};end
    end
    mod_msse = cell2mat(iOFR_table_lin(:,2));
    mod_size = zeros(length(mod_msse), 1); for k=1:length(mod_msse); mod_size(k) = size( iOFR_table_lin{k,9} , 1);end
    BIC = ( dat_len .* log(mod_msse ./ dat_len) ) + ( mod_size .* log(dat_len) );
    [~,msse_vec_min_i] = min(BIC); msse_vec_min_c = mod_msse(msse_vec_min_i);

    best_press = cell2mat(iOFR_table_lin(msse_vec_min_i, 6));
    best_msse = msse_vec_min_c;
    trm_chsn_lin = cell2mat( iOFR_table_lin(msse_vec_min_i,12) );
    theta_lin = cell2mat( iOFR_table_lin(msse_vec_min_i,10) );
    ERR_table_lin = iOFR_table_lin{msse_vec_min_i,1};
    best_mod_ind_lin = msse_vec_min_i;
    if ~x_iOFR; break; end
    %-------------------------------------
    if best_msse < best_msse_prev && best_press < best_press_prev
        n_lin_trms_rem = length(trm_chsn_lin);
        iOFR_table_lin_prev = iOFR_table_lin;
        best_msse_prev = best_msse;
        best_press_prev = best_press;
        trm_chsn_lin_prev = trm_chsn_lin;
        best_mod_ind_lin_prev = best_mod_ind_lin;
        if is_bias == 1;n_lin_trms_rem=n_lin_trms_rem-1;trm_chsn_lin = trm_chsn_lin(1:end-1);end
    elseif cnt==1 && ~(best_msse < best_msse_prev && best_press < best_press_prev)
        break;
    else
        iOFR_table_lin = iOFR_table_lin_prev;
        trm_chsn_lin = trm_chsn_lin_prev;
        best_msse = best_msse_prev;
        best_press = best_press_prev;
        best_mod_ind_lin = best_mod_ind_lin_prev;
        break;
    end
    cnt = cnt+1;
end
end