% clear;
rng(0);

P.region    = 'NA';
if ~exist('threshold_wind','var')
    threshold_wind   = 31.7;
end
P.threshold_wind = threshold_wind;
% ANA_version = 1; % 1: 50&25km    2: 50 km only    3: 25km only
if ~exist('ANA_version','var')
    error('Please specify the version of analysis using variable ANA_version')
end
if ~exist('do_splice','var')
    do_splice   = 0;
end

% ************************************************************************* 
TC_SST_ANA_module_load_data;
% ************************************************************************* 

% *************************************************************************  
% Smooth hurricane counts and assign uncertainty estimates 
% *************************************************************************
clear('P')
P.do_boot = 0;
                      
sm_yr  = 15;            
[NA0_15,NA1_15,TC_15,TC_15_rnd,TC_15_rnd_err] = TC_SST_ANA_function_smooth_data(sm_yr,NA0,NA1,TC,yr_obs,P);

sm_yr  = 25;            
[NA0_25,NA1_25,TC_25,TC_25_rnd,TC_25_rnd_err] = TC_SST_ANA_function_smooth_data(sm_yr,NA0,NA1,TC,yr_obs,P);

% ************************************************************************
% Significant test of changes in R an RMSE
% ************************************************************************
clear('P')
P.N_sample = 10000;
P.block_size = 10;
P.Internal_std = sigma_internal;
P.yr_obs = yr_obs;
P.yr = yr;
P.correction = nanmean(NA1,1) - nanmean(NA0,1);
P.N_eff_0 = N_eff_0;
P.N_eff_1 = N_eff_1;

clear('Table','Table_sig_95','Table_sig_90','Table_yr')
for ct = [1 2]
    
    rng(0);
    
    switch ct
        case 1
            [RS0, RS1, RMSE0, RMSE1, S] = significance_test_null_distribution ...
                                ([1885:yr(end)-7],15,TC_15,TC_15_rnd,NA0_15,NA1_15,P);
            Table_yr(ct,:) = [1885 yr(end)-7];
        case 2
            [RS0, RS1, RMSE0, RMSE1, S] = significance_test_null_distribution ...
                                ([1890:yr(end)-12],25,TC_25,TC_25_rnd,NA0_25,NA1_25,P);
            Table_yr(ct,:) = [1890 yr(end)-12];
    end

    Table(ct,:) = [S([1 2]).^2 S([3 4])];
    p1 = 1.01-find((S(2).^2 - S(1).^2) > quantile((RS1.^2 - RS0.^2),[0:0.01:1]),1,'last')/100;
    p2 = find((S(4) - S(3)) < quantile((RMSE1 - RMSE0),[0:0.01:1]),1,'first')/100 - 0.01;
    Table_sig_95(ct,:) = [0 p1 0 p2];    
    
    
    if ct == 1 && ANA_version == 1 && do_splice == 0
        
        figure(41); clf; hold on;
        CDF_histogram(-1:0.01:1,RS1.^2 - RS0.^2,[1 .6 0],0,2)
        plot([1 1]*(S(2).^2-S(1).^2),[0 5],'color',[1 .6 0]*.0,'linewi',3)
        plot([1 1]*nanmean(RS1.^2 - RS0.^2),[0 5],'color',[1 .6 0]*.8,'linewi',3)
        CDF_panel([-.6 .6 0 5],'','',' ','pdf','fontsize',18)
        set(gcf,'position',[.1 13 6 4.5],'unit','inches')
        set(gcf,'position',[.1 13 6 4.5],'unit','inches')
        
        figure(42); clf; hold on;
        CDF_histogram(-2:0.01:2,RMSE1 - RMSE0,[1 .6 0],0,1)
        plot([1 1]*(S(4)-S(3)),[0 5],'color',[1 .6 0]*.0,'linewi',3)
        plot([1 1]*nanmean(RMSE1 - RMSE0),[0 5],'color',[1 .6 0]*.8,'linewi',3)
        CDF_panel([-.6 .6 0 4],'','',' ','pdf','fontsize',18)
        
        set(gcf,'position',[.1 13 5 8]*1.2,'unit','inches')
        set(gcf,'position',[.1 13 6 4.5],'unit','inches')
    end

end

