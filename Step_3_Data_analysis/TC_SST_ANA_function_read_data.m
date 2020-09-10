% [TC0_raw,count,yr] = TC_SST_ANA_function_read_data(exp_id,P)
% P.region
% P.threshold_wind   when threshold_wind == 33, x1.2 to calibrate

function [TC0_raw,count,yr] = TC_SST_ANA_function_read_data(exp_id,P)
    
    if ~isfield(P,'threshold_wind')
        P.threshold_wind = 33;
    end
    threshold_wind = P.threshold_wind;

    dir_home = TC_SST_IO('TC_simulations');
    
    switch exp_id
        case 0
            dir    = [dir_home,'amipHadISSTlong/'];
        case 1
            dir    = [dir_home,'amipHadISSTlongChancorr/'];
        case 2
            dir    = [dir_home,'1990_slice/'];
        case 3
            dir    = [dir_home,'rcp45_slice/'];
    end
    
    % *********************************************************************
    % Count hurricane frequency at grid box level
    % *********************************************************************
    file_save_count = [dir,'global_count_R1.mat'];
    disp(file_save_count)
    
    try
        load(file_save_count,'count');
        
    catch
        
        clear('lat0','lon0','wind0','yr','l_is_cyclone')
        file   = [dir,'tracks_G.nc'];
        lat0   = ncread(file,'LAT');
        lon0   = ncread(file,'LON');
        wind0  = ncread(file,'WIND');
        
        if exp_id >= 2  % time slice run
            
            l_is_cyclone = max(wind0,[],1) > threshold_wind;
            lat0(repmat(~l_is_cyclone,120,1,1)) = nan;
            lon0(repmat(~l_is_cyclone,120,1,1)) = nan;
            
            clear('count')
            count = zeros(360,180,100);
            for ct_hurr = 1:200
                
                if rem(ct_hurr,20) == 1
                    disp([num2str(ct_hurr),'/200'])
                end
                
                for ct_yr = 1:100
                    t_lon = lon0(:,ct_hurr,ct_yr);
                    t_lon(t_lon > 180) = t_lon(t_lon > 180) - 360;
                    t_lat = lat0(:,ct_hurr,ct_yr);
                    if ~all(isnan(t_lon))
                        clear('count_temp')
                        count_temp = hist2d([t_lon(:)  t_lat(:)],[-180 1 180; -90 1 90]);
                        count_temp(count_temp > 1) = 1;
                        count(:,:,ct_yr) = count(:,:,ct_yr) + count_temp;
                    end
                end
            end
            count = count(:,:,1:50);
            
        else                    % century-long run
            
            l_is_cyclone = max(wind0,[],1) > threshold_wind;
            lat0(repmat(~l_is_cyclone,120,1,1,1)) = nan;
            lon0(repmat(~l_is_cyclone,120,1,1,1)) = nan;
            
            clear('count')
            count = zeros(360,180,5,148);
            for ct_hurr = 1:200
                
                if rem(ct_hurr,20) == 1
                    disp([num2str(ct_hurr),'/200'])
                end
                
                for ct_en = 1:5
                    for ct_yr = 1:148
                        
                        t_lon = lon0(:,ct_en,ct_hurr,ct_yr);
                        t_lon(t_lon > 180) = t_lon(t_lon > 180) - 360;
                        t_lat = lat0(:,ct_en,ct_hurr,ct_yr);
                        if ~all(isnan(t_lon))
                            clear('count_temp')
                            count_temp = hist2d([t_lon(:)  t_lat(:)],[-180 1 180; -90 1 90]);
                            count_temp(count_temp > 1) = 1;
                            count(:,:,ct_en,ct_yr) = count(:,:,ct_en,ct_yr) + count_temp;
                        end
                    end
                end
            end
        end
        
        save(file_save_count,'count','-v7.3')
    
    end
        
    % *********************************************************************
    % Count hurricane frequency at basin level
    % *********************************************************************
    clear('lat0','lon0','wind0','yr','l_is_cyclone')
    file   = [dir,'tracks_',P.region,'.nc'];
    lat0   = ncread(file,'LAT');
    lon0   = ncread(file,'LON');
    wind0  = ncread(file,'WIND');


    if exp_id >= 2  % time slice run

        yr            = [];
        l_is_cyclone = max(wind0,[],1) > threshold_wind;
        lat0(repmat(~l_is_cyclone,120,1,1)) = nan;
        
        l = squeeze(nansum(any(~isnan(lat0),1),2));
        if threshold_wind == 33
            TC0_raw = l * 1.2;
        else
            TC0_raw = l;
        end
        
        TC0_raw = TC0_raw(1:50);

    else               % century-long run
        
        yr = 1870 + [1:size(lon0,4)];
        l_is_cyclone = max(wind0,[],1) > threshold_wind;
        lat0(repmat(~l_is_cyclone,120,1,1,1)) = nan;
        
        l = squeeze(nansum(any(~isnan(lat0),1),3));
        if threshold_wind == 33
            TC0_raw = l * 1.2;
        else
            TC0_raw = l;
        end
        TC0_raw = TC0_raw(1:5,:);
        
    end
end