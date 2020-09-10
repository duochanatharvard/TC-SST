% col = b2rCD(num,start_from_white,name)
% 
% b2rCD returns blue (cold) to red (warm) colormap
% col = colormap_CD([ 0.45 0.7; 0.08 0.95],[1 .35],[0 0],num);
%
% Can be modified to be other maps, or using argument "name": 
%
% 'precip': yellow (dry) to blue (wet)
% col = colormap_CD([  0.15 0.08; 0.5 0.7],[1 .3],[0 0], num);
%
% Last update: 2018-08-14

function col = b2rCD(num,start_from_white,name)
    
    % *********************************************************************
    % Parse input arguments
    % ********************************************************************* 
    if ~exist('num','var')  num = 6; end
    if ~exist('name','var') name = 'temp'; end
    if strcmp(name,'')      name = 'temp'; end
    if ~exist('start_from_white','var') start_from_white = 1; end
    if isempty(start_from_white)      start_from_white = 1; end

    % *********************************************************************
    % Generate colormap
    % *********************************************************************
    if start_from_white == 1,
        b1 = 1;
    else
        shft = (num - 10)/(30-10) *0.075;
        shft(shft > 0.075) = 0.075;
        shft(shft < 0) = 0;
        b1 = 0.925 + shft;
    end
    
    switch name,
        case 'temp',
            col = colormap_CD([ 0.45 0.7; 0.2 0.95],[b1 .35],[0 0],num);
        case 'precip',
            col = colormap_CD([  0.15 0.08; 0.5 0.7],[b1 .3],[0 0], num);
    end

end