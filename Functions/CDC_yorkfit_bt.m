% [slope, inter, slope_member, inter_member] =  ...
%                   CDC_yorkfit_bt(field_y,field_x,sigma_y,sigma_x,r,dim,N,P)
% 
% output variables are:
% - output:     variance
% - l_effect:   effective sample size
% - out_member: bootstrap member of variance
% - out_std:    std of bootstrapped variance
%
% Other input options:
% P.mute_output
% P.N_block
% 
% CDC_yorkfit_bt computes the linear regression: y = ax + b
% with uncertainty in both x and y in certain dimension of matrices
% and perform bootstrap to estimate the uncertainty of variance.
% Bootstrapped data are corrected to account for the underestimation due to
% re-sampling.
% 
% Again, in these fitting related functions, dimensionality is not omittable!
% 
% Last update: 2020-03-05

function [slope, inter, slope_member, inter_member] =  ...
            CDC_yorkfit_bt(field_y,field_x,sigma_y,sigma_x,r,dim,N,varargin)

    % *****************************************************************
    % Parsing inputs
    % *****************************************************************
    if nargin < 7,   error('Not enough inputs!!'); end
    if nargin == 8,  P = varargin{1};              end
    if isempty(r), r = 0; end
    
    dim_1 = size(field_y)*0 + 1;   dim_1(dim) = size(field_y,dim); 
    dim_2 = size(field_y);         dim_2(dim) = 1;
    
    if numel(size(field_x)) == 2
        field_x = repmat(reshape(field_x,dim_1),dim_2);
    end
    
    if numel(sigma_x) == 1
        sigma_x = repmat(sigma_x,size(field_x));
    elseif numel(size(sigma_x)) == 2
        sigma_x = repmat(reshape(sigma_x,dim_1),dim_2);
    end

    if numel(sigma_y) == 1
        sigma_y = repmat(sigma_y,size(field_y));
    elseif numel(size(sigma_y)) == 2
        sigma_y = repmat(reshape(sigma_y,dim_1),dim_2);
    end
    
    if numel(r) == 1
        r = repmat(r,size(field_x));
    elseif numel(size(r)) == 2
        r = repmat(reshape(r,dim_1),dim_2);
    end

    if isfield(P,'N_block')
        N_block =  P.N_block;
    else
        N_block = 1;
    end

    % **************************************************
    % Compute york fit
    % **************************************************
    [slope, inter] = CDC_yorkfit(field_y,field_x,sigma_y,sigma_x,r,dim);
    
    % **************************************************
    % Bootstrap for the order 
    % **************************************************
    rng(0);
    [~,boot_sample] = bootstrp(N, @(x) [mean(x)], [1:fix(size(field_y,dim)/N_block)+1]);
    
    % **************************************************
    % Re-sample and estimate variances
    % **************************************************
    slope_member = nan([size(slope) N]);
    inter_member = nan([size(inter) N]);
    dim_2 = numel(size(slope_member));
    for ct = 1:N

        if exist('P','var'),
            if isfield(P,'mute_output'),
                if P.mute_output == 1,
                else
                    if rem(ct,round(N/10)) == 0,  disp(num2str(ct)); end
                end
            else
                if rem(ct,round(N/10)) == 0,  disp(num2str(ct)); end
            end
        else
            if rem(ct,round(N/10)) == 0,  disp(num2str(ct)); end
        end
        
        order = repmat(boot_sample(:,ct)'*N_block-N_block,N_block,1);
        order = order + repmat([1:N_block]',1,size(boot_sample,1));
        order = order(:);
        order(order > size(field_y,dim)) = [];

        field_yy = CDC_subset(field_y,dim,order);
        field_xx = CDC_subset(field_x,dim,order);
        sigma_yy = CDC_subset(sigma_y,dim,order);
        sigma_xx = CDC_subset(sigma_x,dim,order);
        rr       = CDC_subset(r      ,dim,order);

        [slope_temp, inter_temp] = ...
            CDC_yorkfit(field_yy,field_xx,sigma_yy,sigma_xx,rr,dim);
        slope_member = CDC_assign(slope_member,slope_temp,dim_2,ct);
        inter_member = CDC_assign(inter_member,inter_temp,dim_2,ct);
    end
 
    % **************************************************
    % Correct for underestimation
    % ************************************************** 
    rep = size(slope_member);
    rep(1:dim_2-1) = 1;
    med = quantile(slope_member,0.5,dim_2);
    % slope_member = slope_member + repmat(slope - med,rep);
    med = quantile(inter_member,0.5,dim_2);
    % inter_member = inter_member + repmat(inter - med,rep);
    
    slope_member = squeeze(slope_member);
    inter_member = squeeze(inter_member);
    
end