clear;
rng(0);

P.region    = 'NA';
P.threshold_wind = 31.7;
ANA_version = 1; % 1: 50&25km    2: 50 km only    3: 25km only
do_splice   = 0; % Change to 1 to run sensitivity analysis in Table S1

% ************************************************************************* 
TC_SST_ANA_module_load_data;
% ************************************************************************* 

a = nanmean([NA0; NA1],1);
aa = a' - smooth(a,15);
bb = TC - smooth(TC,15);
yr_list = [1980:min(2011,yr(end)-7)];
aaa = aa(yr_list-yr(1)+1);
bbb = bb(yr_list-yr_obs(1)+1);

figure(111);
subplot(1,2,1); cla; hold on; 
h(2) = plot(yr_list,aaa,'linewi',4,'color',[1 1 1]*.6);
h(1) = plot(yr_list,bbb,'linewi',2,'color','k');
CDF_panel([1980 2012 -8 8],'','','Year','Interannual hurricane count','fontsize',18,'fontweight','normal')
legend(h,{'Obs','Simulated'},'location','southeast','fontsize',18,'fontweight','normal')
daspect([2012-1980 16 1])

subplot(1,2,2); cla; hold on; 
plot(aaa,bbb,'ko','markerfacecolor',[1 1 1]*.6,'markersize',12,'linewi',2);
plot([-8 8],[-8 8],'k--'); daspect([1 1 1]); set(gca,'xtick',[-5:2:7],'ytick',[-5:2:7])
CDF_panel([-6 8 -6 8],'','','Interannual count (simulated)','Interannual count (obs)','fontsize',18,'fontweight','normal')
CDF_size(-10,15,12,7);

% dir_save = TC_SST_IO('Figure_save');
% file_pic = [dir_save,'Fig_1_interannual_variability_ANA_version_',num2str(ANA_version),'.png'];
% CDF_save(1,'png',300,file_pic);