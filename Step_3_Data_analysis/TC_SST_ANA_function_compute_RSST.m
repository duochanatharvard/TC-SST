function RSST = TC_SST_ANA_function_compute_RSST(sst,lon,lat,yr)

    sst = sst - repmat(nanmean(sst(:,:,:,[1982:2005]-yr(1)+1),4),1,1,1,size(sst,4));

    MASK = ones(numel(lon),numel(lat));
    MASK(lon < 280 | lon > 340,:) = 0;
    MASK(:,lat < 10 | lat > 25)   = 0;
    SST_1 = CDC_mask_mean(sst,lat,MASK);

    MASK = ones(numel(lon),numel(lat));
    MASK(:,lat < -30 | lat > 30)   = 0;
    SST_2 = CDC_mask_mean(sst,lat,MASK);

    RSST = 1.388*SST_1 - 1.521 * SST_2;
    RSST = nanmean(RSST(6:11,:),1);
end