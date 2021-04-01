% obervation
N_samples      = size(TC_15_rnd,1);
internal_obs   = normrnd(0,sigma_internal,N_samples,142);
for ct = 1:size(internal_obs,1)
    internal_obs_15(ct,:) = smooth(internal_obs(ct,:),15);
end

% model
I = randperm(20000);
N_yr = size(NA0,2);
internal_m1      = normrnd(0,sigma_internal,N_samples,N_yr);
internal_m2      = normrnd(0,sigma_internal,N_samples,N_yr);

clear('internal_m1_15','internal_m2_15')
for ct = 1:size(internal_m1,1)
    internal_m1_15(ct,:) = smooth(internal_m1(ct,:),15);
    internal_m2_15(ct,:) = smooth(internal_m2(ct,:),15);
end