%
Table_latex = [['15-yr &  ';'25-yr &  '], num2str(Table,' %6.2f  & %5.2f & %6.2f  & %5.2f \\\\')];
disp(' ')
disp(' ')
disp('     & Period & R^2(HadISST1) & R^2(HadISST1b) &  RMSE(HadISST1) & RMSE(HadISST1b) \\')
disp(Table_latex(1,:))
disp(['p-value:  & -- & ', num2str(Table_sig_95(1,[2 4]) ,'%2.2f  & -- & %2.2f \\\\')])
disp(Table_latex(2,:))
disp(['p-value:  & -- & ', num2str(Table_sig_95(2,[2 4]) ,'%2.2f  & -- & %2.2f \\\\')])


%% *************************************************************************
% Print figure to files
% *************************************************************************
% dir_save = TC_SST_IO('Figure_save');
% clear('a','b')
% for ct = 1:2
%     file = [dir_save,'Fig_5_significance_test_ANA_version_',num2str(ANA_version),'_sub_',num2str(ct),'.png'];
%     CDF_save(50+ct,'png',300,file);
%     a{ct} = imread(file);
% end
% 
% b = [a{2}(50:end-200,220:end-100,:) a{1}(50:end-200,220:end-100,:)];
% file = [dir_save,'Fig_5_significance_test_ANA_version_',num2str(ANA_version),'.png'];
% imwrite(b,file);


function [RS0, RS1, RMSE0, RMSE1, S] = ...
                  significance_test_null_distribution(yr_list,sm_yr,TC_obs,TC_rnd,TC_mod_0,TC_mod_1,P)
    
    rng(0);
    N_sample     = P.N_sample;
    block_size   = P.block_size;
    Internal_std = P.Internal_std;
    yr_obs       = P.yr_obs;
    yr           = P.yr;
    correction   = P.correction;
    
    clear('rnd_corr')
    rnd_corr_1 = CDC_block_permutation(correction,N_sample,block_size);
    rnd_corr = nan(numel(yr_list),N_sample);
    for ct = 1:N_sample
        
        temp = smooth(rnd_corr_1(:,ct),sm_yr);
        rnd_corr(:,ct) = temp(yr_list-1870);
        
    end

    TC_obs = TC_obs(yr_list-yr_obs(1)+1)';
    TC_mod_0 = nanmean(TC_mod_0(:,yr_list-yr(1)+1),1);
    TC_mod_1 = nanmean(TC_mod_1(:,yr_list-yr(1)+1),1);

    clear('RS0','RS1','RMSE0','RMSE1')
    RS0   = nan(1,N_sample);
    RS1   = nan(1,N_sample);
    RMSE0 = nan(1,N_sample);
    RMSE1 = nan(1,N_sample);
    for ct = 1:N_sample

        temp          = smooth(normrnd(0,Internal_std,1,numel(yr_list)+sm_yr-1),sm_yr)';
        TC_obs_temp   = TC_rnd(round(unifrnd(1,9999,1,1)),yr_list-yr_obs(1)+1) + temp(:,(sm_yr/2+.5):(end-sm_yr/2+.5));

        temp          = smooth(normrnd(0,Internal_std /sqrt(P.N_eff_0),1,numel(yr_list)+sm_yr-1),sm_yr)';
        TC_mod_0_temp = TC_mod_0 + temp(:,(sm_yr/2+.5):(end-sm_yr/2+.5));

        temp          = smooth(normrnd(0,Internal_std /sqrt(P.N_eff_1),1,numel(yr_list)+sm_yr-1),sm_yr)';
        TC_mod_1_temp = TC_mod_0 + temp(:,(sm_yr/2+.5):(end-sm_yr/2+.5)) + rnd_corr(:,ct)';

        RS0(ct) = CDC_corr(TC_obs_temp,TC_mod_0_temp);
        RS1(ct) = CDC_corr(TC_obs_temp,TC_mod_1_temp);

        RMSE0(ct) = sqrt(nanmean((TC_obs_temp - TC_mod_0_temp).^2));
        RMSE1(ct) = sqrt(nanmean((TC_obs_temp - TC_mod_1_temp).^2));
    end

    S(1) = CDC_corr(TC_obs,TC_mod_0,2);
    S(2) = CDC_corr(TC_obs,TC_mod_1,2);
    S(3) = sqrt(nanmean((TC_obs - TC_mod_0).^2));
    S(4) = sqrt(nanmean((TC_obs - TC_mod_1).^2));
end