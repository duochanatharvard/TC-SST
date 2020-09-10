clear;

% observations ------------------------------------------------------------
TC       = load([TC_SST_IO('Results'),'Atlantic_TC_count.txt']);
yr_obs   = TC(:,1);
TC       = TC(:,2);

% read uncertainty in models associated with uncertin SST adjustments -----
ERR = load([TC_SST_IO('Results'),'Error_from_SST_R1.mat']);

% Read model outputs  -----------------------------------------------------
P.region = 'NA';
P.threshold_wind = 31.7;
[NA0,count_0,~]  = TC_SST_ANA_function_read_data(0,P);
[NA1,count_1,yr] = TC_SST_ANA_function_read_data(1,P);

% Smooth hurricane counts and assign uncertainty estimates ----------------
P.do_boot = 0;
[NA0_1, NA1_1, TC_1, ~,~]              = TC_SST_ANA_function_smooth_data(1,NA0,NA1,TC,yr_obs,P);
[NA0_15,NA1_15,TC_15,~,TC_15_rnd_err]  = TC_SST_ANA_function_smooth_data(15,NA0,NA1,TC,yr_obs,P);

% P2.do_boot = 1;
% P2.N_samples = 10000;           
% [NA02_15,NA12_15,~,TC_15_rnd,~] = TC_SST_ANA_function_smooth_data(15,NA0,NA1,TC,yr_obs,P2);
                    
% ************************************************************************    
% Fig.~S2
% ************************************************************************
a = [NA1_1 - repmat(nanmean(NA1_1,1),5,1);   NA0_1 - repmat(nanmean(NA0_1,1),5,1)];
Noise_Obs = sqrt(nanmean([CDC_var(a(1:5,[1885:2011]-1870),1)  CDC_var(a(6:10,[1885:2011]-1870),1)]));
r2 = nanmean(CDC_corr(a(:,1:end-1),a(:,2:end),2).^2);
disp(['auto-correlation r^2: ',num2str(r2,'%6.3f'),''])
disp(['Internal atmospheric variability: ',num2str(Noise_Obs,'%6.2f'),' (1 s.d.)'])

% Check for normality
figure(150); clf; hold on; 
Q0 = norminv(0.01:0.01:0.99,0,CDC_std(a(:)));
for ct = 1:1000
    temp = sort(normrnd(0,CDC_std(a(:)),1,numel(a)));
    Q(ct,:) = quantile(temp,[0.01:0.01:0.99]);
    plot(Q0,Q(ct,:),'color',[1 1 1]*.7,'linewi',2)
end
Qobs = quantile(a(:),[0.01:0.01:0.99]);
plot(Q0,Qobs','k','linewi',3)
CDF_panel([-10 10 -10 10]/2,'','','Normal Theoretical Quantiles','Normal Data Quantiles')
daspect([1 1 1])
set(gca,'xtick',[-4:2:4],'ytick',[-4:2:4])
set(gcf,'position',[.1 13 5 8],'unit','inches')
set(gcf,'position',[-2 13 6 6],'unit','inches')

% ************************************************************************
% Fig.~S3
% ************************************************************************
yr_list = [1885:2011];

Internal_std   = Noise_Obs;
T_true         = nanmean(NA1_15(:,yr_list-yr(1)+1),1);
sm_yr          = 15;

clear('RMSE0','RMSE1')
for ct = 1:10000
    
    temp       = smooth(normrnd(0,Internal_std,1,numel(yr_list)+14),sm_yr)';
    TC_obs0    = T_true + temp(:,8:end-7);
    TC_obs1    = T_true + TC_15_rnd_err(round(unifrnd(1,9999,1,1)),yr_list-yr_obs(1)+1) + temp(:,8:end-7);

    temp       = smooth(normrnd(0,Internal_std,1,numel(yr_list)+14),sm_yr)';
    TC_model0  = T_true + temp(:,8:end-7)/sqrt(5);
    TC_model1  = T_true + temp(:,8:end-7)/sqrt(5) + ERR.Error_from_SST(round(unifrnd(1,19999,1,1)),yr_list-ERR.yr(1)+1);

    RMSE0(ct) = sqrt(nanmean((TC_obs0 - TC_model0).^2));
    RMSE1(ct) = sqrt(nanmean((TC_obs1 - TC_model1).^2));

    RS0(ct) = CDC_corr(TC_obs0,TC_model0);
    RS1(ct) = CDC_corr(TC_obs1,TC_model1);
end
    
figure(130); clf; hold on;
CDF_histogram(0:0.02:2,RMSE1,[.5 .5 .5],0,0,0.05)
a = sqrt(nanmean((TC_15(yr_list - yr_obs(1) + 1)' - nanmean(NA0_15(:,yr_list - yr(1) + 1),1)).^2));
b = sqrt(nanmean((TC_15(yr_list - yr_obs(1) + 1)' - nanmean(NA1_15(:,yr_list - yr(1) + 1),1)).^2));
plot([1 1]*a,[0 4],'color',[0 0 1]*.8,'linewi',3)
plot([1 1]*b,[0 4],'color',[1 0 0]*.8,'linewi',3)
CDF_panel([0.3 1.5 0 3.5],'','','RMSE','pdf','fontsize',18)
set(gcf,'position',[.1 13 5 8]*1.2,'unit','inches')
set(gcf,'position',[.1 13 6 5]*1.2,'unit','inches')

