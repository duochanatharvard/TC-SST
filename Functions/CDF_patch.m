% CDF_patch(x,y,col,a,P)
function h = CDF_patch(x,y,col,a,P)

    if nargin<4
        a = 0.05;
    end

    if nargin<5
        alp = 0.5;
    else
        if isfield(P,'alpha')
          alp = P.alpha;
        else
          alp = 0.5;
        end
    end
    
    if 1,
        for i = 1:size(y,2)
            up(i) = quantile(y(:,i),1-a/2);
            low(i) = quantile(y(:,i),a/2);
        end
    else
        s = CDC_std(y,1);
        up = nanmean(y,1) + s * abs(norminv(a/2));
        low = nanmean(y,1) - s * abs(norminv(a/2));
    end

    logic = ~isnan(up);
    x = x(logic);
    up = up(logic);
    low = low(logic);

    h = patch([x fliplr(x)],[up fliplr(low)],col);
    alpha(h,alp)
    set(h,'linest','none')

end
