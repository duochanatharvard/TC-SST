% compute sensitivity of simulated hurricane counts to RSSTs
% as well as errors associated with SST corrections.

clear;

% ************************************************************************* 
% Compute RSST
% ************************************************************************* 
dir  = TC_SST_IO('HadISST1b');
file = [dir,'HadISST1b_monthly_1871-2018_en_0.nc'];
lat  = ncread(file,'lat');
lon  = ncread(file,'lon');

HadISST1 = ncread([TC_SST_IO('SST'),'HadISST_sst.nc'],'sst');
HadISST1 = HadISST1([181:360,1:180],[end:-1:1],13:(2018-1869)*12);
temp = reshape(HadISST1,360,180,12,size(HadISST1,3)/12);
RSST(1,:) = TC_SST_ANA_function_compute_RSST(temp,lon,lat,[1871:2018]);
 
HadISST1b = ncread([dir,'HadISST1b_monthly_1871-2018_en_0.nc'],'sst');
temp = reshape(HadISST1b,360,180,12,size(HadISST1b,3)/12);
RSST(2,:) = TC_SST_ANA_function_compute_RSST(temp,lon,lat,[1871:2018]);

RSST = RSST + 1.707;

% ************************************************************************* 
% Cyclone counts
% ************************************************************************* 
P.region    = 'NA';
P.threshold_wind = 31.7;
ANA_version = 1; % 1: 50&25km    2: 50 km only    3: 25km only
do_splice   = 0; % Change to 1 to run sensitivity analysis in Table S1

% ************************************************************************* 
TC_SST_ANA_module_load_data;
% ************************************************************************* 
N(1,:) = nanmean(NA0,1);
N(2,:) = nanmean(NA1,1);

for ct = 1:2
    RSST_sm(ct,:) = smooth(RSST(ct,:),15);
    N_sm(ct,:)    = smooth(N(ct,:),15);
end

RSST_sm = RSST_sm(:,[1878:2011]-1870);
N_sm = N_sm(:,[1878:2011]-1870);

% ************************************************************************* 
% OLR
% ************************************************************************* 
X = [RSST_sm(:) ones(numel(RSST_sm),1)];
Y = N_sm(:);
b = inv(X'*X) * X' * Y;
sigma = nanmean((Y - X * b).^2);
b_error = sigma * inv(X' * X); 
b_rnd = mvnrnd(b,b_error,1000);

slope = b(1);
inter = b(2);
slope_member = b_rnd(:,1);
inter_member = b_rnd(:,2);

% ************************************************************************* 
% Generate Figure S1
% ************************************************************************* 
figure(141); clf; hold on;
x1 = min(RSST_sm(:))-0.3;
x2 = max(RSST_sm(:))+0.3;

plot(RSST_sm(1,:),N_sm(1,:),'kv','color',[0 0 .8],'linewi',2,'markerfacecolor',[.6 .6 1],'markersize',15)
plot(RSST_sm(2,:),N_sm(2,:),'ko','color',[.7 0 0],'linewi',2,'markerfacecolor',[1 .6 .6],'markersize',15)

plot([x1 x2],[x1 x2]*slope + inter,'-','color','k','linewi',3)
xx = x1:0.1:x2;
yy = repmat(xx,1000,1) .* repmat(slope_member,1,numel(xx)) + repmat(inter_member,1,numel(xx));
yy = quantile(yy,[0.025 0.975],1);

plot(xx,yy,'--','color','k','linewi',2)
CDF_panel([x1 x2 3 10],'','','15-year smoothed relative SST index','15-yr smoothed simulated Atlantic hurricane counts','fontsize',19);
daspect([x2-x1 7 1]);
plot([3 10],[3 10],'--','color',[1 1 1]*.8,'linewi',3)
        
set(gcf,'position',[.1 10 15 9],'unit','inches')
set(gcf,'position',[.1 10 11 11]*.8,'unit','inches')

% ************************************************************************* 
% Compute uncertainties in changes in RSSTs
% ************************************************************************* 
clear('SST_1','SST_2')
for ct_en = 1:20
    
    HadISST1b = ncread([dir,'HadISST1b_monthly_1871-2018_en_',num2str(ct_en),'.nc'],'sst');

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

S_chg = 1.388 * SST_1 - 1.521 * SST_2;

% ************************************************************************* 
% Generate errors in hurricane counts associated with SST errors
% ************************************************************************* 
clear('temp')
ct = 0;
for ct_sst = 1:20
    for ct_en = 1:1000
        ct = ct + 1;
        temp(ct,:) = S_chg(ct_sst,:) * slope_member(ct_en);
    end
end
temp = temp - repmat(nanmean(temp,1),20000,1);

Error_from_SST = temp(:,[1871:2018]-1870);
yr = 1871:2018;

% *************************************************************************
disp('Saving data...')
% *************************************************************************
file_save = [TC_SST_IO('Results'),'Error_from_SST.nc'];
delete(file_save)

nccreate(file_save,'year','Dimensions', {'year',numel(yr)},...
    'Datatype','single','FillValue','disable','Format','netcdf4');  
ncwrite(file_save,'year',yr);

nccreate(file_save,'Error_from_SST','Dimensions', {'en',size(Error_from_SST,1),'year',numel(yr)},...
    'Datatype','single','FillValue','disable','Format','netcdf4');  
ncwrite(file_save,'Error_from_SST',Error_from_SST);
disp('Run completes!')

% file_save = [TC_SST_IO('Results'),'Error_from_SST_20210325.mat'];
% save(file_save,'Error_from_SST','yr','-v7.3')

% Print figure to files
% dir_save = TC_SST_IO('Figure_save');
% CDF_save(160,'png',300,[dir_save,'Fig_S1_TC_RSST.png']);
