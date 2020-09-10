% CDF_scatter_legend(in_name,in_st,in_col,mode_in,varargin)
% 
% - in_name: namelist of the scatters
% - in_st: the style of legend                         default: boxes
% - in_col: color, when missing                        default: black
% 
% - mode_in: 
%    contains three variable: [mode, num, write_direction]
%        - mode: 1 (default): verticle, colums  0: horizonal, row
%        - num:  1 (default): how many columns in total would you want?
%        - write_direction: 1 (default): vertical  others: horizontal
% 
% Customizable input argument:
%  - "edgecol":  color of edge                         default: 'k'
%  - "linewi":   width of width                        default: 2
%  - "mksize":   markersize                            default: 10
%  - "fontsize':                                       default: 12
% 
% Last update: 2018-08-20 

function CDF_scatter_legend(in_name,in_st,in_col,mode_in,varargin)

    % *********************************************************************
    % Parse input argument
    % *********************************************************************
    if ~exist('in_st','var')
        in_st = [];
    end

    if isempty(in_st),
        in_st = [];
    else
        if max(size(in_name)) == 1,
            in_st = repmat(in_st,numel(in_name),1);
        end
    end
    
    if ~exist('in_col','var')
        in_col = repmat([0 0 0],numel(in_name),1);
    end

    if isempty(in_col)
        in_col = repmat([0 0 0],numel(in_name),1);
    else
        if size(in_col,1) == 1,
            in_col = repmat(in_col,numel(in_name),1);
        end
    end

    if ~exist('mode_in','var')
        mode_in = [1 1 1];
    end
    
    if isempty(mode_in),
        mode_in = [1 1 1];
    elseif numel(mode_in) ~=3,
        error ('Diemention of mode_in is incorrect!')
    end
    
    mode = mode_in(1);
    num  = mode_in(2);
    write_direction = mode_in(3);
    
    if numel(varargin) == 1,
        varargin = varargin{1};
    end
    para = reshape(varargin(:),2,numel(varargin)/2)';
    for ct = 1 : size(para,1)
        temp = para{ct,1};
        temp = lower(temp);
        temp(temp == '_') = [];
        para{ct,1} = temp;
    end

    % *********************************************************************
    % Assign Parameters
    % ********************************************************************* 

    if nnz(ismember(para(:,1),'edgecol')) == 0,
        edgecol = 'k';
    else
        edgecol = para{ismember(para(:,1),'edgecol'),2};
    end

    if nnz(ismember(para(:,1),'linewi')) == 0,
        linewi = 2;
    else
        linewi = para{ismember(para(:,1),'linewi'),2};
    end

    if nnz(ismember(para(:,1),'mksize')) == 0,
        mksize = 10;
    else
        mksize = para{ismember(para(:,1),'mksize'),2};
    end

    if nnz(ismember(para(:,1),'fontsize')) == 0,
        ftsize = 10;
    else
        ftsize = para{ismember(para(:,1),'fontsize'),2};
    end


    % *********************************************************************
    % Generate figures
    % *********************************************************************

    num_x = num;
    num_y = (numel(in_name) / num_x);
    if num_y ~= fix(num_y)
        num_y = fix(num_y)+1;
    end
    
    for i = 1:numel(in_name)
        if write_direction == 1,
            [y,x] = ind2sub([num_y,num_x],i);
        else
            [x,y] = ind2sub([num_x,num_y],i);
        end
        
        if mode == 1 || strcmp(mode,'vertical'),
            if ~isempty(in_st)
                plot(x,-y,in_st(i),'color',edgecol,'linewi',linewi, ...
                    'markerfacecolor',in_col(i,:),'markersize',mksize);
                text(x + 0.09, - y, in_name{i},...
                    'fontsize',ftsize,'fontweight','bold');
            else
                patch([-0.2 0.2 0.2 -0.2]/2 + x,[-0.2 -0.2 0.2 0.2] - y, ...
                        in_col(i,:),'linest','none');
                text(x + 0.14,- y,in_name{i}, ...
                    'fontsize',ftsize,'fontweight','bold');
            end
            
        else
            if ~isempty(in_st)
                plot(y,-x,in_st(i),'color',edgecol,'linewi',linewi, ...
                    'markerfacecolor',in_col(i,:),'markersize',mksize);
                text(y+0.09 , -x, in_name{i}, ...
                    'fontsize',ftsize,'fontweight','bold');
            else
                patch([-0.2 0.2 0.2 -0.2]/2 + y,[-0.2 -0.2 0.2 0.2] - x, ...
                    in_col(i,:),'linest','none');
                text(y + 0.14, -x, in_name{i}, ...
                    'fontsize',ftsize,'fontweight','bold');
            end 
        end
    end
    
    if ~isempty(in_st)
        xlim([0.95 num_x+0.3])
        ylim([-num_y-1 0])
    else
        xlim([0.7 num_x+0.3])
        ylim([-num_y-1 0])
    end
    
    axis off
end
    