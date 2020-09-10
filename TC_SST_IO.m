% Input / Output directories

function output = TC_SST_IO(input)

    if strcmp(input,'home')
        % home directory in which data is stored
        % output = '/Users/duochan/Data/SST_Cyclone/Data_publish/';
        load('TC_SST_directories.mat')
        output = dir_data;

    elseif strcmp(input,'ICOADS_raw')
        output = '/Users/duochan/Data/ICOADS3/ICOADS_QCed/';

    elseif strcmp(input,'SST')
        output = [TC_SST_IO('home'),'SSTs/'];

    elseif strcmp(input,'2x2_bucket_only')
        output = [TC_SST_IO('SST'),'Step_0_2_degree_bucket_only_uninfilled_estimates/'];

    elseif strcmp(input,'2x2_scaled_bucket')
        output = [TC_SST_IO('SST'),'Step_1_2_degree_scaled_bucket_adjustments/'];

    elseif strcmp(input,'HadISST1b')
        output = [TC_SST_IO('SST'),'Step_2_HadISST1b_and_ensemble/'];

    elseif strcmp(input,'TC_simulations')
        output = [TC_SST_IO('home'),'TC_simulations/'];

    elseif strcmp(input,'Results')
        output = [TC_SST_IO('home'),'Results/'];

    end
end
