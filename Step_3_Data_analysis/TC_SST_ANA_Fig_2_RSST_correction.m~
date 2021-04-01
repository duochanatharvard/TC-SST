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
    'fontsize',20,'barloc','eastoutside',...
    'xtick',[-90 0 90],'ytick',[-30:30:60],'bckgrd',[1 1 1]*.9,...
    'subcoast',1,'docoast',1,'coastwi',1,'daspect',[1 0.6 1]};

figure(21); clf;
l = [1885:1920]-1869;
pic = nanmean(nanmean(HadISST1b(:,:,:,l) - HadISST1(:,:,:,l),3),4);
CDF_plot_map('pcolor',pic,[st_full_subcoast,'crange',0.2,'cmap',b2rCD(10),'bartit','Groupwise SST corrections [^\circ C]','plabel',' ']);

figure(22); clf;
l = [1930:1949]-1869;
pic = nanmean(nanmean(HadISST1b(:,:,:,l) - HadISST1(:,:,:,l),3),4);
CDF_plot_map('pcolor',pic,[st_full_subcoast,'crange',0.2,'cmap',b2rCD(10),'bartit','Groupwise SST corrections [^\circ C]','plabel',' ']);

% *************************************************************************
dir_load = TC_SST_IO('Results');
load([dir_load,'SUM_corr_cyclone_idv_HM_SST_Bucket_deck_level_1_do_rmdup_0_correct_kobe_0_connect_kobe_1_yr_start_1850_scaled.mat']);
load([dir_load,'Stats_HM_SST_Bucket_deck_level_1.mat'],'unique_grp')
unique_grp(ismember(unique_grp,[74 80 762; 74 80 119],'rows'),:) = [];

mon_list = [6:11];

corr_all_mdr  = squeeze(nanmean(TS0_mdr(mon_list,:,2) - TS0_mdr(mon_list,:,1),1));
corr_all_trop = squeeze(nanmean(TS0_trop(mon_list,:,2) - TS0_trop(mon_list,:,1),1));
corr_ind_mdr  = squeeze(nanmean(TS_mdr(mon_list,:,:) - repmat(TS0_mdr(mon_list,:,1),1,1,162),1));
corr_ind_trop = squeeze(nanmean(TS_trop(mon_list,:,:) - repmat(TS0_trop(mon_list,:,1),1,1,162),1));

scl1 = 1.388; scl2 = 1.521;

index_all = scl1*corr_all_mdr  - scl2*corr_all_trop;
index_ind = scl1*corr_ind_mdr  - scl2*corr_ind_trop;

% Combine corrections into nations
[unique_nation,~,J] = unique(unique_grp(:,1:2),'rows');

for ct = 1:max(J)
    index_ind_nation(:,ct) = nansum(index_ind(:,J == ct),2);
end

l_use = max(abs(index_ind_nation([1880:2010]-1849,:)),[],1) > 0.02;
index_ind_sub = index_ind_nation(:,l_use);
grp_sub       = unique_nation(l_use,:);
col           = distinguishable_colors(nnz(l_use));

pic_t = 1850:2014;

figure(23); clf; hold on;

pic = index_ind_sub';
pic_all = index_all;

pic_other = index_ind_nation(:,~l_use)';
grp_other = unique_nation(~l,:);
col_other = [.8 .4 .4; .4 .4 .8]*0;

pic_other_pos = pic_other;
pic_other_pos(pic_other_pos<0) = 0;
pic_other_pos = nansum(pic_other_pos,1);
pic_other_nag = pic_other;
pic_other_nag(pic_other_nag>0) = 0;
pic_other_nag = nansum(pic_other_nag,1);

pic_pos  = [pic; pic_other_pos];
pic_pos(pic_pos<0) = 0;
pic_nag  = [pic; pic_other_nag];
pic_nag(pic_nag>0) = 0;

col(ismember(grp_sub(:,1:2),'DE','rows'),:) = [60 125 222]/255;
col(ismember(grp_sub(:,1:2),'GB','rows'),:) = [111 212 212]/255;
col(ismember(grp_sub(:,1:2),'JP','rows'),:) = [249 241 148]/255;
col(ismember(grp_sub(:,1:2),'NL','rows'),:) = [249 145 111]/255;
col(ismember(grp_sub(:,1:2),'US','rows'),:) = [0 145 0]/255;
col(ismember(grp_sub(:,1:2),'FR','rows'),:) = [222 101 135]/255;
col(ismember(grp_sub(:,1:2),'RU','rows'),:) = [135 51 222]/255;
col(ismember(grp_sub(:,1:2),[156 156],'rows'),:) = [1 1 1]*.8;
col(ismember(grp_sub(:,1:2),[155 155],'rows'),:) = [1 1 1]*.6;

CDF_bar_stuck(pic_t,pic_pos,[col;col_other(1,:)]);
CDF_bar_stuck(pic_t,pic_nag,[col;col_other(2,:)]);

CDF_histplot(pic_t, pic_all,'-','w',5);
CDF_histplot(pic_t, pic_all,'-','k',2);


CDF_panel([1880 2010 -0.2 0.2],[],{},'Year',['Contribution to RSST index (^oC)'],'fontsize',19)


set(gcf,'position',[1 12 15 10]*1.1,'unit','inches')
set(gcf,'position',[1 18 15 5],'unit','inches')

set(gca,'xtick',[1880:20:2000])

% *************************************************************************
figure(24); clf; hold on;

group = grp_sub;
in_name = {};
for ct = 1:size(group,1)
    name = double(group(ct,:));
    if name(1) > 100
        in_name{ct} = ['Deck ',num2str(name(1))];
    else
        in_name{ct} = char([name(1:2)]);
    end
end

CDF_scatter_legend(in_name,[],col,[2,9,2],'fontsize',17,'mksize',13,'fontweight','Normal')
patch([-0.2 0.2 0.2 -0.2]/2 + 1,[-0.2 -0.2 0.2 0.2] - 10, ...
    'k','linest','none');
text(1+0.09 , -10, '  Others', 'fontsize',17,'fontweight','Normal');
xlim([0.8 8])
ylim([-11 0])
set(gcf,'color','w')
set(gcf,'position',[1 12 15 10]*1.1,'unit','inches')
set(gcf,'position',[1 18 15 5],'unit','inches') 

% Print figure to files
% dir_save = '/Users/duochan/Dropbox/Research/06_SST_TC/TC_manuscript/Submission_to_GRL/Figures/Materials/';
% CDF_save(21,'png',300,[dir_save,'Fig2_1.png']);
% CDF_save(22,'png',300,[dir_save,'Fig2_2.png']);
% CDF_save(23,'png',300,[dir_save,'Fig2_3.png']);
% CDF_save(24,'png',300,[dir_save,'Fig2_4.png']);