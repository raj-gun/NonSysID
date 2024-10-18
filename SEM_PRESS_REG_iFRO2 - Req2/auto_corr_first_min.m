function min_lag = auto_corr_first_min(c_ac,lags_ac)

ac_zc = find(lags_ac == 0); % find zero lag position 
% diff_ac_pos = diff(c_ac(ac_zc:end)); % rate of change of auto corr in (+) direction
% diff_ac_neg = diff(flip(c_ac(1:ac_zc))); % rate of change of auto corr in (-) direction
% 
% diff_ac_pos_pgrd = find(diff_ac_pos > 0); % find positive rate of change in (+) dir. 
% ac_lag_pos_ind = ac_zc + diff_ac_pos_pgrd(1); % auto corr positive direction first minima index
% ac_lag_pos = abs(lags_ac(ac_lag_pos_ind)); % auto corr positive direction first minima
% 
% diff_ac_neg_pgrd = find(diff_ac_neg > 0); % find positive rate of change in (-) dir.
% ac_lag_neg_ind = ac_zc - diff_ac_neg_pgrd(1); % auto corr negative direction first minima index
% ac_lag_neg = abs(lags_ac(ac_lag_neg_ind)); % auto corr negative direction first minima
% 
% min_lag = min([ac_lag_pos,ac_lag_neg]); % first minima of auto corr function

diff_with_max_corr_pos_side = c_ac(ac_zc+1) - c_ac(ac_zc:end); % Relative difference between max AC and other lag positions, positive lags
diff_with_max_corr_neg_side = flip(c_ac(ac_zc+1) - c_ac(1:ac_zc)); % Relative difference between max AC and other lag positions, negative lags

[pcks_pos,locs_pos_side] = findpeaks(diff_with_max_corr_pos_side,'MinPeakProminence',0.01);%,'MinPeakDistance',475); % Find peaks of the 
[pcks_neg,locs_neg_side] = findpeaks(diff_with_max_corr_neg_side,'MinPeakProminence',0.01);%,'MinPeakDistance',475);

ac_lag_pos_side = abs(lags_ac(ac_zc + locs_pos_side(1)));
ac_lag_neg_side = abs(lags_ac(ac_zc - locs_neg_side(1)));

min_lag = min([ac_lag_pos_side,ac_lag_neg_side]); % First minima 

end

%% test

% [cc,ii] = sort(abs(diff_ac_pos),'ascend');
% 
% for i = 1:length(diff_ac_pos)
%     chck_diff_ac_pos_ind = diff_ac_pos_pgrd(i);
%     if (chck_diff_ac_pos_ind ~= 1) && (chck_diff_ac_pos_ind ~= length(diff_ac_pos))
%         if diff_ac_pos(chck_diff_ac_pos_ind - 1) < 0 && diff_ac_pos(chck_diff_ac_pos_ind + 1) > 0
%             break;
%         end
%     end
% end
% 
% 
% diff_ac_pos_norm = diff_ac_pos./sum((diff_ac_pos(2:end).^2));
% c_ac(ac_zc:end)
% 
% 


% 
% 
% figure;plot(diff_with_max_corr_pos_side);
% hold on;plot(locs_pos_side,pcks_pos,'Marker','o','LineStyle','none');
% 
% figure;plot(diff_with_max_corr_neg_side);
% hold on;plot(locs_neg_side,pcks_neg,'Marker','o','LineStyle','none');

