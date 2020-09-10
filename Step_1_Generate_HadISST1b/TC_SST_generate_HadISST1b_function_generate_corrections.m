function  corr_out = TC_SST_generate_HadISST1b_function_generate_corrections(yr,mon,NUM,BIAS,sst_mask)

    % -------------------------------------------------------------------------
    % 1. Count the number of valid SSTs from all methods, which is six times of 
    %    the number of buoy SSTs plus the number of all other SSTs.  
    %    Weighting buoy SSTs by six is to partially account for mass of satellite
    %    observations.  In a sensitivity test, satellite era is removed
    %    from simulated hurricanes.
    % -------------------------------------------------------------------------

    P.mute_read = 1;
    P.yr  = yr;
    P.mon = mon;
    P.do_connect   = 1;
    P.connect_Kobe = 1;
    P.var_list = {'C0_YR',      'C0_MO',     'C0_DY',    'C0_HR',      'C0_LCL',    'C0_UTC', ...
                  'C98_UID',    'C0_LON',    'C0_LAT',   'C1_DCK',     'C1_SID',...
                  'C0_II',      'C1_PT',     'C0_SST',   'C0_OI_CLIM', 'C0_SI_1',...
                  'C1_ND',      'C0_SI_2',   'C0_SI_3',  'C0_SI_4',    'QC_FINAL',...
                  'C0_CTY_CRT', 'C1_DUPS',   'C0_IT'};

    Data  = TC_SST_generate_HadISST1b_function_read_SST(P);

    lon   = Data.C0_LON;
    lat   = Data.C0_LAT;
    si    = Data.C0_SI_4;

    l_buoy = si == -2;
    l_bck  = si >= 0 & si <0.05;

    count_buoy  = hist2d([lon(l_buoy)'  lat(l_buoy)'],  [0 2 360;-90 2 90]);
    count_other = hist2d([lon(~l_buoy)' lat(~l_buoy)'], [0 2 360;-90 2 90]);
    count_bck   = NUM(:,:,P.mon,P.yr-1849);  
    bias        = BIAS(:,:,P.mon,P.yr-1849);
    

    mask        = isnan(count_bck);
    count_bck(isnan(count_bck)) = 0;

    count_total = count_other + count_buoy * 6;

    % -------------------------------------------------------------------------
    % 2. Compute a weighted average between the groupwise bucket corrections and zero, 
    %    where weight is the percentage of bucket SSTs.  
    %    In addition, to account for the spread out of information when mapping for global coverage, 
    %    I performed a spatial smoothing with scale of 5 boxes, which is,
    % 	     S(C_g * N_bck)
    %    f = --------------,
    %         S(N_total)
    %    where C_g is groupwise correction, N_bck is the number of bucket measurements, 
    %    N_total is the total number of SST measurements, and S denote the operation of the 2D smoothing.
    % -------------------------------------------------------------------------
    corr              = count_bck .* bias;
    corr(isnan(corr)) = 0;

    count_total_sm    = CDC_smooth2(count_total,5);
    corr_sm           = CDC_smooth2(corr,5) ./ count_total_sm;

    corr_sm(mask)     = nan;
    corr_sm(sst_mask) = 0;
    corr_sm(:,89:90)  = 0;

    % -------------------------------------------------------------------------
    % 3. Interpolate the field in step 3 to have a global coverage.  
    % -------------------------------------------------------------------------
    [lon_grid,lat_grid] = meshgrid(1:2:360,-89:2:89);
    lon_grid = lon_grid';
    lat_grid = lat_grid';
    l = ~isnan(corr_sm);
    l_beg = ~isnan(corr_sm) & lon_grid < 5;
    l_end = ~isnan(corr_sm) & lon_grid > 355;
    corr_interp = griddata([lon_grid(l); lon_grid(l_beg)+360; lon_grid(l_end)-360],...
                           [lat_grid(l); lat_grid(l_beg); lat_grid(l_end)],...
                           [corr_sm(l);  corr_sm(l_beg);  corr_sm(l_end)],...
                           lon_grid,lat_grid,'v4');

    corr_interp(sst_mask) = nan;

    % -------------------------------------------------------------------------
    % 4. Compute the distance to the closest grid that has groupwise corrections, 
    %    and the final correction is scaled by exp(-(distance-2)+/10) to tail corrections
    % -------------------------------------------------------------------------
    Dis = nan(180,90);
    for i = 1:180
        for j = 1:90
            dis = distance(lat_grid(i,j),lon_grid(i,j),lat_grid(~mask),lon_grid(~mask));
            Dis(i,j) = min(dis);
        end
    end

    a = (Dis-2); a(a<0) = 0;
    corr_sm_exp = corr_interp .* exp(-a/10);  

    
    corr_out(:,:,1) = corr_sm_exp(:,1:end-1);
    corr_out(:,:,2) = corr_sm_exp(:,2:end);
    corr_out = nanmean(corr_out,3);
    corr_out(sst_mask) = nan;

end