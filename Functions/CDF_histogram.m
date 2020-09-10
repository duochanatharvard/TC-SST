function CDF_histogram(x,y,col,offset,do_single,alpha)

    if nargin < 5
        do_single = 0;
    end
    
    if nargin <6
        alpha = 0.05;
    end

    dx = x(2) - x(1);
    sm = 5;

    for ct = 1:size(y,1)
        h(ct,:) = smooth(hist(y(ct,:),x),sm) / size(y,2);
    end

    hold on;
    for ct = 1:size(y,1)
        pic       = h(ct,:);
        pic_x     = x;
        l         = pic == 0;
        pic(l)    = [];
        pic_x(l)  = [];
        patch([pic_x, fliplr(pic_x)],[pic pic*0]/dx + offset,col(ct,:)*.4+.6,'linest','none','facealpha',.3,'edgecolor',col(ct,:),'linewi',3);
    end

    for ct = 1:size(y,1)
        h(ct,:) = smooth(hist(y(ct,:),x),sm) / size(y,2);
        a = cumsum(h(ct,:));
        if do_single == 0
            l = a > alpha/2 & a < 1-alpha/2;
        elseif do_single == 1 % single side, larger than zero
            l = a > alpha & a < 1;
        else
            l = a > 0 & a < 1-alpha;
        end
        h(ct,~l) = 0; 
    end    
    
    for ct = 1:size(y,1)
        pic       = h(ct,:);
        pic_x     = x;
        l         = pic == 0;
        pic(l)    = [];
        pic_x(l)  = [];
        % patch([pic_x, fliplr(pic_x)],[pic pic*0]/dx + offset,col(ct,:)*.4+.6,'linest','none','facealpha',.7);
        patch([pic_x, fliplr(pic_x)],[pic pic*0]/dx + offset,col(ct,:),'linest','none','facealpha',.5);
    end

    for ct = 1:size(y,1)
        h(ct,:) = smooth(hist(y(ct,:),x),sm) / size(y,2);
        a = cumsum(h(ct,:));
        if do_single == 0
            l = a > 0.25 & a < 0.75;
        elseif do_single == 1 % single side, larger than zero
            l = a > alpha & a < 1;
        else
            l = a > 0 & a < 1-alpha;
        end
        h(ct,~l) = 0; 
    end    
    
    for ct = 1:size(y,1)
        pic       = h(ct,:);
        pic_x     = x;
        l         = pic == 0;
        pic(l)    = [];
        pic_x(l)  = [];
        % patch([pic_x, fliplr(pic_x)],[pic pic*0]/dx + offset,col(ct,:),'linest','none','facealpha',.5);
    end

    for ct = 1:size(y,1)
        h(ct,:) = smooth(hist(y(ct,:),x),sm) / size(y,2);
    end

    hold on;
    for ct = 1:size(y,1)
        pic       = h(ct,:);
        pic_x     = x;
        l         = pic == 0;
        pic(l)    = [];
        pic_x(l)  = [];
        plot(pic_x,[pic]/dx + offset,'color',col(ct,:)*.8,'linewi',3);
    end
end