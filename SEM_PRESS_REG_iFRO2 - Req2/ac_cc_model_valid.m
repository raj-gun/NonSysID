function [dat,conf_inv] = ac_cc_model_valid(error_sim_ext,U,max_lag,plt)
len_err_sim = length(error_sim_ext);
var_err_sim = var(error_sim_ext);%(error_sim_ext'*error_sim_ext)/len_err_sim;
dat = zeros(len_err_sim*2 - 1, 3);
conf_inv = (1.96/sqrt(len_err_sim))*sqrt(var_err_sim);

[c_ac,lags_ac] = xcorr(error_sim_ext,error_sim_ext,'coeff');
dat(:,1) = lags_ac; dat(:,2) = c_ac;
if plt==1
    figure;subplot(2,1,1);plot(lags_ac,c_ac);hold on;plot(lags_ac,conf_inv*ones(1,length(lags_ac)),'r');
    plot(lags_ac,-conf_inv*ones(1,length(lags_ac)),'r');axis([-max_lag max_lag -Inf Inf]);
    xlabel('Lag');ylabel('ACF Amplitude');title('ACF of the Residuals');
end

[c_cc,lags_cc] = xcorr(error_sim_ext,U,'coeff');
dat(:,3) = c_cc;
if plt==1
    subplot(2,1,2);plot(lags_cc,c_cc);hold on;plot(lags_cc,conf_inv*ones(1,length(lags_cc)),'r');
    plot(lags_cc,-conf_inv*ones(1,length(lags_cc)),'r');axis([-max_lag max_lag -Inf Inf])
    xlabel('Lag');ylabel('Cross-CF Amplitude');
    title('Cross-CF of the Residuals with the input');
end
end