% clear;
rng(0);

P.region    = 'NA';
P.threshold_wind = 31.7;
% ANA_version = 1; % 1: 50&25km    2: 50 km only    3: 25km only
if ~exist('ANA_version','var')
    error('Please specify the version of analysis using variable ANA_version')
end
do_splice   = 0; % Change to 1 to run sensitivity analysis in Table S1

% ************************************************************************* 
TC_SST_ANA_module_load_data;
% ************************************************************************* 

% ************************************************************************* 
% Smooth hurricane counts and assign uncertainty estimates
% ************************************************************************* 
P.do_boot = 0;        
[NA0_1,NA1_1,TC_1,TC_1_rnd,TC_1_rnd_err]       = TC_SST_ANA_function_smooth_data(1,NA0,NA1,TC,yr_obs,P);
                      
sm_yr  = 15;            
[NA0_15,NA1_15,TC_15,TC_15_rnd,TC_15_rnd_err]  = TC_SST_ANA_function_smooth_data(sm_yr,NA0,NA1,TC,yr_obs,P);

% *************************************************************************
TC_SST_ANA_module_compute_atmospheric_internal_variability;
% ************************************************************************* 

% *************************************************************************
% Fig. 1a-c - time sereis
% *************************************************************************
if ANA_version == 1 
    offset = 0;
elseif ANA_version == 2
    offset = 120;
elseif ANA_version == 3
    offset = 125;
