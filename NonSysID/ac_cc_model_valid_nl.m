function [dat,conf_inv] = ac_cc_model_valid_nl(error_sim_ext,U,max_lag,plt)
len_err_sim = length(error_sim_ext);
var_err_sim = var(error_sim_ext);%(error_sim_ext'*error_sim_ext);%/len_err_sim;%
dat = zeros(len_err_sim*2 - 1, 6);

conf_inv = (1.96/sqrt(len_err_sim))*sqrt(var_err_sim);

[c_ac,lags_ac] = xcorr(error_sim_ext,error_sim_ext,'normalized');
dat(:,1) = lags_ac; dat(:,2) = c_ac;
if plt==1
    figure('OuterPosition',[237 224.2 897.6 577.6]);subplot(3,2,1);plot(lags_ac,c_ac);hold on;plot(lags_ac,conf_inv*ones(1,length(lags_ac)),'r');
    plot(lags_ac,-conf_inv*ones(1,length(lags_ac)),'r');axis([-max_lag max_lag -Inf Inf]);
    xlabel('Lag');ylabel('ACF Amplitude');title('ACF of the Residuals');
end

if ~isempty(U)
    [c_cc,lags_cc] = xcorr(error_sim_ext,U,'normalized');
    dat(:,3) = c_cc;
    if plt==1
        subplot(3,2,2);plot(lags_cc,c_cc);hold on;plot(lags_cc,conf_inv*ones(1,length(lags_cc)),'r');
        plot(lags_cc,-conf_inv*ones(1,length(lags_cc)),'r');axis([-max_lag max_lag -Inf Inf])
        xlabel('Lag');ylabel('Cross-CF Amplitude');
        title('Cross-CF of the Residuals with the input');
    end

    [c_cc,lags_cc] = xcorr(error_sim_ext(1:end-1),error_sim_ext(2:end).*U(2:end),'normalized');
    dat(1:end-2,4) = c_cc;
    if plt==1
        subplot(3,2,3);plot(lags_cc,c_cc);hold on;plot(lags_cc,conf_inv*ones(1,length(lags_cc)),'r');
        plot(lags_cc,-conf_inv*ones(1,length(lags_cc)),'r');axis([-max_lag max_lag -Inf Inf])
        xlabel('Lag');ylabel('Cross-CF Amplitude');
        title('Cross-CF of the Residuals with the input \epsilon(\epsilon\itu)');
    end

    [c_cc,lags_cc] = xcorr( (U.^2)-mean(U.^2) ,error_sim_ext,'normalized');
    dat(:,5) = c_cc;
    if plt==1
        subplot(3,2,4);plot(lags_cc,c_cc);hold on;plot(lags_cc,conf_inv*ones(1,length(lags_cc)),'r');
        plot(lags_cc,-conf_inv*ones(1,length(lags_cc)),'r');axis([-max_lag max_lag -Inf Inf])
        xlabel('Lag');ylabel('Cross-CF Amplitude');
        title('Cross-CF of the Residuals with the input (\itu^2)\epsilon');
    end

    [c_cc,lags_cc] = xcorr( (U.^2)-mean(U.^2) ,error_sim_ext.^2,'normalized');
    dat(:,6) = c_cc;
    if plt==1
        subplot(3,2,5);plot(lags_cc,c_cc);hold on;plot(lags_cc,conf_inv*ones(1,length(lags_cc)),'r');
        plot(lags_cc,-conf_inv*ones(1,length(lags_cc)),'r');axis([-max_lag max_lag -Inf Inf])
        xlabel('Lag');ylabel('Cross-CF Amplitude');
        title('Cross-CF of the Residuals with the input (\itu^2)\epsilon^2');
    end

else
    dat(:,3:end)=0;
end

end