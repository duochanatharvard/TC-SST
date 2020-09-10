% CDF_boundaries(varargin)
%  
% CDF_boundaries draw the boundaries of countries in the world, provinces
% in China, or states in the U.S.
% 
% Customizable input argument:
%  - "type": {"China", "USA"}         default: "countries"
%  - "do_m_map": {1}                  default: 0
%  - "do_fill": {1}                   default: 0
%  - "color":  rgb                    default: black
%  - "linewi":                        default: 1
%  - "linest":                        default: '-'
%  - "gridsize"                       default: 1
%  When do_fill is 1, argument color can take the value of "colors", which 
%  retuens colors infill countries or states. It can also take in a colormap
%  that indicates colors individual countries or states.

% Last update: 2018-08-09

function CDF_boundaries(varargin)

    % *********************************************************************
    % Parse input argument
    % ********************************************************************* 
    para = reshape(varargin(:),2,numel(varargin)/2)';
    for ct = 1 : size(para,1)
        temp = para{ct,1};
        temp = lower(temp);
        temp(temp == '_') = [];
        para{ct,1} = temp;
    end

    % *********************************************************************
    % Read the coast lines 
    % ********************************************************************* 
    if nnz(ismember(para(:,1),'gridsize')) == 0
        gridsize = nan;
    else
        gridsize = para{ismember(para(:,1),'gridsize'),2};
    end

    if nnz(ismember(para(:,1),'type')) == 0
        type = 'countries';
    else
        type = para{ismember(para(:,1),'type'),2};
    end

    if strcmp(type,'countries')
        map_path1 = shaperead(['world_adm0.shx']);
        map_X1    = [map_path1(:).X];
        map_Y1    = [map_path1(:).Y];

    elseif strcmp(type,'China')
        map_path2 = shaperead(['bou2_4p.shp']);
        map_X1    = [map_path2(:).X];
        map_Y1    = [map_path2(:).Y];

    elseif strcmp(type,'USA')
        states = geoshape(shaperead('usastatehi', 'UseGeoCoords', true));
        map_X1 = [];
        map_Y1 = [];
        for i=1:51
            map_X1 = [map_X1 NaN states(i).Longitude];
            map_Y1 = [map_Y1 NaN states(i).Latitude];
        end
    end
    
    if ~isnan(gridsize)
        map_X1 = map_X1./gridsize + .5;
        map_Y1 = (map_Y1+90)./gridsize + .5;
        shft   = 360./gridsize;
    else
        shft   = 360;
    end
   
    % *********************************************************************
    % Whether to use m_map toolbox
    % ********************************************************************* 
    if nnz(ismember(para(:,1),'dommap')) == 0
        do_m = ' ';
    else
        do_m = 'm_';
    end

    % *********************************************************************
    % Set Parameters
    % ********************************************************************* 
    if nnz(ismember(para(:,1),'dofill')) == 0
        do_fill = 0;
    else
        do_fill = para{ismember(para(:,1),'dofill'),2};
    end

    if nnz(ismember(para(:,1),'linewi')) == 0
        linewi = 1;
    else
        linewi = para{ismember(para(:,1),'linewi'),2};
    end

    if nnz(ismember(para(:,1),'linest')) == 0
        linest = '-';
    else
        linest = para{ismember(para(:,1),'linest'),2};
    end

    if nnz(ismember(para(:,1),'color')) == 0
        col = [1 1 1]*0;
    else
        col = para{ismember(para(:,1),'color'),2};
    end
   
   
    % *********************************************************************
    % To plot the filled lines
    % ********************************************************************* 
    hold on;
    if do_fill == 1
        
        if strcmp(col,'colors')
            num_c = 100;
            col = CDF_distinguishable_colors(num_c);
            flag = 1;
        elseif size(col,1) > 1
            num_c = size(col,1);
            flag = 1;
        else
            flag = 0;
        end
        
        nan_list = [0 find(isnan(map_X1))];
        for i = 1:numel(nan_list)-1
            temp_x = map_X1(nan_list(i)+1 : nan_list(i+1)-1);
            temp_y = map_Y1(nan_list(i)+1 : nan_list(i+1)-1);
            if flag == 1
                col_id = rem(i-0.5,num_c)+0.5;
                eval([do_m,'patch(temp_x,temp_y,col(col_id,:),''linest'',''none'');']);
                eval([do_m,'patch(temp_x-shft,temp_y,col(col_id,:),''linest'',''none'');']);
                eval([do_m,'patch(temp_x+shft,temp_y,col(col_id,:),''linest'',''none'');']);
            else
                eval([do_m,'patch(temp_x,temp_y,col,''linest'',''none'');']);
                eval([do_m,'patch(temp_x+shft,temp_y,col,''linest'',''none'');']);
                eval([do_m,'patch(temp_x-shft,temp_y,col,''linest'',''none'');']);
            end
        end
        
    else   % do_fill == 0
        
        eval([do_m,'plot(map_X1,map_Y1,''color'',col,'...
            '''linewidth'',linewi,''linest'',linest);']);
        eval([do_m,'plot(map_X1-shft,map_Y1,''color'',col,'...
            '''linewidth'',linewi,''linest'',linest);']);
        eval([do_m,'plot(map_X1+shft,map_Y1,''color'',col,'...
            '''linewidth'',linewi,''linest'',linest);']);
    end
end