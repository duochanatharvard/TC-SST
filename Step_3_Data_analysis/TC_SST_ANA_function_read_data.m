% [TC0,count,yr] = TC_SST_ANA_function_read_data(exp_id,P)
% P.region
% P.threshold_wind   when threshold_wind == 33, x1.2 to calibrate

function [TC0,count,yr] = TC_SST_ANA_function_read_data(exp_id,P)
    
    if ~isfield(P,'threshold_wind')
        threshold_wind = 31.7;
    else
        threshold_wind = P.threshold_wind;
    end
    
    dir_home = TC_SST_IO('TC_simulations');
    
    switch exp_id
        case 0
            dir    = [dir_home,'amipHadISSTlong/'];
        case 1
            dir    = [dir_home,'amipHadISSTlongChancorr/'];
        case 10
            dir    = [dir_home,'amipHadISST2long/'];
        case 11
            dir    = [dir_home,'amipHadISST2longChancorr/'];
        case 20
            dir    = [dir_home,'AM2.5_C360_TRAJ_amipblend/'];
        case 21
            dir    = [dir_home,'AM2.5_C360_TRAJ_amipblend_chancorr/'];
    end
    
    % *********************************************************************
    % Count hurricane frequency at grid box level
    % *********************************************************************
    file_save_count = [dir,'TS_track_density_G.nc'];
    count = ncread(file_save_count,'track_density');

    % *********************************************************************
    % Count hurricane frequency at basin level
    % *********************************************************************
    clear('lat0','lon0','wind0','yr','l_is_cyclone')
    file   = [dir,'TS_tracks_',P.region,'.nc'];
    wind0  = ncread(file,'wnd');
    yr     = ncread(file,'year');
        
    l_is_cyclone = max(wind0,[],1) > threshold_wind;
    wind0(repmat(~l_is_cyclone,120,1,1,1)) = nan;

    N = squeeze(nansum(any(~isnan(wind0),1),3));
    if threshold_wind == 33
        TC0_raw = N * 1.2;
    else
        TC0_raw = N;
    end

    l     = yr' >= 1871 & nanmean(TC0_raw,1)~=0 & yr' <= 2018;
    count = count(:,:,:,l);
    TC0   = TC0_raw(:,l);
    yr    = yr(l);
    
end