% clear;
rng(0);

P.region    = 'NA';
P.threshold_wind = 31.7;
% ANA_version = 1; % 1: 50&25km    2: 50 km only    3: 25km only
if ~exist('ANA_version','var')
    error('Please specify the version of analysis using variable ANA_version')
end
do_splice   = 0;                  % Change to 1 to run sensitivity analysis in Table S1

% ************************************************************************* 
TC_SST_ANA_module_load_data;
% ************************************************************************* 
                   
st_full_subcoast = {'region',[-180 180 -60 80],...
    'fontsize',20,'barloc','eastoutside',...
    'xtick',[-90 0 90],'ytick',[-30:30:60],'bckgrd',[1 1 1]*.9,...
    'subcoast',1,'docoast',1,'coastwi',1,'daspect',[1 0.6 1]};

% *********************************************************************
% Fig. 1 maps of cyclones
% *********************************************************************
if ANA_version == 1 
    offset = 0;
elseif ANA_version == 2
    offset = 130;
elseif ANA_version == 3
    offset = 135;
end

figure(31+offset); clf;
l = [1885:1920]-1870;
pic = nanmean(nanmean(count_0(:,:,1:end,l),3),4);
pic = CDC_smooth2(pic);
x_scale = [0 0.1 0.2 0.5 1 2 5 10 20]/10;
pic = discretize(pic,x_scale) - 0.1;
CDF_plot_map('pcolor',pic,...
    [st_full_subcoast,'crange',1,'cmap',hotCD(8),...
    'bartit','Hurricane density per 1^o box [per year] ','plabel',' ',...
    'bartick',[0:1:7],'bartickl',x_scale(1:1:end)]);
caxis([0 8])


figure(32+offset); clf;
l = [1885:1920]-1870;
clear('temp0','temp1')
ct = 0;
for ct1 = 1:size(count_0,3)
    for ct2 = l
        ct = ct + 1;
        temp0(:,:,ct) = CDC_smooth2(count_0(:,:,ct1,ct2));
    end
end
ct = 0;
for ct1 = 1:size(count_1,3)
    for ct2 = l
        ct = ct + 1;
        temp1(:,:,ct) = CDC_smooth2(count_1(:,:,ct1,ct2));
    end
end

pic = nanmean(temp1,3) - nanmean(temp0,3);
std_est = sqrt(CDC_var(temp0,3) ./ size(temp0,3) + CDC_var(temp1,3) ./ size(temp1,3));
sig2 = (abs(pic) ./ std_est) > tinv(0.95,size(temp0,3) + size(temp1,3) - 2);

x_scale = [-2.5 -1 -.5 -.3 -.2 -.1 -.05 -.01 0 .01 .05 .1 .2 .3 .5  1 2.5]/5;
pic = discretize(pic,x_scale) - 0.1;
CDF_plot_map('pcolor',pic,...
    [st_full_subcoast,'crange',14,'cmap',b2rCD(8),...
    'bartit','Changes in hurricane density','plabel',' ',...
    'bartick',[0:2:16],'bartickl',x_scale(1:2:end),'sig',sig2,'sigtype','marker']);
caxis([0 16])


figure(33+offset); clf;
l = [1930:1949]-1870;
clear('temp0','temp1')
ct = 0;
for ct1 = 1:size(count_0,3)
    for ct2 = l
        ct = ct + 1;
        temp0(:,:,ct) = CDC_smooth2(count_0(:,:,ct1,ct2));
    end
end
ct = 0;
for ct1 = 1:size(count_1,3)
    for ct2 = l
        ct = ct + 1;
        temp1(:,:,ct) = CDC_smooth2(count_1(:,:,ct1,ct2));
    end
end

pic = nanmean(temp1,3) - nanmean(temp0,3);
std_est = sqrt(CDC_var(temp0,3) ./ size(temp0,3) + CDC_var(temp1,3) ./ size(temp1,3));
sig2 = (abs(pic) ./ std_est) > tinv(0.95,size(temp0,3) + size(temp1,3) - 2);

x_scale = [-2.5 -1 -.5 -.3 -.2 -.1 -.05 -.01 0 .01 .05 .1 .2 .3 .5  1 2.5]/5;
pic = discretize(pic,x_scale) - 0.1;
CDF_plot_map('pcolor',pic,...
    [st_full_subcoast,'crange',14,'cmap',b2rCD(8),...
    'bartit','Changes in hurricane density','plabel',' ',...
    'bartick',[0:2:16],'bartickl',x_scale(1:2:end),'sig',sig2,'sigtype','marker']);
caxis([0 16])

% *************************************************************************
% Print figure to files
% *************************************************************************
% dir_save = TC_SST_IO('Figure_save');
% clear('a','b')
% for ct = 1:3
%     file = [dir_save,'Fig_3_density_map_ANA_version_',num2str(ANA_version),'_sub_',num2str(ct),'.png'];
%     CDF_save(30+ct,'png',300,file);
%     a{ct} = imread(file);
% end
% xx = 360;
% b = [a{1}(250:end-350,1:end-xx,:);a{2}(250:end-350,1:end-xx,:);a{3}(250:end-110,1:end-xx,:)];
% file = [dir_save,'Fig_3_density_map_ANA_version_',num2str(ANA_version),'.png'];
% imwrite(b,file);