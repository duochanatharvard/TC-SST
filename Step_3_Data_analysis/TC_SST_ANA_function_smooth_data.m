function [NA0_sm,NA1_sm,TC_sm,TC_sm_rnd,TC_sm_rnd_err] ...
                      = TC_SST_ANA_function_smooth_data(sm_yr,NA0,NA1,TC,yr_obs,P)

    if ~isfield(P,'N_samples')
        N_samples = 10000;
    else
        N_samples = P.N_samples;
    end

    dir_home = TC_SST_IO('Results');
    do_boot = P.do_boot;

    if do_boot == 0  % compute uncertainty using only 5 members
        if sm_yr > 1
            for ct = 1:size(NA0,1)
                NA0_sm(ct,:) = smooth(double(NA0(ct,:)),sm_yr);
            end

            for ct = 1:size(NA1,1)
                NA1_sm(ct,:) = smooth(double(NA1(ct,:)),sm_yr);
            end
        else
            NA0_sm = NA0;
            NA1_sm = NA1;
        end
    else
        rng(0);

        N_bt = N_samples;
        N_block = 1;
        
        seed = fix(unifrnd(1e-10,size(NA0,1),N_bt,size(NA0,2)))+1;
        clear('NA0_bt','NA0_sm')
        for ct = 1:size(NA0,2)
            [~,b] = ind2sub([N_block,1000],ct);
            ct_pst = (b-1)*N_block+1;
            pst = seed(:,ct_pst);
            temp = NA0(:,ct);        NA0_bt(:,ct) = temp(pst);
        end
        if sm_yr > 1
            for ct = 1:size(NA0_bt,1)
                NA0_sm(ct,:) = smooth(double(NA0_bt(ct,:)),sm_yr);
            end
        else
            for ct = 1:size(NA0_bt,1)
                NA0_sm(ct,:) = double(NA0_bt(ct,:));
            end
        end
        
        seed = fix(unifrnd(1e-10,size(NA1,1),N_bt,size(NA1,2)))+1;
        clear('NA1_bt','NA1_sm')
        for ct = 1:size(NA1,2)
            [~,b] = ind2sub([N_block,1000],ct);
            ct_pst = (b-1)*N_block+1;
            pst = seed(:,ct_pst);
            temp = NA1(:,ct);        NA1_bt(:,ct) = temp(pst);
        end
        if sm_yr > 1
            for ct = 1:size(NA0_bt,1)
                NA1_sm(ct,:) = smooth(double(NA1_bt(ct,:)),sm_yr);
            end
        else
            for ct = 1:size(NA0_bt,1)
                NA1_sm(ct,:) = double(NA1_bt(ct,:));
            end
        end
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