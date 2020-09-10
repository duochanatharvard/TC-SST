% [slope, intercept] = CDC_yorkfit(field_y,field_x,sigma_y,sigma_x,r,dim)
%
% CDC_yorkfit computes linear fitting given uncertainties in both x and y
% directions.
% 
% 
% References:
% D. York, N. Evensen, M. Martinez, J. Delgado "Unified equations for the
% slope, intercept, and standard errors of the best straight line" Am. J.
% Phys. 72 (3) March 2004.
% 
% Original code from: Travis Wiens 2010 travis.mlfx@nutaksas.com
% Matrixrized by Duo Chan 2018 duochan@g.harvard.edu
% 
% Last update: 2018-08-10

function  [slope, intercept] = CDC_yorkfit(field_y,field_x,sigma_y,sigma_x,r,dim)


    % *****************************************************************
    % Parsing inputs
    % *****************************************************************
    if nargin ~= 6,  error('Not enough inputs!!'); end
    if isempty(r), r = 0; end
    
    dim_1 = size(field_y)*0 + 1;   dim_1(dim) = size(field_y,dim); 
    dim_2 = size(field_y);         dim_2(dim) = 1;
    
    if numel(size(field_x)) == 2,
        field_x = repmat(reshape(field_x,dim_1),dim_2);
    end
    
    if numel(sigma_x) == 1,
        sigma_x = repmat(sigma_x,size(field_x));
    elseif numel(size(sigma_x)) == 2,
        sigma_x = repmat(reshape(sigma_x,dim_1),dim_2);
    end

    if numel(sigma_y) == 1,
        sigma_y = repmat(sigma_y,size(field_y));
    elseif numel(size(sigma_y)) == 2,
        sigma_y = repmat(reshape(sigma_y,dim_1),dim_2);
    end
    
    if numel(r) == 1,
        r = repmat(r,size(field_x));
    elseif numel(size(r)) == 2,
        r = repmat(reshape(r,dim_1),dim_2);
    end
    
    l_nan = isnan(field_x) | isnan(field_y);
    field_x (l_nan) = nan;
    field_y (l_nan) = nan;
    sigma_x (l_nan) = nan;
    sigma_y (l_nan) = nan;
    r (l_nan) = nan;

    % *****************************************************************
    % Make initial guess use least square fit
    % *****************************************************************   
    output = CDC_trend(field_y,field_x,dim);
    b = output{1};

    % *****************************************************************
    % Compute weights
    % *****************************************************************  
    omega_x = 1./ sigma_x.^2;
    omega_y = 1./ sigma_y.^2;
    alpha   = sqrt(omega_x .* omega_y);

    % *****************************************************************
    % Start interation
    % ***************************************************************** 
    N_itermax = 10;       % maximum number of interations
    tol       = 1e-15;    % relative tolerance to stop at
    
    ct = 1;
    chg_max = 1;
    
    while (ct <= N_itermax && chg_max > tol),
        
        W = omega_x .* omega_y ./ ...
            (omega_x + repmat(b,dim_1) .^2 .* omega_y - ...
                                2 .* repmat(b,dim_1) .* r .* alpha);
                            
        x_bar = CDC_nansum(W .* field_x, dim) ./ CDC_nansum(W, dim);
        y_bar = CDC_nansum(W .* field_y, dim) ./ CDC_nansum(W, dim);

        u = field_x - repmat(x_bar,dim_1);
        v = field_y - repmat(y_bar,dim_1);

        beta = W .* (u ./ omega_y + repmat(b,dim_1) .* v ./omega_x - ...
                        (repmat(b,dim_1) .* u + v) .* r ./ alpha);
                    
        b_new = CDC_nansum(W .* beta .* v, dim) ./ ...
                                    CDC_nansum(W .* beta .* u, dim);

    	ct = ct + 1;
        chg = abs((b - b_new) ./ b_new);
        chg_max = max(chg(:));
        b = b_new;
    end

    % *****************************************************************
    % Start interation
    % ***************************************************************** 
    a = y_bar - b .* x_bar;
    
    slope = b;
    intercept = a;
    
end