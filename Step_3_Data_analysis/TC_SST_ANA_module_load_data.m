% *************************************************************************
% observations 
% *************************************************************************
TC       = load([TC_SST_IO('Results'),'Atlantic_TC_count.txt']);
yr_obs   = TC(:,1);
TC       = TC(:,2);

% *************************************************************************  
% read uncertainty in models associated with uncertin SST adjustments
% ************************************************************************* 
try
    % ERR = load([TC_SST_IO('Results'),'Error_from_SST_20210325.mat']);
    file_sst = [TC_SST_IO('Results'),'Error_from_SST.nc'];
    ERR.Error_from_SST = ncread(file_sst,'Error_from_SST');
    ERR.yr = ncread(file_sst,'year')';
catch
    disp([TC_SST_IO('Results'),'Error_from_SST_20210325.mat does not exist!'])
    disp('Run TC_SST_ANA_module_SST_uncertainty_and_Fig_S1_full_range_of_RSST to first create error estimates associated with SSTs.')
end
% Read model outputs  -----------------------------------------------------

switch ANA_version
    case 1
        
        % ANA_version = 0;         % 0: HadISST1  1: HadISST2   2: Hi-flor 25km
        [NA0_50,count_0_50,~]  = TC_SST_ANA_function_read_data(0,P);
        [NA1_50,count_1_50,~] = TC_SST_ANA_function_read_data(1,P);
        
        [NA0_25,count_0_25,~]  = TC_SST_ANA_function_read_data(20,P);
        [NA1_25,count_1_25,yr] = TC_SST_ANA_function_read_data(21,P);
        
        % -----------------------------------------------------------------
        % Combine different resolution model outputs  
        % -----------------------------------------------------------------
        NA0 = [NA0_50; NA0_25(1:3,:)];
        NA1 = [NA1_50; NA1_25(1:3,:)];
        count_0 = cat(3,count_0_50,count_0_25(:,:,1:3,:));
        count_1 = cat(3,count_1_50,count_1_25(:,:,1:3,:));
        
        clear('NA0_50','NA0_25','NA1_50','NA1_25',...
            'count_0_50','count_0_25','count_1_50','count_1_25')
    case 2
        [NA0,count_0,~]  = TC_SST_ANA_function_read_data(0,P);
        [NA1,count_1,yr] = TC_SST_ANA_function_read_data(1,P);
    case 3
        [NA0,count_0,~]  = TC_SST_ANA_function_read_data(20,P);
        [NA1,count_1,yr] = TC_SST_ANA_function_read_data(21,P); 
        NA0 = NA0(1:3,:);         count_0 = count_0(:,:,1:3,:);
        NA1 = NA1(1:3,:);         count_1 = count_1(:,:,1:3,:);
end

% ************************************************************************* 
% Make sure everything has the same years
% ************************************************************************* 
try
    ERR.Error_from_SST = ERR.Error_from_SST(:,ismember(ERR.yr,yr));
    ERR.yr = ERR.yr(ismember(ERR.yr,yr));
catch
end
    
% ************************************************************************* 
% Remove runs that do not have valid outputs
% *************************************************************************
N_eff_0  = nnz(any(NA0~=0,2));
N_eff_1  = nnz(any(NA1~=0,2));
NA0 = NA0(1:N_eff_0,:);
NA1 = NA1(1:N_eff_1,:);
count_0 = count_0(:,:,1:N_eff_0,:);
count_1 = count_1(:,:,1:N_eff_1,:);

% ************************************************************************* 
% Splice estimates after the 1980s
% *************************************************************************
if do_splice == 1               % Turn off corrections in the satellite era
    NA1(:,[1981:2018]-1870) = NA0(:,[1981:2018]-1870);
    ERR.Error_from_SST(:,[1989:2014] - ERR.yr(1) + 1) = 0;
    ERR.Error_from_SST(:,[1975:1988] - ERR.yr(1) + 1) = ERR.Error_from_SST(:,[1975:1988] - ERR.yr(1) + 1) .* repmat([14:-1:1]/15,20000,1);
end

% *************************************************************************   
% Estimate internal variability
% *************************************************************************
a = NA0 - repmat(nanmean(NA0,1),N_eff_0,1);
b = NA1 - repmat(nanmean(NA1,1),N_eff_1,1);
Internal_var0 = nanmean(a(:).^2) * N_eff_0 / (N_eff_0 - 1);
Internal_var1 = nanmean(b(:).^2) * N_eff_1 / (N_eff_1 - 1);
sigma_internal = sqrt((Internal_var0 * N_eff_0 + Internal_var1 * N_eff_1)/(N_eff_0 + N_eff_1));
disp(['Atmospheric Intrinsic Variability: ',num2str(sigma_internal,'%6.2f')])