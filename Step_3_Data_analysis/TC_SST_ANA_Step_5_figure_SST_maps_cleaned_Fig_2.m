clear;

HadISST1  = ncread([TC_SST_IO('SST'),'HadISST_sst.nc'],'sst');
HadISST1  = HadISST1([181:360,1:180],[end:-1:1],13:(2018-1869)*12);
HadISST1b = ncread([TC_SST_IO('HadISST1b'),'HadISST1b_monthly_1871-2018_en_0.nc'],'sst');
lon       = ncread([TC_SST_IO('HadISST1b'),'HadISST1b_monthly_1871-2018_en_0.nc'],'lon');
lat       = ncread([TC_SST_IO('HadISST1b'),'HadISST1b_monthly_1871-2018_en_0.nc'],'lat');

HadISST1(HadISST1<-100) = nan;
HadISST1b(HadISST1b<-100) = nan;

HadISST1 = reshape(HadISST1,360,180,12,148);
HadISST1b = reshape(HadISST1b,360,180,12,148);

st_full_subcoast = {'region',[-180 180 -60 80],...
    'fontsize',24,'barloc','eastoutside',...
    'xtick',[-90 0 90],'ytick',[-30:30:60],'bckgrd',[1 1 1]*.9,...
    'subcoast',1,'docoast',1,'coastwi',1,'daspect',[1 0.6 1]};

l = [1885:1920]-1869;

figure(21); clf;
pic = nanmean(nanmean(HadISST1(:,:,:,l),3),4);
CDF_plot_map('pcolor',pic,[st_full_subcoast,'crange',0.4,'cmap',b2rCD(16),'bartit','SST [^\circ C]','plabel',' ']);
caxis([-2 30])

figure(23); clf;
pic = nanmean(nanmean(HadISST1b(:,:,:,l) - HadISST1(:,:,:,l),3),4);
CDF_plot_map('pcolor',pic,[st_full_subcoast,'crange',0.2,'cmap',b2rCD(10),'bartit','Groupwise SST corrections [^\circ C]','plabel',' ']);