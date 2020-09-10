% TC_SST_generate_HadISST1b_step_02_merge_with_HadISST1(en)
% en == 0:  corrections using MLE of offsets
% en == 1~20: corrections using preturbed offsets
% It takes around 10 seconds to finish one ensemble member 

function TC_SST_generate_HadISST1b_step_02_merge_with_HadISST1(en)

    dir_hadISST1 = TC_SST_IO('SST');
    dir          = TC_SST_IO('2x2_scaled_bucket');
    dir_save     = TC_SST_IO('HadISST1b');

    % *************************************************************************
    % Load in HadISST1
    % *************************************************************************
    file_HadISST1 = [dir_hadISST1,'HadISST_sst.nc'];
    sst      = ncread(file_HadISST1,'sst');
    time_H1  = datevec(double(ncread(file_HadISST1,'time')+datenum([1870 1 1])));
    lon      = ncread(file_HadISST1,'longitude');
    lat      = ncread(file_HadISST1,'latitude');
    lH1      = time_H1(:,1) >= 1871 & time_H1(:,1) <=2018;

    % *************************************************************************
    % Load in mapped groupwise corrections
    % *************************************************************************
    file = [dir,'ICOADSb_bucket_groupwise_correction_en_',num2str(en),'.mat'];
    grp_corr = load(file);

    lon_corr = [0:2:359]';
    lat_corr = [-88:2:88]';
    lon_corr   = reshape(lon_corr,numel(lon_corr),1);
    [lat0,lon0] = meshgrid(lat_corr,[lon_corr-360; lon_corr; lon_corr+360]);

    [lat_target,lon_target] = meshgrid(lat,lon);

    clear('field_1x1')
    for ct = 1:size(grp_corr.Data_save,3)
        field = grp_corr.Data_save(:,:,ct);
        field_1x1(:,:,ct) = interp2(lat0,lon0,[field; field; field],lat_target,lon_target);
    end
    field_1x1(isnan(field_1x1)) = 0;

    % *************************************************************************
    % Merge groupwise correction to HadISST1 raw data
    % *************************************************************************
    clear('sst_corr');
    sst_corr = sst(:,:,(1871-1870)*12+1 : (2014-1869)*12) + field_1x1(:,:,(1871-1850)*12+1 : (2014-1849)*12); 
    sst_corr(:,:,1728+[1:48]) = sst(:,:,(2015-1870)*12+1 : (2018-1869)*12);

    % *************************************************************************
    % Save NC files
    % *************************************************************************
    HadISST1b = sst_corr([181:360,1:180],[end:-1:1],:);
    lon(lon < 0) = lon(lon < 0) + 360;

    % Save data ----------------------------------
    file_save = [dir_save,'HadISST1b_monthly_1871-2018_en_',num2str(en),'.nc'];

    lon_dim  = 360;
    lat_dim  = 180;
    time_dim = 1776;

    nccreate(file_save,'lon','Dimensions', {'lon',lon_dim},...
        'Datatype','single','FillValue','disable','Format','netcdf4');  
    ncwrite(file_save,'lon',lon([181:360 1:180]));

    nccreate(file_save,'lat','Dimensions', {'lat',lat_dim},...
        'Datatype','single','FillValue','disable','Format','netcdf4');  
    ncwrite(file_save,'lat',lat([end:-1:1]));

    nccreate(file_save,'time','Dimensions', {'time',time_dim},...
        'Datatype','single','FillValue','disable','Format','netcdf4');  
    ncwrite(file_save,'time',time_H1(lH1,1));

    nccreate(file_save,'sst','Dimensions', {'lon',lon_dim,'lat',lat_dim,'time',time_dim},...
        'Datatype','single','FillValue','disable','Format','netcdf4');  
    ncwrite(file_save,'sst',HadISST1b);

end