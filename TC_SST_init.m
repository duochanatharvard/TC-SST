% TC_SST_init(dir_data)
% Input dir_data is the directory for storing data
%    default is under the code directory.
%
% TC_SST_init('/Users/duochan/Data/SST_Cyclone/TC_SST_DATA/')
%
function TC_SST_init(dir_data)

    % ********************************************
    % Make directories
    % ********************************************
    dir_code = [pwd,'/'];
    if ~exist('dir_data','var')
        dir_data = [dir_code,'TC_SST_DATA/']; 
    end
    if dir_data(end)~= '/'  
        dir_data = [dir_data,'/']; 
    end
    
    mkdir(dir_data)
    cd(dir_data)
    
    mkdir SSTs/
    mkdir SSTs/Step_0_2_degree_bucket_only_uninfilled_estimates/
    mkdir SSTs/Step_1_2_degree_scaled_bucket_adjustments/
    mkdir SSTs/Step_2_HadISST1b_and_ensemble/
    
    % mkdir TC_simulations/
    % mkdir TC_simulations/amipHadISSTlong/
    % mkdir TC_simulations/amipHadISSTlongChancorr/
    % mkdir TC_simulations/1990_slice/
    % mkdir TC_simulations/rcp45_slice/
    
    % mkdir Results/
    
    cd(dir_code)  
    save('TC_SST_directories.mat','dir_data','dir_code','-v7.3');
    
end