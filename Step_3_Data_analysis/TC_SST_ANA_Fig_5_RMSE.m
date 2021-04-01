clear;
rng(0);

P.region    = 'NA';
P.threshold_wind = 31.7;
ANA_version = 1; % 1: 50&25km    2: 50 km only    3: 25km only
do_splice   = 0;                  % Change to 1 to run sensitivity analysis in Table S1

% ************************************************************************* 
TC_SST_ANA_module_load_data;
% ************************************************************************* 
% Smooth hurricane counts and assign uncertainty estimates ----------------
P.do_boot = 0;
[NA0_1, NA1_1, TC_1, ~,~]              = TC_SST_ANA_function_smooth_data(1,NA0,NA1,TC,yr_obs,P);
[NA0_15,NA1_15,TC_15,~,TC_15_rnd_err]  = TC_SST_ANA_function_smooth_data(15,NA0,NA1,TC,yr_obs,P);


a = [NA1_1 - repmat(nanmean(NA1_1,1),size(NA1_1,1),1);   NA0_1 - repmat(nanmean(NA0_1,1),size(NA0_1,1),1)];
% Noise_Obs = sqrt(nanmean([CDC_var(a(1:5,[1885:2011]-1870),1)  CDC_var(a(6:10,[1885:2011]-1870),1)]));
r2 = nanmean(CDC_corr(a(:,1:end-1),a(:,2:end),2).^2);
disp(['auto-correlation r^2: ',num2str(r2,'%6.3f'),''])
% disp(['Internal atmospheric variability: ',num2str(Noise_Obs,'%6.2f'),' (1 s.d.)'])

% *************************************************************************
% Fig. 5
% *************************************************************************
yr_list = [1885:2011];

Internal_std   = sigma_internal;
sm_yr          = 15;

rng(0);
clear('RMSE0','RMSE1')
for ct = 1:10000
    
    temp1      = smooth(normrnd(0,Internal_std,1,numel(yr_list)+14),sm_yr)';
    TC_obs     = TC_15_rnd_err(round(unifrnd(1,9999,1,1)),yr_list-yr_obs(1)+1) + temp1(:,8:end-7);

    temp2      = smooth(normrnd(0,Internal_std/sqrt(size(NA0_1,1)),1,numel(yr_list)+14),sm_yr)';
    TC_model0  = temp2(:,8:end-7);
    TC_model1  = temp2(:,8:end-7) + ERR.Error_from_SST(round(unifrnd(1,19999,1,1)),yr_list-ERR.yr(1)+1);

    RMSE0(ct) = sqrt(nanmean((TC_obs - TC_model0).^2));
    RMSE1(ct) = sqrt(nanmean((TC_obs - TC_model1).^2));
end
    
% *************************************************************************
% Generate Figures
% *************************************************************************
figure(51); clf; hold on;
CDF_histogram(0:0.01:2,RMSE0,[.5 .5 .6],0,0,0.05)
a = sqrt(nanmean((TC_15(yr_list - yr_obs(1) + 1)' - nanmean(NA0_15(:,yr_list - yr(1) + 1),1)).^2));
disp(['p-value: ',num2str(1.01-find(a > quantile((RMSE0),[0:0.01:1]),1,'last')/100,'%6.2f')])
plot([1 1]*a,[0 4],'color',[0 0 1]*.8,'linewi',4)
CDF_panel([0.3 1.3 0 3.5],'','','RMSE','pdf','fontsize',18)
set(gcf,'position',[.1 13 5 8],'unit','inches')
set(gcf,'position',[.1 20 10 4],'unit','inches')

figure(52); clf; hold on;
CDF_histogram(0:0.01:2,RMSE1,[.65 .5 .5],0,0,0.05)
b = sqrt(nanmean((TC_15(yr_list - yr_obs(1) + 1)' - nanmean(NA1_15(:,yr_list - yr(1) + 1),1)).^2));
disp(['p-value: ',num2str(1.01-find(b > quantile((RMSE1),[0:0.01:1]),1,'last')/100,'%6.2f')])
plot([1 1]*b,[0 4],'color',[1 0 0]*.7,'linewi',4)
CDF_panel([0.3 1.3 0 3.5],'','','RMSE','pdf','fontsize',18)
set(gcf,'position',[.1 13 5 8]*1.2,'unit','inches')
set(gcf,'position',[.1 15 10 4],'unit','inches')

disp(['95% c.i. raw:', num2str(quantile(RMSE0,[0.025 0.975]),'%6.2f')])
disp(['95% c.i. adj:', num2str(quantile(RMSE1,[0.025 0.975]),'%6.2f')])

% *************************************************************************
% Print figure to files
% *************************************************************************
% dir_save = TC_SST_IO('Figure_save');
% clear('a','b')
% for ct = 1:2
%     file = [dir_save,'Fig_4_discrepancy_ANA_version_',num2str(ANA_version),'_sub_',num2str(ct),'.png'];
%     CDF_save(40+ct,'png',300,file);
%     a{ct} = imread(file);
% end
% b = [a{1}(50:end-100,:,:);a{2}(50:end-100,:,:)];
% file = [dir_save,'Fig_4_discrepancy_ANA_version_',num2str(ANA_version),'.png'];
% imwrite(b,file);