

[AIC_03,BIC_03] = AIC_BIC(data03(:,5), data03(:,8), 188);

[AIC_36,BIC_36] = AIC_BIC(data36(:,5), data36(:,8), 188);

[AIC_69,BIC_69] = AIC_BIC(data69(:,5), data69(:,8), 188);

[AIC_015,BIC_015] = AIC_BIC(data015(:,7), data015(:,8), 188);




figure;plot( data03(:,8) ,  BIC_03 , 'o');hold on;
plot( data36(:,8) ,  BIC_36 , 'o');plot( data69(:,8) ,  BIC_69 , 'o');plot( data015(:,8) ,  BIC_015 , 'o');hold off;
legend('03','36','69','015')

figure;subplot(411);plot( data03(:,8) ,  BIC_03 , 'o');
subplot(412);plot( data36(:,8) ,  BIC_36 , 'o');
subplot(413);plot( data69(:,8) ,  BIC_69 , 'o');
subplot(414);plot( data015(:,8) ,  BIC_015 , 'o');

%%

[AIC_05,BIC_05] = AIC_BIC(data05(:,5), data05(:,8), 313);

[AIC_510,BIC_510] = AIC_BIC(data510(:,5), data510(:,8), 313);

% [AIC_69,BIC_69] = AIC_BIC(data69(:,5), data69(:,8), 188);
% 
% [AIC_015,BIC_015] = AIC_BIC(data015(:,7), data015(:,8), 188);




figure;plot( data05(:,8) ,  BIC_05 , 'o');hold on;
plot( data510(:,8) ,  BIC_510 , 'o');hold off;
legend('05','510');

figure;subplot(211);plot( data05(:,8) ,  BIC_05 , 'o');
subplot(212);plot( data510(:,8) ,  BIC_510 , 'o');
% subplot(413);plot( data69(:,8) ,  BIC_69 , 'o');
% subplot(414);plot( data015(:,8) ,  BIC_015 , 'o');

%%

