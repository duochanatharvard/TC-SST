clear;

% observations ------------------------------------------------------------
TC       = load([TC_SST_IO('Results'),'Atlantic_TC_count.txt']);
yr_obs   = TC(:,1);
TC       = TC(:,2);

% read uncertainty in models associated with uncertin SST adjustments -----
ERR      = load([TC_SST_IO('Results'),'Error_from_SST_R1.mat']);

% Read model outputs  -----------------------------------------------------
P.region = 'NA';
P.threshold_wind = 31.7;
[NA0,count_0,~]  = TC_SST_ANA_function_read_data(0,P);
[NA1,count_1,yr] = TC_SST_ANA_function_read_data(1,P);

N_eff_0  = nnz(any(NA0~=0,2));
N_eff_1  = nnz(any(NA1~=0,2));
NA0 = NA0(1:N_eff_0,:);
NA1 = NA1(1:N_eff_1,:);

do_splice = 0;                  % TODO
if do_splice == 1               % Turn off corrections in the satellite era
    NA1(:,[1981:2018]-1870) = NA0(:,[1981:2018]-1870);
    ERR.Error_from_SST(:,[1989:2014] - ERR.yr(1) + 1) = 0;
    ERR.Error_from_SST(:,[1975:1988] - ERR.yr(1) + 1) = ERR.Error_from_SST(:,[1975:1988] - ERR.yr(1) + 1) .* repmat([14:-1:1]/15,20000,1);
end

% Smooth hurricane counts and assign uncertainty estimates ----------------
P.do_boot = 1;        
[NA0_1,NA1_1,TC_1,TC_1_rnd,TC_1_rnd_err]       = TC_SST_ANA_function_smooth_data(1,NA0,NA1,TC,yr_obs,P);
                      
sm_yr  = 15;            
[NA0_15,NA1_15,TC_15,TC_15_rnd,TC_15_rnd_err]  = TC_SST_ANA_function_smooth_data(sm_yr,NA0,NA1,TC,yr_obs,P);
                        
% ************************************************************************
% Fig. 1a-c - time sereis
% *************************************************************************
figure(11); clf;     hold on;

sigma_internal = 2.11;
N_samples      = size(NA1_15,1);
internal_obs   = normrnd(0,sigma_internal,N_samples,142);
for ct = 1:size(internal_obs,1)
    internal_obs_15(ct,:) = smooth(internal_obs(ct,:),15);
end

