% output = TC_SST_generate_HadISST1b_function_read_SST(P)
% This version reads in CMAN, 
%                       whereas CMAN are not included in all other analyses
% 
% Required parameters are:
%     P.yr
%     P.mon
%     P.dir_load
% Possible parameters are:
%     P.do_connect
%     P.connect_Kobe
%     P.buoy_diurnal
%     P.var_list

function output = TC_SST_generate_HadISST1b_function_read_SST(P)

    % *********************************************************************
    % Input and Output 
    % *********************************************************************
    % dir_load = LME_OI('ICOADS3');
    % dir_load = '/n/boslfs/TRANSFER/dchan/Early_20th_century_warming/ICOADS3/ICOADS_QCed_v1/';
    % dir_load = P.dir_load; 
    dir_load = TC_SST_IO('ICOADS_raw');

    % *********************************************************************
    % Set up file names to be read
    % *********************************************************************
    clear('file_load','file_save','sst_ascii')
    file_load = [dir_load,'IMMA1_R3.0.0_',num2str(P.yr),'-',CDF_num2str(P.mon,2),'_QCed.mat'];

    % *********************************************************************
    % Define a list of variables to read
    % *********************************************************************
    var_list = get_var_list(P);
    
    % *********************************************************************
    % READ IN THE DATA 
    % *********************************************************************
    try
        clear('logic','kind_temp','sst_ascii_temp')
        if ~isfield(P,'mute_read')
            disp([file_load,' is started!']);
        end

        for var = 1:numel(var_list)
            eval(['clear(''',var_list{var},''');'])
            eval(['load(file_load,''',var_list{var},''')'])
        end
        
        l = QC_FINAL == 1; %  & C0_SI_4 ~= -3;  TODO: commented because C-MAN is used in HadISST1
        for var = 1:numel(var_list)
            if ~ismember(var_list{var},{'C0_ID','C0_CTY_CRT','DCK'})
                eval([var_list{var},' = ',var_list{var},'(l);']);
            else
                eval([var_list{var},' = ',var_list{var},'(l,:);']);
            end
        end
        clear('l')

        % *****************************************************************
        % Process nation and deck if required
        % *****************************************************************
        if isfield(P,'do_connect')
            if P.do_connect == 1
               DCK = LME_function_preprocess_deck(double([C0_CTY_CRT C1_DCK']),P);
               var_list{end+1} = 'DCK';
            end
        end

%         % *****************************************************************
%         % Read Diurnal Cycles
%         % *****************************************************************
%         if isfield(P,'buoy_diurnal')
%             if P.buoy_diurnal == 1
%                 dir_da = LME_OI('Mis');
%                 
%                 if isfield(P,'reproduce_nature')
%                     disp(' ')
%                     disp('Using 2017 version of diurnal signals')
%                     disp(' ')
%                     load([dir_da,'DA_SST_Gridded_BUOY_sum_from_grid.mat'],'CLIM_DASM');
%                     load([dir_da,'Diurnal_Shape_SST.mat'],'Diurnal_Shape');
%                     Diurnal_clim_buoy_1990_2014 = CLIM_DASM;
%                     Diurnal_Shape_1 = squeeze(Diurnal_Shape(:,:,3,:));
%                     clear('Diurnal_Shape')
%                     for ct = 1:12
%                         Diurnal_Shape(:,:,ct) = Diurnal_Shape_1(:,:,ct)';
%                     end
%                 else
%                     load([dir_da,'Diurnal_Amplitude_buoy_SST_1990_2014_climatology.mat'],'Diurnal_clim_buoy_1990_2014');
%                     load([dir_da,'Diurnal_Shape_buoy_SST.mat'],'Diurnal_Shape');
%                 end
%                 DA_mgntd  = LME_function_grd2pnt(C0_LON,C0_LAT,C0_MO,Diurnal_clim_buoy_1990_2014,5,5,1);
%                 Y = fix((C0_LAT+90)/5)+1;  Y(Y>36)=36;
%                 C0_LCL(isnan(C0_LCL)) = 1;
%                 DASHP_id = sub2ind(size(Diurnal_Shape), C0_LCL, Y, C0_MO);
%                 DA_shape  = Diurnal_Shape(DASHP_id);
%                 Buoy_Diurnal = DA_shape .* DA_mgntd;
%                 Buoy_Diurnal(isnan(Buoy_Diurnal)) = 0;
%                 var_list{end+1} = 'Buoy_Diurnal';
%             end
%         end
%         clear('DASHP_id','DA_mgntd','DA_shape','Y')
%         
%         % *****************************************************************
%         % Subset data by UID if exist
%         % *****************************************************************
%         if isfield(P,'C98_UID')
%             [~,pst] = ismember(P.C98_UID,C98_UID);
% 
%             for var = 1:numel(var_list)
%                 if ~ismember(var_list{var},{'C0_ID','C0_CTY_CRT','DCK'})
%                     eval([var_list{var},' = ',var_list{var},'(pst);']);
%                 else
%                     eval([var_list{var},' = ',var_list{var},'(pst,:);']);
%                 end
%             end
%         end
% 
%         % *****************************************************************
%         % Load in fundemental SSTs
%         % *****************************************************************
%         if isfield(P,'use_fundemental_SST')
%             if P.use_fundemental_SST == 1
%                 dir_diurnal  = LME_OI('ship_diurnal');
%                 file_diurnal = [dir_diurnal,'IMMA1_R3.0.0_',num2str(P.yr),'-',...
%                                        CDF_num2str(P.mon,2),'_Ship_Diurnal_Signal',...
%                                        '_relative_to_',P.relative,'.mat'];
%                 FD_SST = load(file_diurnal,'Day_indicator','C98_UID','Fundemental_SST');
%                 if P.diurnal_QC == 1
%                     l_rm = ~ismember(FD_SST.Day_indicator,[0 1]);
%                     FD_SST.C98_UID(l_rm)         = [];
%                     FD_SST.Fundemental_SST(l_rm) = [];
%                     FD_SST.Day_indicator(l_rm)   = [];
%                 end
%                 FD_SST.first_day = ismember(FD_SST.Day_indicator,[1 3]);
%                 Fundemental_SST  = nan(1,numel(C98_UID));
%                 for ct = 1:numel(Fundemental_SST)
%                     if ismember(C98_UID(ct), FD_SST.C98_UID)
%                         l = C98_UID(ct) == FD_SST.C98_UID & FD_SST.first_day;
%                         if nnz(l) > 0
%                             Fundemental_SST(ct) = nanmean(FD_SST.Fundemental_SST(l));
%                         else
%                             l = C98_UID(ct) == FD_SST.C98_UID & FD_SST.first_day == 0;
%                             Fundemental_SST(ct) = nanmean(FD_SST.Fundemental_SST(l));
%                         end
%                     end
%                 end
%                 output.Fundemental_SST = Fundemental_SST;
%             end
%         end

        % *****************************************************************
        % Prepare for outputs
        % *****************************************************************
        for var = 1:numel(var_list)
            eval(['output.',var_list{var},' = ',var_list{var},';']);
        end      

    catch
        disp('error in reading the file ...')
        output = [];
    end
end


function var_list = get_var_list(P)

    if ~isfield(P,'var_list')
        var_list = {'C0_YR','C0_MO','C0_DY','C0_HR','C0_LCL','C0_UTC','C98_UID','C0_LON','C0_LAT',...
                    'C1_DCK','C1_SID','C0_II','C1_PT','C0_SST','C0_OI_CLIM','C0_SI_1','C1_ND'...
                    'C0_SI_2','C0_SI_3','C0_SI_4','QC_FINAL','C0_CTY_CRT','C1_DUPS','C0_IT'};
    else
        var_list = P.var_list;
        
        if all(~ismember(var_list,'QC_FINAL'))
            var_list{end+1} = 'QC_FINAL';
        end
        
        if all(~ismember(var_list,'C0_SI_4'))
            var_list{end+1} = 'C0_SI_4';
        end
        
        if isfield(P,'use_C0_SI_2')
            if P.use_C0_SI_2 == 1
                if all(~ismember(var_list,'C0_SI_2'))
                    var_list{end+1} = 'C0_SI_2';
                end
            end
        end
        
        if isfield(P,'do_connect')
            if all(~ismember(var_list,'C0_CTY_CRT'))
                var_list{end+1} = 'C0_CTY_CRT';
            end
            
            if all(~ismember(var_list,'C1_DCK'))
                var_list{end+1} = 'C1_DCK';
            end
        end
            
        if isfield(P,'buoy_diurnal')
            if all(~ismember(var_list,'C0_LCL'))
                var_list{end+1} = 'C0_LCL';
            end

            if all(~ismember(var_list,'C0_LON'))
                var_list{end+1} = 'C0_LON';
            end

            if all(~ismember(var_list,'C0_LAT'))
                var_list{end+1} = 'C0_LAT';
            end
            
            if all(~ismember(var_list,'C0_MO'))
                var_list{end+1} = 'C0_MO';
            end
        end 
        
        if isfield(P,'C98_UID')
            if all(~ismember(var_list,'C98_UID'))
                var_list{end+1} = 'C98_UID';
            end
        end

        if isfield(P,'do_nighttime_LME')
            if P.do_nighttime_LME == 1
                if all(~ismember(var_list,'C1_ND'))
                    var_list{end+1} = 'C1_ND';
                end
            end
        end
    end
end
