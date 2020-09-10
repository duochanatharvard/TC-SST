clear;

P.region = 'NA';
P.threshold_wind = 31.7;
[NA0,count_0,~]                = TC_SST_ANA_function_read_data(0,P);
[NA1,count_1,yr]               = TC_SST_ANA_function_read_data(1,P);
[TC_ctl_1990,count_ctl_1990,~] = TC_SST_ANA_function_read_data(2,P);
[TC_exp_1990,count_exp_1990,~] = TC_SST_ANA_function_read_data(3,P);
                   
st_full_subcoast = {'region',[-180 180 -60 80],...
    'fontsize',24,'barloc','eastoutside',...
    'xtick',[-90 0 90],'ytick',[-30:30:60],'bckgrd',[1 1 1]*.9,...
    'subcoast',1,'docoast',1,'coastwi',1,'daspect',[1 0.6 1]};

% *********************************************************************
% Fig. 1 maps of cyclones
% *********************************************************************
dens0 = count_0([181:end 1:180],:,:,:);
dens1 = count_1([181:end 1:180],:,:,:);

figure(22); clf;
l = [1885:1920]-1870;
pic = nanmean(nanmean(dens0(:,:,:,l),3),4);
pic = CDC_smooth2(pic);
x_scale = [0 0.1 0.2 0.5 1 2 5 10]/10;
pic = discretize(pic,x_scale) - 0.1;
CDF_plot_map('pcolor',pic,...
    [st_full_subcoast,'crange',1,'cmap',hotCD(7),...
    'bartit','Hurricane density per 1^o box [per year] ','plabel',' ',...
    'bartick',[0:1:7],'bartickl',x_scale(1:1:end)]);
caxis([0 7])
set(gcf,'position',[.1 10 15 9],'unit','inches')
set(gcf,'position',[.1 10 11 6],'unit','inches')

figure(24); clf;
l = [1885:1920]-1870;
pic = nanmean(nanmean(dens1(:,:,:,l) - dens0(:,:,:,l),3),4);
pic = CDC_smooth2(pic);
temp = squeeze(nanmean(dens1(:,:,:,l) - dens0(:,:,:,l),3));
for ct = 1:size(temp,3)
    temp(:,:,ct) = CDC_smooth2(temp(:,:,ct));
end
sig = (abs(pic) ./ CDC_std(temp,3) .* sqrt(size(temp,3) - 1)) > tinv(0.95,size(temp,3) - 1);
sig(:,:,2) = 0;
x_scale = [-2.5 -1 -.5 -.3 -.2 -.1 -.05 -.01 0 .01 .05 .1 .2 .3 .5  1 2.5]/5;
pic = discretize(pic,x_scale) - 0.1;
CDF_plot_map('pcolor',pic,...
    [st_full_subcoast,'crange',14,'cmap',b2rCD(8),...
    'bartit','Changes in hurricane density','plabel',' ',...
    'bartick',[0:2:16],'bartickl',x_scale(1:2:end),'sig',sig,'sigtype','marker']);
caxis([0 16])
set(gcf,'position',[.1 10 15 9],'unit','inches')
set(gcf,'position',[.1 10 11 6],'unit','inches')

% ************************************************************************
% Fig. S2 RCP simulations
% *************************************************************************
figure(51); clf;
pic = nanmean(count_exp_1990([181:end 1:180],:,:) - count_ctl_1990([181:end 1:180],:,:),3);
pic = CDC_smooth2(pic);
temp = count_exp_1990([181:end 1:180],:,:) - count_ctl_1990([181:end 1:180],:,:);
for ct = 1:size(temp,3)
    temp(:,:,ct) = CDC_smooth2(temp(:,:,ct));
end
sig = (abs(pic) ./ CDC_std(temp,3) .* sqrt(size(temp,3) - 1)) > tinv(0.95,size(temp,3) - 1);
sig(:,:,2) = 0;
x_scale = [-2.5 -1 -.5 -.3 -.2 -.1 -.05 -.01 0 .01 .05 .1 .2 .3 .5  1 2.5]/5;
pic = discretize(pic,x_scale) - 0.1;
CDF_plot_map('pcolor',pic,...
    [st_full_subcoast,'crange',14,'cmap',b2rCD(8),...
    'bartit','Changes in hurricane density','plabel',' ',...
    'bartick',[0:2:16],'bartickl',x_scale(1:2:end),'sig',sig,'sigtype','marker']);
caxis([0 16])
set(gcf,'position',[.1 10 15 9],'unit','inches')
set(gcf,'position',[.1 10 11 6],'unit','inches')