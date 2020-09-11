clear;

dir_home = '/Users/duochan/Data/SST_Cyclone/';

% *************************************************************************  
% observations 
% *************************************************************************  
TC       = load([TC_SST_IO('Results'),'Atlantic_TC_count.txt']);
yr_obs   = TC(:,1);
TC       = TC(:,2);

% *************************************************************************  
% read uncertainty in models associated with uncertin SST adjustments
% *************************************************************************  
ERR = load([TC_SST_IO('Results'),'Error_from_SST_R1.mat']);

% *************************************************************************  
% Read model outputs  
% *************************************************************************  
clear('P')
P.region = 'NA';
P.threshold_wind = 31.7;
[NA0,~,~]        = TC_SST_ANA_function_read_data(0,P);
[NA1,~,yr]       = TC_SST_ANA_function_read_data(1,P);

N_eff_0 = nnz(any(NA0~=0,2));
N_eff_1 = nnz(any(NA1~=0,2));
NA0 = NA0(1:N_eff_0,:);
NA1 = NA1(1:N_eff_1,:);

do_splice = 0;                  % TODO
if do_splice == 1               % Turn off corrections in the satellite era
    NA1(:,[1981:2018]-1870) = NA0(:,[1981:2018]-1870);
    ERR.Error_from_SST(:,[1989:2014] - ERR.yr(1) + 1) = 0;
    ERR.Error_from_SST(:,[1975:1988] - ERR.yr(1) + 1) = ERR.Error_from_SST(:,[1975:1988] - ERR.yr(1) + 1) .* repmat([14:-1:1]/15,20000,1);
end

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
% Estimate internal variability
% ************************************************************************
Internal_std = 2.11;

% ************************************************************************
% Significant test of changes in R an RMSE
% ************************************************************************
clear('P')
P.N_sample = 10000;
P.block_size = 10;
P.Internal_std = Internal_std;
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
                                ([1885:2011],15,TC_15,TC_15_rnd,NA0_15,NA1_15,P);
            Table_yr(ct,:) = [1885 2011];
        case 2
            [RS0, RS1, RMSE0, RMSE1, S] = significance_test_null_distribution ...
                                ([1890:2006],25,TC_25,TC_25_rnd,NA0_25,NA1_25,P);
            Table_yr(ct,:) = [1890 2006];
    end

    Table(ct,:) = [S([1 2]).^2 S([3 4])];
    Table_sig_95(ct,2) = (S(2).^2 - S(1).^2) > quantile((RS1.^2 - RS0.^2),0.95);
    Table_sig_95(ct,4) = (S(4) - S(3)) < quantile((RMSE1 - RMSE0),0.05);
    Table_sig_90(ct,2) = (S(2).^2 - S(1).^2) > quantile((RS1.^2 - RS0.^2),0.9);
    Table_sig_90(ct,4) = (S(4) - S(3)) < quantile((RMSE1 - RMSE0),0.1);
    
    
    if ct == 1
        
        figure(1); clf;
        subplot(2,1,1); hold on;
        CDF_histogram(-1:0.01:1,RS1.^2 - RS0.^2,[1 .6 0],0,2)
        plot([1 1]*(S(2).^2-S(1).^2),[0 5],'color',[1 .6 0]*.0,'linewi',3)
        plot([1 1]*nanmean(RS1.^2 - RS0.^2),[0 5],'color',[1 .6 0]*.8,'linewi',3)
        CDF_panel([-.6 .6 0 5],'','','\Delta r^2','pdf','fontsize',18)
        
        subplot(2,1,2); hold on;
        CDF_histogram(-2:0.01:2,RMSE1 - RMSE0,[1 .6 0],0,1)
        plot([1 1]*(S(4)-S(3)),[0 4],'color',[1 .6 0]*.0,'linewi',3)
        plot([1 1]*nanmean(RMSE1 - RMSE0),[0 4],'color',[1 .6 0]*.8,'linewi',3)
        CDF_panel([-.6 .6 0 4],'','','\Delta RMSE','pdf','fontsize',18)
        
        set(gcf,'position',[.1 13 5 8]*1.2,'unit','inches')
        set(gcf,'position',[.1 13 7 8]*1.2,'unit','inches')
    end

end

%
Table_latex = [['15-yr &  ';'25-yr &  '], num2str(Table,' %6.2f  & %5.2f & %6.2f  & %5.2f \\\\')];
disp(' ')
disp(' ')
disp('     & Period & R^2(HadISST1) & R^2(HadISST1b) &  RMSE(HadISST1) & RMSE(HadISST1b) \\')
disp(Table_latex(1,:))
disp(['significance at the 0.05 level:  & -- & ', num2str(Table_sig_95(1,[2 4]) ,'%2.0f  & -- & %2.0f \\\\')])
disp(['significance at the 0.10 level:  & -- & '  , num2str(Table_sig_90(1,[2 4]) ,'%2.0f  & -- & %2.0f \\\\')])
disp(Table_latex(2,:))
disp(['significance at the 0.05 level:  & -- & ', num2str(Table_sig_95(2,[2 4]) ,'%2.0f  & -- & %2.0f \\\\')])
disp(['significance at the 0.10 level:  & -- & ', num2str(Table_sig_90(2,[2 4]) ,'%2.0f  & -- & %2.0f \\\\')])


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