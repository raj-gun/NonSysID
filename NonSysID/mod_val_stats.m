function val_stats = mod_val_stats(Mod_Val_dat)
no_valds = size(Mod_Val_dat{1,1},2)-1;
val_stats = zeros(no_valds,3);
for k=1:length(Mod_Val_dat{1, 2})
    lag = Mod_Val_dat{1,1}(:,1);
    lag_5_ind = (lag > -5) & (lag < 5); %indexes where -5 < lag < 5
    cc_cc = Mod_Val_dat{1,1}(:,2:end,k); cc_cc(lag_5_ind,1) = 0;
    conf_inv = Mod_Val_dat{1, 2}(k);
    
    cc_cc_fl = zeros(size(cc_cc));
    cc_cc_ind = (cc_cc < -conf_inv); cc_cc_fl(cc_cc_ind) = abs(cc_cc(cc_cc_ind) + conf_inv);
    cc_cc_ind = (cc_cc > conf_inv); cc_cc_fl(cc_cc_ind) = abs(cc_cc(cc_cc_ind) - conf_inv);
    cc_cc_fl = cc_cc_fl./conf_inv;
    cc_cc_ind = (cc_cc > conf_inv) | (cc_cc < -conf_inv);
    
    cc_cc_ind_4 = cc_cc_fl > 0.04; %anything greater than 4%
    cc_cc_sum = zeros(1,no_valds); for z=1:no_valds;cc_cc_sum(z) = sum(cc_cc_fl(cc_cc_ind_4(:,z), z) );end
    
    %cc_cc_mean = zeros(1,5); for z=1:5;cc_cc_mean(z) = mean(cc_cc_fl(cc_cc_ind(:,z), z) );end
    %cc_cc_median = zeros(1,5); for z=1:5;cc_cc_median(z) = median(cc_cc_fl(cc_cc_ind(:,z), z) );end
    %cc_cc_sum = zeros(1,5); for z=1:5;cc_cc_sum(z) = sum(cc_cc_fl(cc_cc_ind(:,z), z) );end
    
    val_stats(:,k) = sum(cc_cc_ind_4);%cc_cc_sum;
end
end