%A Simple function that makes a 2D histgram developed by Sisi Ma (sisima[at]rci.rutgers.edu )
% count=hist2d(data, RAN)
% Input:    data: two cols, x value; y value
%             xrange: range and bins for x value (edges)
%             yrange: range and bins for y value (edges)
%Output: Count of a specifice (x,y) bin combination; 
%       Suggested visualizing tool: I like to use imagesc; bar3 will work fine
%       too; have to change axis label though


function count = hist2d(data, RAN)

    for i = 1:size(data,2)
        range = [RAN(i,1):RAN(i,2):RAN(i,3)];
        LV(i) = size(range,2) - 1;
        JG = range(2)-range(1);
        DATA(:,i) = fix((data(:,i) - range(1))/JG) + 1;
        DATA(DATA(:,i) > LV(i),i) = NaN;
        DATA(DATA(:,i) < 1,i) = NaN;
    end

    logic = all(isnan(DATA) == 0,2);
    [DATA_uni,~,J] = unique(DATA(logic,:),'rows');

    count = zeros(LV);
    if (size(data,2) == 2)
        for i = 1:size(DATA_uni,1)
            count(DATA_uni(i,1),DATA_uni(i,2)) = nnz(J == i);
        end
    else
        for i = 1:size(DATA_uni,1)
            count(DATA_uni(i,1),DATA_uni(i,2),DATA_uni(i,3)) = nnz(J == i);
        end
    end
    
end

    
    