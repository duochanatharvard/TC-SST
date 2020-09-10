% compute sensitivity of simulated hurricane counts to corrections in RSSTs
% , as well as errors associated with SST corrections.

clear;

dir  = TC_SST_IO('HadISST1b');
file = [dir,'HadISST1b_monthly_1871-2018_en_0.nc'];
lat  = ncread(file,'lat');
lon  = ncread(file,'lon');

HadISST1 = ncread([TC_SST_IO('SST'),'HadISST_sst.nc'],'sst');
HadISST1 = HadISST1([181:360,1:180],[end:-1:1],13:(2018-1869)*12);

% Compute changes in RSSTs
clear('SST_1','SST_2')
for ct_en = 1:21
    
    HadISST1b = ncread([dir,'HadISST1b_monthly_1871-2018_en_',num2str(ct_en-1),'.nc'],'sst');

    temp = reshape(HadISST1b - HadISST1,360,180,12,size(HadISST1b,3)/12);
    dif = squeeze(nanmean(temp(:,:,[6:11],:),3));

    MASK = ones(numel(lon),numel(lat));
    MASK(lon < 280 | lon > 340,:) = 0;
    MASK(:,lat < 10 | lat > 25)   = 0;
    SST_1(ct_en,:) = CDC_mask_mean(dif,lat,MASK);

    MASK = ones(numel(lon),numel(lat));
    MASK(:,lat < -30 | lat > 30)   = 0;
    SST_2(ct_en,:) = CDC_mask_mean(dif,lat,MASK);
end

S = 1.388*SST_1 - 1.521 * SST_2;

% Compute changes in hurricane counts
P.region = 'NA';
P.threshold_wind = 31.7;
[NA0,count_0,~]  = TC_SST_ANA_function_read_data(0,P);
[NA1,count_1,~]  = TC_SST_ANA_function_read_data(1,P);

sm_yr  = 15;
for ct = 1:5
    NA0_sm(ct,:) = smooth(double(NA0(ct,:)),sm_yr);
    NA1_sm(ct,:) = smooth(double(NA1(ct,:)),sm_yr);
end


% York regression
yr_list = 1885:2011;
x = S(1,yr_list-1870);
y = nanmean(NA1_sm(:,yr_list-1870) - NA0_sm(:,yr_list-1870),1)';
x_std = CDC_std(S(2:end,yr_list-1870),1)';
y_std = CDC_std(NA1_sm(:,yr_list-1870) - NA0_sm(:,yr_list-1870),1)'/sqrt(5);

N = 1000;
P.mute_output = 1;
P.N_block = 5;
[slope, inter, slope_member, inter_member] = CDC_yorkfit_bt(y,x,y_std,x_std,0,1,N,P);
 

% Generate Figure S6
figure(160); clf; hold on;
x1 = min(x)-0.3;
x2 = max(x)+0.3;

for ct = 1:numel(x)
    plot(x(ct) + [-1 1]*x_std(ct) * 0, y(ct) + [-1 1]*y_std(ct),'-','color',[1 1 1]*.7)
    plot(x(ct) + [-1 1]*x_std(ct), y(ct) + [-1 1]*y_std(ct) * 0,'-','color',[1 1 1]*.7)
end

plot([x1 x2],[x1 x2]*slope + inter,'-','color','k','linewi',3)
xx = x1:0.1:x2;
yy = repmat(xx,N,1) .* repmat(slope_member,1,numel(xx)) + repmat(inter_member,1,numel(xx));
yy = quantile(yy,[0.025 0.975],1);

plot(xx,yy,'--','color','k','linewi',2)
plot(x,y,'.','markersize',35,'color','w','linest','none');
plot(x,y,'.','markersize',20,'color','k','linest','none');
CDF_panel([-.2 .25 -2 2],'','','Relative SST index','Mean change HadISST1b - HadISST1','fontsize',19);
daspect([1.125 10 1]);
plot([3 10],[3 10],'--','color',[1 1 1]*.8,'linewi',3)
        
set(gcf,'position',[.1 10 15 9],'unit','inches')
set(gcf,'position',[.1 10 11 11]*.8,'unit','inches')


% Generate errors in hurricane counts associated with SST errors
clear('temp')
ct = 0;
for ct_sst = 2:21
    for ct_en = 1:1000
        ct = ct + 1;
        temp(ct,:) = S(ct_sst,:) * slope_member(ct_en) + inter_member(ct_en);
    end
end
temp2 = S(2:end,:) * slope + inter;
temp = temp - repmat(nanmean(temp,1),20000,1);
temp2 = temp2 - repmat(nanmean(temp2,1),20,1);

Error_from_SST = temp(:,[1871:2014]-1870);
yr = 1871:2014;

file_save = [TC_SST_IO('Results'),'Error_from_SST_R1.mat'];
save(file_save,'Error_from_SST','yr','-v7.3')
