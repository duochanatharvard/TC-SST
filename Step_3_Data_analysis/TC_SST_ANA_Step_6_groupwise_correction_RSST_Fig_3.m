clear;

dir_load = TC_SST_IO('Results');
load([dir_load,'SUM_corr_cyclone_idv_HM_SST_Bucket_deck_level_1_do_rmdup_0_correct_kobe_0_connect_kobe_1_yr_start_1850_scaled.mat']);
load([dir_load,'Stats_HM_SST_Bucket_deck_level_1.mat'],'unique_grp')
l = ismember(unique_grp,[74 80 762; 74 80 119],'rows');
unique_grp(l,:) = [];

mon_list = [6:11];

corr_all_mdr  = squeeze(nanmean(TS0_mdr(mon_list,:,2) - TS0_mdr(mon_list,:,1),1));
corr_all_trop = squeeze(nanmean(TS0_trop(mon_list,:,2) - TS0_trop(mon_list,:,1),1));
corr_ind_mdr  = squeeze(nanmean(TS_mdr(mon_list,:,:) - repmat(TS0_mdr(mon_list,:,1),1,1,162),1));
corr_ind_trop = squeeze(nanmean(TS_trop(mon_list,:,:) - repmat(TS0_trop(mon_list,:,1),1,1,162),1));

scl1 = 1.388; scl2 = 1.521;

index_all = scl1*corr_all_mdr  - scl2*corr_all_trop;
index_ind = scl1*corr_ind_mdr  - scl2*corr_ind_trop;

l = max(abs(index_ind),[],1) > 0.02;
index_ind_sub = index_ind(:,l);
grp_sub       = unique_grp(l,:);
col           = distinguishable_colors(nnz(l));

% *************************************************************************
% Fig.3: Break correction into individual groups
% *************************************************************************
pic_t = 1850:2014;

figure(31); clf; subplot(5,1,1:3); hold on;

pic = index_ind_sub';
pic_all = index_all;

pic_other = index_ind(:,~l)';
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

l = ismember(grp_sub(:,1:2),'DE','rows');
temp = hotCD(nnz(l)+3,'b'); col(l,:) = temp(3:end-1,:);
l = ismember(grp_sub(:,1:2),'GB','rows');
temp = hotCD(nnz(l)+3,'c'); col(l,:) = temp(3:end-1,:);
l = ismember(grp_sub(:,1:2),'JP','rows');
temp = hotCD(nnz(l)+3,'y'); col(l,:) = temp(2:end-2,:);
l = ismember(grp_sub(:,1:2),'NL','rows');
temp = hotCD(nnz(l)+4,'r'); col(l,:) = temp(4:end-1,:);
l = ismember(grp_sub(:,1:2),'US','rows');
temp = hotCD(nnz(l)+3,'g'); col(l,:) = temp(3:end-1,:);
l = ismember(grp_sub(:,1:2),['NO';'RU'],'rows');
temp = hotCD(nnz(l)+3,'m'); col(l,:) = temp(3:end-1,:);
l = grp_sub(:,1) > 100;
temp = hotCD(nnz(l)+3,'gry'); col(l,:) = temp(3:end-1,:);

CDF_bar_stuck(pic_t,pic_pos,[col;col_other(1,:)]);
CDF_bar_stuck(pic_t,pic_nag,[col;col_other(2,:)]);

CDF_histplot(pic_t, pic_all,'-','w',5);
CDF_histplot(pic_t, pic_all,'-','k',2);


CDF_panel([1880 2010 -0.2 0.2],[],{},'Year',['Contribution to RSST index (^oC)'],'fontsize',18)


set(gcf,'position',[1 12 15 10]*1.1,'unit','inches')
set(gcf,'position',[1 12 15 10]*1.1,'unit','inches')

set(gca,'xtick',[1880:20:2000])

% *************************************************************************
% legend
% *************************************************************************
subplot(5,1,4:5); hold on;

group = grp_sub;
in_name = {};
for ct = 1:size(group,1)
    name = double(group(ct,:));
    if name(1) > 100
        in_name{ct} = ['Deck ',num2str(name(3))];
    else
        in_name{ct} = [name(1:2),' - ',num2str(name(3))];
    end
end
CDF_scatter_legend(in_name,[],col,[1,6,1],'fontsize',17,'mksize',13)
patch([-0.2 0.2 0.2 -0.2]/2 + 6,[-0.2 -0.2 0.2 0.2] - 2, ...
    'k','linest','none');
text(6+0.09 , -2, '  Others', 'fontsize',17,'fontweight','bold');
xlim([0.8 7])
ylim([-6 0])