end
figure(11+offset); clf;     hold on;
a = TC_15_rnd + internal_obs_15;  CDF_patch(yr_obs',a,[.7 .7 .7]+0.1,0.05);

a = internal_m1_15/sqrt(N_eff_0) + repmat(nanmean(NA0_15,1),N_samples,1);
h = CDF_patch(ERR.yr,a,[1 .7 .7],0.05);  set(h,'facealpha',0.2)
plot(ERR.yr,quantile(a,0.975,1),'-.','color',[.5 .5 1],'linewi',2)
plot(ERR.yr,quantile(a,0.025,1),'-.','color',[.5 .5 1],'linewi',2)

plot(yr,nanmean(NA0_15),'linewi',3,'color',[0 0 .8])
plot(yr_obs,smooth(TC,sm_yr),'linewi',3,'color',[1 1 1]*.0)
CDF_panel([1885 yr(end)-7 4 10],'','','year','','fontsize',18)
set(gca,'ytick',[5:2:9])
set(gcf,'position',[.1 14 7 3.5]*1.1,'unit','inches')
set(gcf,'position',[.1 14 12 3.5]*1.1,'unit','inches')


figure(12+offset); clf; hold on;
a = TC_15_rnd + internal_obs_15;  CDF_patch(yr_obs',a,[.7 .7 .7]+0.1,0.05);

internal = internal_m2_15/sqrt(N_eff_1) + repmat(nanmean(NA1_15,1),N_samples,1);
a = internal + ERR.Error_from_SST(I(1:N_samples),:);
h = CDF_patch(ERR.yr,a,[1 .7 .7],0.05);
set(h,'facealpha',0.2)
plot(ERR.yr,quantile(a,0.975,1),'-.','color',[.9 .4 .5],'linewi',2)
plot(ERR.yr,quantile(a,0.025,1),'-.','color',[.9 .4 .5],'linewi',2)

plot(yr,nanmean(NA1_15),'linewi',3,'color',[.7 0 0])
plot(yr_obs,smooth(TC,sm_yr),'linewi',3,'color',[1 1 1]*.0)
CDF_panel([1885 yr(end)-7 4 10],'','','year','','fontsize',18)
set(gca,'ytick',[5:2:9])
set(gcf,'position',[.1 14 7 3.5]*1.1,'unit','inches')
set(gcf,'position',[.1 14 12 3.5]*1.1,'unit','inches')


figure(13+offset); clf; hold on;

pic0 = internal_m2_15/sqrt(N_eff_0) + repmat(nanmean(NA0_15,1),N_samples,1);
pic1 = internal_m1_15/sqrt(N_eff_1) + repmat(nanmean(NA1_15,1),N_samples,1);
a    = pic1 - pic0 + ERR.Error_from_SST(I(1:N_samples),:);

h = CDF_patch(ERR.yr,a,[.5 .8 .5],0.05);   set(h,'facealpha',0.2)
plot(ERR.yr,quantile(a,0.975,1),'-.','color',[.5 .8 .5],'linewi',2)
plot(ERR.yr,quantile(a,0.025,1),'-.','color',[.5 .8 .5],'linewi',2)
 
plot(yr,nanmean(NA1_15,1) - nanmean(NA0_15,1),'linewi',3,'color',[0 .5 0])
plot([1880 2010],[0 0],'--','color',[1 1 1]*.6,'linewi',3)
CDF_panel([1885 yr(end)-7 -2 2],'','','year','','fontsize',18)
set(gca,'ytick',[-1:1:1])
set(gcf,'position',[.1 14 12 3.5]*1.1,'unit','inches')
set(gcf,'position',[.1 14 12 3.5]*1.1,'unit','inches')

% *************************************************************************
% Fig. 1d - compute consistency
% *************************************************************************
yr_list_0 = {[1885:1899],[1900:1929],[1930:1959],[1960:1994],[1995:min(2011,yr(end)-7)]};

clear('a','b','c','d','e')
interval_obs    = normrnd(0,sigma_internal,N_samples,142);
internal_m1     = normrnd(0,sigma_internal,N_samples,148);
internal_m2     = normrnd(0,sigma_internal,N_samples,148);

for ct_yr = 1:5
    yr_list = yr_list_0{ct_yr};
    a(ct_yr,:) = nanmean(TC_1_rnd(:,yr_list-1877) + interval_obs(:,yr_list-1877),2);
    b(ct_yr,:) = nanmean(nanmean(NA0_1(:,yr_list-1870),1),2) + nanmean(internal_m1(:,yr_list-1870)/sqrt(N_eff_0),2);
    c(ct_yr,:) = nanmean(nanmean(NA1_1(:,yr_list-1870),1),2) + nanmean(internal_m2(:,yr_list-1870)/sqrt(N_eff_1),2);
    e(ct_yr,:) = nanmean(ERR.Error_from_SST(:,yr_list-1869),2);
end

figure(14+offset); clf; hold on;
bar_width = 4;
for ct_grp = 1:5
    bar(1 + ct_grp*6,nanmean(a(ct_grp,:),2),'facecolor','k','edgecolor','none');  
    plot((1 + ct_grp*6) * [1 1], quantile(a(ct_grp,:),[0.025 0.975]),'color',[1 1 1]*.8,'linewi',bar_width)   
    bar(2 + ct_grp*6,nanmean(b(ct_grp,:),2),'facecolor',[0 0 .8],'edgecolor','none');
    plot((2 + ct_grp*6) * [1 1], quantile(b(ct_grp,:),[0.025 0.975]),'color',[.8 .8 1]-0.05,'linewi',bar_width)
    bar(3 + ct_grp*6,nanmean(c(ct_grp,:),2),'facecolor',[.7 0 0],'edgecolor','none');
    plot((3 + ct_grp*6) * [1 1], quantile(c(ct_grp,:) + e(ct_grp,1:2:end),[0.025 0.975]),'color',[1 .85 .85]-0.05,'linewi',bar_width)    
end
CDF_panel([5 29+6 4.5 9.5],'','','','','fontsize',18)
set(gca,'xtick',[6:6:30]+2,'xticklabel',{'1885-1899','1900-1929','1930-1959','1960-1994','1995-2011'});
set(gcf,'position',[.1 14 12 3]*1.1,'unit','inches')
set(gcf,'position',[.1 14 12 3]*1.1,'unit','inches')

disp(['period 1 -- obs:  ',num2str(nanmean(a(1,:),2),'%6.1f'),' +/- ',num2str(CDC_std(a(1,:),2)*2,'%6.1f')])
disp(['period 1 -- had:  ',num2str(nanmean(b(1,:),2),'%6.1f'),' +/- ',num2str(CDC_std(b(1,:),2)*2,'%6.1f')])
disp(['period 1 -- hadb: ',num2str(nanmean(c(1,:),2),'%6.1f'),' +/- ',num2str(CDC_std(c(1,:)+e(1,1:2:end),2)*2,'%6.1f')])
disp(' ')
disp(['period 3 -- obs:  ',num2str(nanmean(a(3,:),2),'%6.1f'),' +/- ',num2str(CDC_std(a(3,:),2)*2,'%6.1f')])
disp(['period 3 -- had:  ',num2str(nanmean(b(3,:),2),'%6.1f'),' +/- ',num2str(CDC_std(b(3,:),2)*2,'%6.1f')])
disp(['period 3 -- hadb: ',num2str(nanmean(c(3,:),2),'%6.1f'),' +/- ',num2str(CDC_std(c(3,:)+e(3,1:2:end),2)*2,'%6.1f')])
disp(' ')

% *************************************************************************
% Print figure to files
% *************************************************************************
% dir_save = TC_SST_IO('Figure_save');
% clear('a','b')
% for ct = 1:4
%     file = [dir_save,'Fig_1_time_series_ANA_version_',num2str(ANA_version),'_sub_',num2str(ct),'.png'];
%     CDF_save(10+ct,'png',300,file);
%     a{ct} = imread(file);
% end
% b = [a{1}(50:end-200,:,:);a{2}(50:end-200,:,:);a{3}(50:end-110,:,:);a{4}(50:end-0,:,:)];
% file = [dir_save,'Fig_1_time_series_ANA_version_',num2str(ANA_version),'.png'];
% imwrite(b,file);