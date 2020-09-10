% TC_SST_generate_HadISST1b_step_01_scale_bucket_corrections(en)
% en == 0:  corrections using MLE of offsets
% en == 1~20: corrections using preturbed offsets
% It takes around 3.5 hrs to finish one ensemble member 

function TC_SST_generate_HadISST1b_step_01_scale_bucket_corrections(en)

    % *************************************************************************
    % Set parameters
    % *************************************************************************
    dir = TC_SST_IO('2x2_bucket_only');
    file_raw  = [dir,'corr_idv_HM_SST_Bucket_deck_level_1_en_0_do_rmdup_0_correct_kobe_0_connect_kobe_1_yr_start_1850.mat'];
    if en == 0
        file_corr  = file_raw;
    else
        file_corr = [dir,'corr_rnd_HM_SST_Bucket_deck_level_1_en_',num2str(en),'_do_rmdup_0_correct_kobe_0_connect_kobe_1_yr_start_1850.mat'];
    end

    % *************************************************************************
    % Load in groupwise corrections SSTs
    % *************************************************************************
    clear('BIAS','NUM','WM','corr')
    if strcmp(file_raw,file_corr)
        load(file_raw,'NUM','WM')
        NUM  = squeeze(NUM(:,:,1,:,:));
        BIAS = squeeze(WM(:,:,2,:,:) - WM(:,:,1,:,:));
    else
        load(file_raw,'NUM','WM')
        NUM  = squeeze(NUM(:,:,1,:,:));
        corr = load(file_corr,'WM');
        BIAS = corr.WM(:,:,:,:) - squeeze(WM(:,:,1,:,:));
    end
    clear('WM','corr')

    % *************************************************************************
    % Load in land_masks to be removed in infilled corrections
    % *************************************************************************
    load('land_mask_2x2.mat');

    Data_save = nan(180,89,165*12);

    for yr = 1850:2014
        for mon = 1:12

            disp(['Year: ',num2str(yr),'  Month: ',num2str(mon)]);

            tic;
                corr_out = TC_SST_generate_HadISST1b_function_generate_corrections(yr,mon,NUM,BIAS,sst_mask);
            toc

            Data_save(:,:,(yr-1850) * 12 + mon) = corr_out;
        end
    end

    dir_save = TC_SST_IO('2x2_scaled_bucket');
    file_save = [dir_save,'ICOADSb_bucket_groupwise_correction_en_',num2str(en),'.mat'];
    save(file_save,'Data_save','-v7.3')
end

