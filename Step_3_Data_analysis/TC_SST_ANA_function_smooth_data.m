function [NA0_sm,NA1_sm,TC_sm,TC_sm_rnd,TC_sm_rnd_err] ...
                      = TC_SST_ANA_function_smooth_data(sm_yr,NA0,NA1,TC,yr_obs,P)

    if ~isfield(P,'N_samples')
        N_samples = 10000;
    else
        N_samples = P.N_samples;
    end

    dir_home = TC_SST_IO('Results');
    
    % *********************************************************************
    % Smooth model outputs
    % *********************************************************************
    if sm_yr > 1
        NA0_sm = nan(size(NA0));
        for ct = 1:size(NA0,1)
            NA0_sm(ct,:) = smooth(double(NA0(ct,:)),sm_yr);
        end

        NA1_sm = nan(size(NA1));
        for ct = 1:size(NA1,1)
            NA1_sm(ct,:) = smooth(double(NA1(ct,:)),sm_yr);
        end
    else
        NA0_sm = NA0;
        NA1_sm = NA1;
    end
                
    % *********************************************************************
    % Observed hurricane counts
    % *********************************************************************
    % Assign errors for hurricane corrections
    clear('a','b','c','m','y')
    m = ncread([dir_home,'missed_all_based_on_Vecchi_2011.nc'],'MISS40');
    y = ncread([dir_home,'missed_all_based_on_Vecchi_2011.nc'],'YYEAR');

    mm = reshape(m,43,227,13*50);
    for i = 1:43 mmm(:,i,:) = mm(i,:,:); end
    a = reshape(mmm,227,43*650);
    
    for ct = 1:size(a,1)
        temp = a(ct,:);
        p = randperm(size(a,2));
        b(ct,:) = temp(p);
    end

    c = [b([yr_obs(1):y(end)]-y(1)+1,:); zeros(yr_obs(end) - y(end),size(b,2))];
    c([1965:2019] - yr_obs(1)+1,:) = 0;
    c = c - repmat(nanmean(c,2),1,size(c,2));

    clear('TC_sm_rnd')
    if sm_yr > 1
        TC_sm = smooth(TC,sm_yr);
        for ct = 1:N_samples
            TC_sm_rnd(ct,:) = smooth(c(:,ct)' + TC',sm_yr);
            TC_sm_rnd_err(ct,:) = smooth(c(:,ct)',sm_yr);
        end
    else
        TC_sm  = TC;
        TC_sm_rnd = c(:,1:N_samples)' + repmat(TC',N_samples,1);
        TC_sm_rnd_err = c(:,1:N_samples)';
    end
end