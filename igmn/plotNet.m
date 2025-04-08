% PLOTNET Plots 2D and 3D Gaussian distributions from a network
%
%   H = PLOTNET(NET) plots the Gaussian distributions specified by 
%   NET.means and NET.covs. The distributions are visualized as ellipses 
%   (in 2D) or ellipsoids (in 3D). By default, the distributions are 
%   plotted in the current axes. H is the graphics handle to the plotted 
%   ellipse or ellipsoid.
%
%   H = PLOTNET(NET, 'sd', SD) uses SD as the standard deviation along 
%   the major and minor axes (larger SD => larger ellipse). By default, 
%   SD = 1. Note: 
%     * For 2D distributions, SD=1.0 and SD=2.0 cover ~39% and ~86% of 
%       the total probability mass, respectively. 
%     * For 3D distributions, SD=1.0 and SD=2.0 cover ~19% and ~73% of 
%       the total probability mass, respectively.
%
%   H = PLOTNET(NET, 'sd', SD, 'npts', NPTS) plots the ellipse or 
%   ellipsoid with a resolution of NPTS. Ellipsoids are generated on an 
%   NPTS x NPTS mesh (see SPHERE for more details). By default, 
%   NPTS = 50 for ellipses, and 20 for ellipsoids.
%
%   H = PLOTNET(NET, 'sd', SD, 'npts', NPTS, 'ax', AX) adds the plot to 
%   the axes specified by the axis handle AX. If AX is not provided, a 
%   new figure and axes are created.
%
%   INPUTS:
%       NET   - A structure containing the Gaussian network parameters:
%               * NET.means: Mean vectors of the Gaussian components.
%               * NET.covs: Covariance matrices of the Gaussian components.
%               * NET.invCovs: Inverse covariance matrices (if applicable).
%               * NET.nc: Number of Gaussian components.
%               * NET.useRankOne: Boolean indicating whether to use rank-one 
%                 covariance approximation.
%       SD    - (Optional) Standard deviation for scaling the ellipses or 
%               ellipsoids. Default is 1.
%       NPTS  - (Optional) Number of points for plotting resolution. Default 
%               is 50 for 2D and 20 for 3D.
%       AX    - (Optional) Axes handle for plotting. If not provided, a new 
%               figure and axes are created.
%
%   OUTPUTS:
%       H     - Graphics handle to the plotted ellipse or ellipsoid. If no 
%               output is specified, the handle is not returned.
%
%   EXAMPLES:
%       % Example 1: Plot a 2D Gaussian distribution
%       net.means = [0, 0];
%       net.covs = eye(2);
%       net.nc = 1;
%       net.useRankOne = false;
%       plotNet(net);
%
%       % Example 2: Plot a 3D Gaussian distribution with custom SD and NPTS
%       net.means = [0, 0, 0];
%       net.covs = eye(3);
%       net.nc = 1;
%       net.useRankOne = false;
%       plotNet(net, 'sd', 2, 'npts', 30);
%
%   See also SPHERE.
function [h] = plotNet(net, varargin)
    parser = inputParser;
    
    addOptional(parser, 'sd', 1);
    addOptional(parser, 'npts', []);
    addOptional(parser, 'ax', []);
    
    parse(parser, varargin{:});
    
    sd = parser.Results.sd;
    npts = parser.Results.npts;
    ax = parser.Results.ax;

    if isempty(ax)
       figure; ax = gca;
    end
    
    set(ax, 'nextplot', 'add');
    
    for i = 1:net.nc
        mean = net.means(i, :);
        if net.useRankOne
            cov = inv(net.invCovs(:, :, i))'; 
        else 
            cov = net.covs(:, :, i)'; 
        end
        switch numel(mean)
            case 2, h = show2d(mean, cov, sd, npts, ax);
            case 3, h = show3d(mean, cov, sd, npts, ax);
            otherwise 
                error('Unsupported dimensionality');
        end
    end
    if nargout == 0, clear h; end
end

% SHOW2D Plots a 2D Gaussian distribution as an ellipse.
%
%   h = SHOW2D(mean, cov, sd, npts, ax) plots a 2D Gaussian distribution
%   represented by its mean and covariance matrix as an ellipse. The
%   ellipse is scaled by the standard deviation (sd) and plotted with a
%   specified number of points (npts) on the given axes (ax).
%
%   Inputs:
%       mean  - A 2-element vector specifying the mean of the Gaussian
%               distribution [mean_x, mean_y].
%       cov   - A 2x2 covariance matrix of the Gaussian distribution.
%       sd    - A scalar specifying the scaling factor for the standard
%               deviation.
%       npts  - (Optional) Number of points used to draw the ellipse.
%               Default is 50.
%       ax    - (Optional) Handle to the axes where the ellipse will be
%               plotted. If not provided, the current axes will be used.
%
%   Output:
%       h     - Handle to the plotted line object representing the ellipse.
%
%   Example:
%       mean = [0, 0];
%       cov = [1, 0.5; 0.5, 1];
%       sd = 2;
%       figure;
%       ax = gca;
%       show2d(mean, cov, sd, 100, ax);
%
%   Notes:
%       - The function uses eigenvalue decomposition to compute the
%         orientation and scaling of the ellipse based on the covariance
%         matrix.
%       - The ellipse is centered at the specified mean and scaled by
%         the given standard deviation.
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
    h = plot(bp(1, :), bp(2, :), '-', 'parent', ax, 'LineWidth', 2);
end

% SHOW3D Plots a 3D ellipsoid representing a Gaussian distribution.
%
%   h = SHOW3D(mean, cov, sd, npts, ax) creates a 3D ellipsoid centered at
%   the specified mean, with the shape determined by the covariance matrix
%   (cov), and scaled by the standard deviation (sd). The ellipsoid is
%   plotted on the specified axes (ax) using a sphere with npts points.
%
%   Inputs:
%       mean - A 3-element vector specifying the center of the ellipsoid.
%       cov  - A 3x3 covariance matrix defining the shape of the ellipsoid.
%       sd   - A scalar specifying the scaling factor for the ellipsoid.
%       npts - (Optional) Number of points used to generate the sphere.
%              Default is 20.
%       ax   - Handle to the axes where the ellipsoid will be plotted.
%
%   Output:
%       h - Handle to the surface object representing the ellipsoid.
%
%   Notes:
%       - If the covariance matrix has negative eigenvalues, a warning is
%         displayed, and the negative eigenvalues are clamped to zero.
%       - The function uses the eigendecomposition of the covariance matrix
%         to determine the orientation and scaling of the ellipsoid.
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
