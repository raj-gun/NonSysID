function [trm_lag_char_lin, X] = iOFR_trm_char(no_outpts, max_dyn_ord_y, no_inpts, inpt0, max_dyn_ord_u, n_terms_y, n_terms_u, mod_type, is_bias, min_dyn_ord_y, min_dyn_ord_u, X, dat_len)

% ----- Charater identifiers of the linear lagged terms --------------

switch mod_type
    case 'ARX'
        trm_delay_Y = cell(1,no_outpts);
        for j = 1:no_outpts %
            trm_delay_Y{j} = -1.*(1:1:max_dyn_ord_y(j))';
        end
        trm_delay_U = cell(1,no_inpts);
        for j = 1:no_inpts
            if inpt0(j) == 0
                trm_delay_U{j} = -1.*(1:1:max_dyn_ord_u(j))';
            else
                trm_delay_U{j} = -1.*(0:1:max_dyn_ord_u(j)-1)';
            end
        end
        %-------------------------
        y_lag_char = cell(n_terms_y,1);
        u_lag_char = cell(n_terms_u,1);
        loop_cnt = 1;
        for j = 1:no_outpts
            for i = 1:max_dyn_ord_y(j)
                y_lag_char{loop_cnt} = sprintf('y%d(t%d)' , j , trm_delay_Y{j}(i) );
                loop_cnt = loop_cnt + 1;
            end
        end
        loop_cnt = 1;
        for j = 1:no_inpts
            for i = 1:max_dyn_ord_u(j)
                u_lag_char{loop_cnt} = sprintf('u%d(t%d)' , j , trm_delay_U{j}(i) );
                loop_cnt = loop_cnt + 1;
            end
        end
        %-------------------------
        if is_bias == 0
            trm_lag_char_lin = [{y_lag_char{min_dyn_ord_y:max_dyn_ord_y}},{u_lag_char{min_dyn_ord_u:max_dyn_ord_u}}];
        else
            trm_lag_char_lin = [{y_lag_char{min_dyn_ord_y:max_dyn_ord_y}},{u_lag_char{min_dyn_ord_u:max_dyn_ord_u}},'bias'];
            X = [X,ones(dat_len,1)];
        end
    case 'AR'
        trm_delay_Y = cell(1,no_outpts);
        for j = 1:no_outpts %
            trm_delay_Y{j} = -1.*(1:1:max_dyn_ord_y(j))';
        end
        %-------------------------
        y_lag_char = cell(n_terms_y,1);
        loop_cnt = 1;
        for j = 1:no_outpts
            for i = 1:max_dyn_ord_y(j)
                y_lag_char{loop_cnt} = sprintf('y%d(t%d)' , j , trm_delay_Y{j}(i) );
                loop_cnt = loop_cnt + 1;
            end
        end
        %-------------------------
        X = X(:,min_dyn_ord_y:max_dyn_ord_y);
        if is_bias == 0
            trm_lag_char_lin = [{y_lag_char{min_dyn_ord_y:max_dyn_ord_y}}];%[u_lag_char'];%
        else
            trm_lag_char_lin = [{y_lag_char{min_dyn_ord_y:max_dyn_ord_y}},'bias'];%[u_lag_char','bias'];%
            X = [X,ones(dat_len,1)];
        end
    case 'ErrMA'
        trm_delay_Y = cell(1,no_outpts);
        for j = 1:no_outpts %
            trm_delay_Y{j} = -1.*(1:1:max_dyn_ord_y(j))';
        end
        %-------------------------
        y_lag_char = cell(n_terms_y,1);
        loop_cnt = 1;
        for j = 1:no_outpts
            for i = 1:max_dyn_ord_y(j)
                y_lag_char{loop_cnt} = sprintf('e%d(t%d)' , j , trm_delay_Y{j}(i) );
                loop_cnt = loop_cnt + 1;
            end
        end
        %-------------------------
        if is_bias == 0
            trm_lag_char_lin = [{y_lag_char{min_dyn_ord_y:max_dyn_ord_y}}];%[u_lag_char'];%
        else
            trm_lag_char_lin = [{y_lag_char{min_dyn_ord_y:max_dyn_ord_y}},'bias'];%[u_lag_char','bias'];%
            X = [X,ones(dat_len,1)];
        end
%     case 'ErrY'
%     case 'ErrU'
    case 'ErrYU'
        trm_delay_Y = cell(1,no_outpts);
        for j = 1:no_outpts %
            trm_delay_Y{j} = -1.*(1:1:max_dyn_ord_y(j))';
        end
        trm_delay_U = cell(1,no_inpts);
        for j = 1:no_inpts
            if inpt0(j) == 0
                trm_delay_U{j} = -1.*(1:1:max_dyn_ord_u(j))';
            else
                trm_delay_U{j} = -1.*(0:1:max_dyn_ord_u(j)-1)';
            end
        end
        %-------------------------
        y_lag_char = cell(n_terms_y,1);
        u_lag_char = cell(n_terms_u,1);
        loop_cnt = 1;
        for j = 1:no_outpts
            for i = min_dyn_ord_y(j):max_dyn_ord_y(j)
                y_lag_char{loop_cnt} = sprintf('e%d(t%d)' , j , trm_delay_Y{j}(i) );
                loop_cnt = loop_cnt + 1;
            end
        end
        loop_cnt = 1;
        for j = 1:no_inpts
            for i = min_dyn_ord_u(j):max_dyn_ord_u(j)
                u_lag_char{loop_cnt} = sprintf('u%d(t%d)' , j , trm_delay_U{j}(i) );
                loop_cnt = loop_cnt + 1;
            end
        end
        %-------------------------
        if is_bias == 0
            trm_lag_char_lin = [{y_lag_char{:}},{u_lag_char{:}}];
        else
            trm_lag_char_lin = [{y_lag_char{:}},{u_lag_char{:}},'bias'];
            X = [X,ones(dat_len,1)];
        end
end
end