function [h] = plotNet(net, varargin)
    % PLOT plots 2-d and 3-d Gaussian distributions
    %
    %   H = PLOT(net) plots the distribution specified by 
    %   self.means and self.covs. The distribution is plotted as 
    %   an ellipse (in 2-d) or an ellipsoid (in 3-d). By default, 
    %   the distributions are plotted in the current axes. H is 
    %   the graphics handle to the plotted ellipse or ellipsoid.
    %
    %   h = PLOT(net, 'sd', SD) uses SD as the standard deviation 
    %   along the major and minor axes (larger SD => larger 
    %   ellipse). By default, SD = 1. Note: 
    %     * For 2-d distributions, SD=1.0 and SD=2.0 cover ~ 39% 
    %       and 86%  of the total probability mass, respectively. 
    %     * For 3-d distributions, SD=1.0 and SD=2.0 cover ~ 19% 
    %       and 73% of the total probability mass, respectively.
    %  
    %   h = PLOT(net, 'sd', SD, 'npts', NPTS) plots the ellipse or 
    %   ellipsoid  with  a resolution of NPTS (ellipsoids are 
    %   generated on an  NPTS x NPTS mesh; see SPHERE for more 
    %   details). By default,  NPTS = 50 for ellipses, and 20 for 
    %   ellipsoids.
    %
    %   h = self.PLOT('sd', SD, 'npts', NPTS, 'ax', AX) adds the 
    %   plot to the axes specified by the axis handle AX.
    checkAx = @(ax) ~(isscalar(ax) && ...
    ishandle(ax) && strcmp(get(ax,'type'), 'axes'));
    
    parser = inputParser;
    
    addOptional(parser, 'sd', 1);
    addOptional(parser, 'npts', []);
    addOptional(parser, 'ax', gca, checkAx);
    
    parse(parser, varargin{:});
    
    sd = parser.Results.sd;
    npts = parser.Results.npts;
    ax = parser.Results.ax;
    
    set(ax, 'nextplot', 'add');
    
    for i = 1:net.nc
        mean = net.means(i, :);
        cov = net.covs(:, :, i)';
        switch numel(mean)
            case 2, h = show2d(mean, cov, sd, npts, ax);
            case 3, h = show3d(mean, cov, sd, npts, ax);
            otherwise 
                error('Unsupported dimensionality');
        end
    end
    if nargout == 0, clear h; end
end


function h = show2d(mean, cov, sd, npts, ax)
    if isempty(npts), npts = 50; end
    % plot the gaussian fits
    tt = linspace(0, 2 * pi, npts)';
    x = cos(tt); 
    y = sin(tt);
    ap = [x(:) y(:)]';
    [v, d] = eig(cov); 
    d = (sd * sqrt(d)) / 2; % convert variance to sd*sd
    bp = (v * d * ap) + repmat(mean', 1, size(ap, 2)); 
    h = plot(bp(1, :), bp(2, :), '-', 'parent', ax);
end

function h = show3d(mean, cov, sd, npts, ax)
    if isempty(npts), npts = 20; end
    [x,y,z] = sphere(npts);
    ap = [x(:) y(:) z(:)]';
    [v, d] = eig(cov); 
    if any(d(:) < 0)
        fprintf('warning: negative eigenvalues\n');
        d = max(d, 0);
    end
    d = sd * sqrt(d); % convert variance to sd*sd
    bp = (v * d * ap) + repmat(mean', 1, size(ap, 2)); 
    xp = reshape(bp(1, :), size(x));
    yp = reshape(bp(2, :), size(y));
    zp = reshape(bp(3, :), size(z));
    h = surf(ax, xp, yp, zp);    
end