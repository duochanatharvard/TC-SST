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

DS0 = squeeze(nanmean(count_0,3));
DS1 = squeeze(nanmean(count_1,3));

for ct = 1:148
    DS0(:,:,ct) = CDC_smooth2(DS0(:,:,ct));
    DS1(:,:,ct) = CDC_smooth2(DS1(:,:,ct));
end

yr = [1885:2012] - 1870;
[trd0,trd0_sig,~] = CDC_trend(DS0(:,:,yr),1:numel(yr),3);
[trd1,trd1_sig,~] = CDC_trend(DS1(:,:,yr),1:numel(yr),3);


st_full_subcoast = {'region',[-180 180 -50 80],...
    'fontsize',20,'barloc','southoutside',...
    'xtick',[-90 0 90],'ytick',[-30:30:60],'bckgrd',[1 1 1]*.9,...
    'subcoast',1,'docoast',1,'coastwi',1,'daspect',[1 0.6 1]};

dens0 = trd0{1}(:,:) * numel(yr);
dens1 = trd1{1}(:,:) * numel(yr);
dens0_sig = (trd0_sig{1}.lower > 0 & trd0{1} > 0) | (trd0_sig{1}.upper < 0 & trd0{1} < 0);
dens1_sig = (trd1_sig{1}.lower > 0 & trd1{1} > 0) | (trd1_sig{1}.upper < 0 & trd1{1} < 0);

% ************************************************************************* 
% Generate figures
% ************************************************************************* 
if ANA_version == 1 
    offset = 0;
elseif ANA_version == 2
    offset = 3;
elseif ANA_version == 3
    offset = 6;
end

figure(121+offset); clf;
pic = dens0;
clear('sig')
sig(:,:,1) = dens0_sig(:,:);  
sig(:,:,2) = 0;
x_scale = [-2.5 -1 -.5 -.3 -.2 -.1 -.05 -.01 0 .01 .05 .1 .2 .3 .5  1 2.5]/5;
pic = discretize(pic,x_scale) - 0.1;
CDF_plot_map('pcolor',pic,...
    [st_full_subcoast,'crange',14,'cmap',b2rCD(8),...
    'bartit','Hurricane density trend per 1^o box [per year]','plabel',' ',...
    'bartick',[0:2:16],'bartickl',x_scale(1:2:end),'sig',sig,'sigtype','marker']);
caxis([0 16])

figure(122+offset); clf;
pic = dens1;
clear('sig')
sig(:,:,1) = dens1_sig(:,:);  
sig(:,:,2) = 0;
x_scale = [-2.5 -1 -.5 -.3 -.2 -.1 -.05 -.01 0 .01 .05 .1 .2 .3 .5  1 2.5]/5;
pic = discretize(pic,x_scale) - 0.1;
CDF_plot_map('pcolor',pic,...
    [st_full_subcoast,'crange',14,'cmap',b2rCD(8),...
    'bartit','Hurricane density trend per 1^o box [per year]','plabel',' ',...
    'bartick',[0:2:16],'bartickl',x_scale(1:2:end),'sig',sig,'sigtype','marker']);
caxis([0 16])

% Print figure to files
% dir_save = TC_SST_IO('Figure_save');
% CDF_save(31,'png',300,[dir_save,'Fig_S3_trend_ANA_version_',num2str(ANA_version),'_HadISST1.png']);
% CDF_save(32,'png',300,[dir_save,'Fig_S3_trend_ANA_version_',num2str(ANA_version),'_HadISST1b.png']);