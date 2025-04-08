% COMPUTEPROBDENSITY Compute the probability density of a multivariate normal distribution.
%
%   net = computeProbDensity(net, x, i)
%
%   This function calculates the probability density of a multivariate 
%   normal distribution for a given data point `x` and updates the 
%   corresponding fields in the `net` structure. The computation is 
%   performed differently depending on whether rank-one updates are used.
%
%   Inputs:
%       net - A structure containing the parameters of the multivariate 
%             normal distribution, including means, covariances, and 
%             other related fields.
%       x   - A row vector representing the data point for which the 
%             probability density is to be computed.
%       i   - An index specifying which component of the distribution 
%             to use for the computation.
%
%   Outputs:
%       net - The updated structure with the computed probability density 
%             and related values stored in the appropriate fields.
%
%   Notes:
%       - If `net.useRankOne` is true, the computation uses a rank-one 
%         update approach for efficiency.
%       - If `net.useRankOne` is false, the computation involves 
%         Cholesky decomposition of the covariance matrix.
%       - The function assumes that the covariance matrices are positive 
%         definite and symmetric.
%
%   See also: computeChol, wrapValues
function net = computeProbDensity(net, x, i) %#codegen
    coder.inline('always');
    diff = x - net.means(i, :);
    dim = net.dimension;
    twopi = 2 * pi;
    if net.useRankOne
        diff = x - net.means(i, :);
        net.distances(i) = diff * net.invCovs(:, :, i) * diff';
        regularization = ((2 * pi) .^ (dim / 2.0)) * sqrt(net.logDets(i));
        net.logLikes(i) = wrapValues(exp(-0.5 * net.distances(i)) / regularization);
    else
        [L, diagL, net.covs(:, :, i)] = computeChol(net.covs(:, :, i));
        xRinv = diff / L;
        net.distances(i) = sum(xRinv .^ 2, 2);
        net.logLikes(i) = -0.5 * ( ...
            net.distances(i) + 2 * sum(log(diagL)) + dim * log(twopi));
    end
end


