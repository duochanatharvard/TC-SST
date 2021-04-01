% It typically takes 3-4 minutes to run all the analysis on a MacBook Pro 2019
% 2.8 GHz Intel Corei7 ~ 16GB2133MHz LPDDR3
%
% After running these scripts, all panels of main text and supplemental 
% figures will be generated.  Key statistics will be also be printed in the
% command window.

clear;

load('TC_SST_directories.mat')
addpath(dir_code);
addpath([dir_code,'/Step_1_Generate_HadISST1b/']);
addpath([dir_code,'/Step_2_Model_simulations/']);
addpath([dir_code,'/Step_3_Data_analysis/']);
addpath([dir_code,'/Functions/']);
addpath([dir_code,'/m_map/']);

% *************************************************************************
% Download and unzip file
% *************************************************************************
load('TC_SST_directories.mat','dir_data','dir_code')

disp(['downloading data ...']); 
tic;

cd(dir_data)
websave('TC_simulations.tar.gz','https://dataverse.harvard.edu/api/access/datafile/4494684');

try
    !tar -zxvf TC_simulations.tar.gz
catch
    !tar -zxvf TC_simulations.tar
end
websave('Results.tar.gz','https://dataverse.harvard.edu/api/access/datafile/4494685');
try
    !tar -zxvf Results.tar.gz
catch
    !tar -zxvf Results.tar
end

% uncommen the following lines to download ensembles of SSTs
% cd(TC_SST_IO('SST'))
% websave('HadISST_sst.nc','https://dataverse.harvard.edu/api/access/datafile/4062524');
% 
% cd(TC_SST_IO('HadISST1b'))
% websave('HadISST1b_monthly_1871-2018_en_0.nc','https://dataverse.harvard.edu/api/access/datafile/4062549');
% 
% websave('HadISST1b_monthly_1871-2018_en_1.nc','https://dataverse.harvard.edu/api/access/datafile/4062536');
% websave('HadISST1b_monthly_1871-2018_en_2.nc','https://dataverse.harvard.edu/api/access/datafile/4062538');
% websave('HadISST1b_monthly_1871-2018_en_3.nc','https://dataverse.harvard.edu/api/access/datafile/4062542');
% websave('HadISST1b_monthly_1871-2018_en_4.nc','https://dataverse.harvard.edu/api/access/datafile/4062541');
% websave('HadISST1b_monthly_1871-2018_en_5.nc','https://dataverse.harvard.edu/api/access/datafile/4062554');
% 
% websave('HadISST1b_monthly_1871-2018_en_6.nc','https://dataverse.harvard.edu/api/access/datafile/4062537');
% websave('HadISST1b_monthly_1871-2018_en_7.nc','https://dataverse.harvard.edu/api/access/datafile/4062545');
% websave('HadISST1b_monthly_1871-2018_en_8.nc','https://dataverse.harvard.edu/api/access/datafile/4062555');
% websave('HadISST1b_monthly_1871-2018_en_9.nc','https://dataverse.harvard.edu/api/access/datafile/4062553');
% websave('HadISST1b_monthly_1871-2018_en_10.nc','https://dataverse.harvard.edu/api/access/datafile/4062543');
% 
% websave('HadISST1b_monthly_1871-2018_en_11.nc','https://dataverse.harvard.edu/api/access/datafile/4062548');
% websave('HadISST1b_monthly_1871-2018_en_12.nc','https://dataverse.harvard.edu/api/access/datafile/4062546');
% websave('HadISST1b_monthly_1871-2018_en_13.nc','https://dataverse.harvard.edu/api/access/datafile/4062552');
% websave('HadISST1b_monthly_1871-2018_en_14.nc','https://dataverse.harvard.edu/api/access/datafile/4062539');
% websave('HadISST1b_monthly_1871-2018_en_15.nc','https://dataverse.harvard.edu/api/access/datafile/4062544');
% 
% websave('HadISST1b_monthly_1871-2018_en_16.nc','https://dataverse.harvard.edu/api/access/datafile/4062550');
% websave('HadISST1b_monthly_1871-2018_en_17.nc','https://dataverse.harvard.edu/api/access/datafile/4062547');
% websave('HadISST1b_monthly_1871-2018_en_18.nc','https://dataverse.harvard.edu/api/access/datafile/4062540');
% websave('HadISST1b_monthly_1871-2018_en_19.nc','https://dataverse.harvard.edu/api/access/datafile/4062551');
% websave('HadISST1b_monthly_1871-2018_en_20.nc','https://dataverse.harvard.edu/api/access/datafile/4062556');

disp(['Downloading data takes ',num2str(toc,'%6.0f'),' seconds'])
cd(dir_code)

% *************************************************************************
% Compute statistics and generate figures and tables
% *************************************************************************
clear;
close all;
tic;
    % TC_SST_ANA_module_SST_uncertainty_and_Fig_S1_full_range_of_RSST
    % This script generates error associated with uncertainty SST adjustments
    % it also generates Fig. S4
    
    % Figure 1
    clear; ANA_version = 1; TC_SST_ANA_Fig_1_time_sereis;
    
    % Figure 2
    clear; TC_SST_ANA_Fig_2_RSST_correction;
    
    % Figure 3
    clear; ANA_version = 1; TC_SST_ANA_Fig_3_Hurricane_density_map; 
    
    % Figure 4 will be generated when calculate statistics in Table 1
    clear; ANA_version = 1; TC_SST_ANA_Table_S1;
    
    % Figure 5
    clear; TC_SST_ANA_Fig_5_RMSE;
    
    % Table 1: sensitivity tests
    clear; ANA_version = 2; TC_SST_ANA_Table_S1;
    clear; ANA_version = 3; TC_SST_ANA_Table_S1;
    clear; ANA_version = 1; threshold_wind = 33;  TC_SST_ANA_Table_S1;
    clear; ANA_version = 1; do_splice = 1;  TC_SST_ANA_Table_S1;
    
    % Figure S1
    clear; TC_SST_ANA_Fig_S1_Interannual_variability_of_hurricanes;    

    % Figure S2
    clear; ANA_version = 1;  TC_SST_ANA_Fig_S2_trend_in_track_density;
    clear; ANA_version = 2;  TC_SST_ANA_Fig_S2_trend_in_track_density;
    clear; ANA_version = 3;  TC_SST_ANA_Fig_S2_trend_in_track_density;   
    
    % Figure S3
    clear; ANA_version = 2; TC_SST_ANA_Fig_3_Hurricane_density_map;
    clear; ANA_version = 3; TC_SST_ANA_Fig_3_Hurricane_density_map;

    % Figure S6
    clear; ANA_version = 2; TC_SST_ANA_Fig_3_Hurricane_density_map; 
    clear; ANA_version = 3; TC_SST_ANA_Fig_3_Hurricane_density_map; 
    
disp(['Computation takes ',num2str(toc,'%6.0f'),' seconds'])