CDF_patch(yr_obs',TC_15_rnd + internal_obs_15,[.7 .7 .7]+0.05,0.05);
CDF_patch(yr,(NA0_15 - repmat(nanmean(NA0_15,1),N_samples,1))/sqrt(N_eff_0) + repmat(nanmean(NA0_15,1),N_samples,1),[.7 .7 1],0.05);
plot(yr,nanmean(NA0_15),'linewi',3,'color',[0 0 1])
plot(yr_obs,smooth(TC,sm_yr),'linewi',3,'color',[1 1 1]*.0)
CDF_panel([1885 2011 4 10],'','','year','','fontsize',18)
set(gca,'ytick',[5:2:9])
set(gcf,'position',[.1 14 12 3.5]*1.1,'unit','inches')
set(gcf,'position',[.1 14 12 3.5]*1.1,'unit','inches')

% -------------------------------------------------------------------------
I = randperm(20000);

internal_m1      = normrnd(0,sigma_internal,N_samples,148);
internal_m2      = normrnd(0,sigma_internal,N_samples,148);

if do_splice == 1
    internal_m2(:,[1982:2018] - 1870) = internal_m1(:,[1982:2018] - 1870);
end

clear('internal_m1_15','internal_m2_15')
for ct = 1:size(internal_m1,1)
    internal_m1_15(ct,:) = smooth(internal_m1(ct,:),15);
    internal_m2_15(ct,:) = smooth(internal_m2(ct,:),15);
end

figure(12); clf; hold on;
CDF_patch(yr_obs',TC_15_rnd+internal_obs_15,[.7 .7 .7]+0.05,0.05);            % to check back, comment this line
internal = internal_m1_15(:,1:144)/sqrt(N_eff_1) + repmat(nanmean(NA1_15(:,1:144),1),N_samples,1);
CDF_patch(ERR.yr(1:144),internal + ERR.Error_from_SST(I(1:N_samples),:),[1 .4 .5],0.05);
plot(yr,nanmean(NA1_15),'linewi',3,'color',[.7 0 0])
plot(yr_obs,smooth(TC,sm_yr),'linewi',3,'color',[1 1 1]*.0)
CDF_panel([1885 2011 4 10],'','','year','','fontsize',18)
set(gca,'ytick',[5:2:9])
set(gcf,'position',[.1 14 12 3.5]*1.1,'unit','inches')
set(gcf,'position',[.1 14 12 3.5]*1.1,'unit','inches')

% -------------------------------------------------------------------------
figure(13); clf; hold on;

pic1 = internal_m1_15(:,1:144)/sqrt(N_eff_1) + repmat(nanmean(NA1_15(:,1:144),1),N_samples,1);
pic0 = internal_m2_15(:,1:144)/sqrt(N_eff_0) + repmat(nanmean(NA0_15(:,1:144),1),N_samples,1);
    
CDF_patch(ERR.yr(1:144),pic1 - pic0 + ERR.Error_from_SST(I(1:N_samples),:),[.5 .8 .5],0.05);
plot(yr,nanmean(NA1_15 - NA0_15),'linewi',3,'color',[0 .5 0])
plot([1880 2010],[0 0],'--','color',[1 1 1]*.6,'linewi',3)
CDF_panel([1885 2011 -2 2],'','','year','','fontsize',18)
set(gca,'ytick',[-1:1:1])
set(gcf,'position',[.1 14 12 3.5]*1.1,'unit','inches')
set(gcf,'position',[.1 14 12 3.5]*1.1,'unit','inches')

% *********************************************************************
% Fig. 2d - compute consistency
% *********************************************************************
yr_list_0 = {[1885:1899],[1900:1929],[1930:1959],[1960:1994],[1995:2011]};

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

figure(14); clf; hold on;
bar_width = 4;
for ct_grp = 1:5
    bar(1 + ct_grp*6,nanmean(a(ct_grp,:),2),'facecolor','k','edgecolor','none');  
    plot((1 + ct_grp*6) * [1 1], quantile(a(ct_grp,:),[0.025 0.975]),'color',[1 1 1]*.8,'linewi',bar_width)   
    bar(2 + ct_grp*6,nanmean(b(ct_grp,:),2),'facecolor','b','edgecolor','none');
    plot((2 + ct_grp*6) * [1 1], quantile(b(ct_grp,:),[0.025 0.975]),'color',[.8 .8 1]-0.05,'linewi',bar_width)
    bar(3 + ct_grp*6,nanmean(c(ct_grp,:),2),'facecolor',[.75 0 0],'edgecolor','none');
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

% ************************************************************************
% Fig. 4 Compute the sensitivity as a function of time
% *************************************************************************
clear('Tab_slope','Tab_slope_rnd')
N_yr = 40;
for ct_yr = 1:(127-N_yr)
    
    yr_list = [1:N_yr] + 1884 + ct_yr;
    
    for ct_case = 1:2
       
        switch ct_case
            case 1
                pic = NA0_1;  
                pic_sm = NA0_15;
                ct_fig = 1;
            case 2
                pic = NA1_1;  
                pic_sm = NA1_15;
                ct_fig = 2;
        end
        
        x = TC_1(yr_list-yr_obs(1)+1);
        y = nanmean(pic(:,yr_list-yr(1)+1),1)';
        x_sm = TC_15(yr_list-yr_obs(1)+1);
        y_sm = nanmean(pic_sm(:,yr_list-yr(1)+1),1)';

        x_std = sqrt(nanmean((x - x_sm).^2) + CDC_var(TC_1_rnd_err(:,yr_list-yr_obs(1)+1),1)');
        y_std = sqrt(nanmean((y - y_sm).^2) + CDC_var(ERR.Error_from_SST(:,yr_list-ERR.yr(1)+1),1));

        N = 1000;
        P.mute_output = 1;
        P.N_block = 5;
        [slope, inter, slope_member, inter_member] = CDC_yorkfit_bt(y,x,y_std,x_std,0,1,N,P);

        Tab_slope(ct_yr,ct_case) = slope;
        Tab_slope_rnd(:,ct_yr,ct_case) = slope_member;
        
        if ct_yr == 16
            figure(41+ct_case); clf; hold on;
            
            xx = [0:0.01:20];
            clear('y_hat')
            for ct = 1:N
                y_hat(ct,:) =  slope_member(ct) .* xx + inter_member(ct);
            end
            
            if ct_case == 1
                patch([xx fliplr(xx)],[quantile(y_hat,0.025,1) fliplr(quantile(y_hat,0.975,1))],...
                    [.8 .8 1],'linest','none','facealpha',.4)
                patch([xx fliplr(xx)],[quantile(y_hat,0.25,1) fliplr(quantile(y_hat,0.75,1))],...
                    [.7 .6 1],'linest','none','facealpha',.4)
            else
                patch([xx fliplr(xx)],[quantile(y_hat,0.025,1) fliplr(quantile(y_hat,0.975,1))],...
                    [1 .75 .75],'linest','none','facealpha',.4)
                patch([xx fliplr(xx)],[quantile(y_hat,0.25,1) fliplr(quantile(y_hat,0.75,1))],...
                    [1 .45 .45],'linest','none','facealpha',.4)
            end
            
            for ct = 1:N_yr
                plot(x(ct) + [-1 1]*x_std(ct) * 1, y(ct) + [-1 1] * y_std(ct) * 0,'color',[.7 .7 .7]-.2);
                plot(x(ct) + [-1 1]*x_std(ct) * 0, y(ct) + [-1 1] * y_std(ct) * 1,'color',[.7 .7 .7]-.2);
            end
            
            if ct_case == 1
                plot(x,y,'o','markersize',10,'markerfacecolor',[.4 .5 1],'color',[0 0 .5],'linewi',2);
                plot([0 16],slope*[0 16]+inter,'linewi',3,'color',[0 0 .8])
            else
                plot(x,y,'s','markersize',10,'markerfacecolor',[.8 0 0],'color',[.5 0 0],'linewi',2);
                plot([0 16],slope*[0 16]+inter,'linewi',3,'color',[.6 0 0])
            end
            
            CDF_panel([0 15 0 15],'','','Observed hurricane counts','Simulated hurricane counts','fontsize',18)
            daspect([1 1 1])
            
            set(gcf,'position',[.1 14 12 3]*1.1,'unit','inches')
            set(gcf,'position',[.1 14 7 7],'unit','inches')
        end
    end
end

figure(41); clf; hold on
pic_yr = N_yr/2 + 1884 + [1:size(Tab_slope,1)];
CDF_patch(pic_yr,Tab_slope_rnd(:,:,1),[.8 .8 1],0.05);
CDF_patch(pic_yr,Tab_slope_rnd(:,:,2),[1 .75 .75],0.05);
CDF_patch(pic_yr,Tab_slope_rnd(:,:,1),[.7 .6 1],0.5);
CDF_patch(pic_yr,Tab_slope_rnd(:,:,2),[1 .45 .45],0.5);
plot([0 10000],[1 1],'k--')
plot(pic_yr,Tab_slope(:,1),'-','linewi',3,'color',[0 0 .8])
plot(pic_yr,Tab_slope(:,2),'-','linewi',3,'color',[.7 0 0])
CDF_panel([1885 2011 0 3],'','','','Sensitivity','fontsize',19);

set(gcf,'position',[.1 14 12 3]*1.1,'unit','inches')
set(gcf,'position',[.1 14 12 3]*1.1,'unit','inches')

disp(['alpha -- had:  ',num2str(nanmean(Tab_slope(:,1)),'%6.2f'),' +/- ',num2str(CDC_std(Tab_slope(:,1),1)*1,'%6.2f')])
disp(['alpha -- hadb: ',num2str(nanmean(Tab_slope(:,2)),'%6.2f'),' +/- ',num2str(CDC_std(Tab_slope(:,2),1)*1,'%6.2f')])
disp(' ')
disp(['alpha in 1920 -- had:  ',num2str(nanmean(Tab_slope(16,1)),'%6.2f')])
disp(['alpha in 1920 -- hadb: ',num2str(nanmean(Tab_slope(16,2)),'%6.2f')])