% updateComponents Updates the components of the network based on input data.
%
%   net = updateComponents(net, x)
%
%   This function updates the parameters of a network structure `net` 
%   using the input data `x`. It modifies the means, covariances, priors, 
%   and other internal parameters of the network based on the posterior 
%   probabilities and the input data.
%
%   Inputs:
%       net - A structure representing the network, containing fields such as:
%             - vs: A vector of component counts.
%             - sp: A vector of posterior sums.
%             - spu: A vector of posterior sums (used for updates).
%             - means: A matrix of component means.
%             - invCovs: A matrix of inverse covariances.
%             - logDets: A vector of log determinants of covariances.
%             - priors: A vector of component priors.
%             - posteriors: A vector of posterior probabilities.
%             - minCov: A minimum covariance value to ensure numerical stability.
%             - dimension: Dimensionality of the data.
%             - nc: Number of components.
%             - useRankOne: A flag indicating whether to use rank-one updates.
%             - covs: A matrix of component covariances.
%       x   - A vector representing the input data point.
%
%   Outputs:
%       net - The updated network structure with modified fields:
%             - Updated means, covariances, priors, and other parameters.
%
%   Notes:
%       - If `useRankOne` is true, the function performs rank-one updates 
%         and downdates for the inverse covariance matrices.
%       - If `useRankOne` is false, the function updates the covariance 
%         matrices directly.
%       - The function ensures numerical stability by adding `minCov` to 
%         the covariance updates.
%
%   Example:
%       net = updateComponents(net, x);
%
%   See also: Other related functions in the IGMN framework.
function net = updateComponents(net, x) %#codegen
    net.vs = net.vs + 1;
    net.sp = net.sp + net.posteriors;
    net.spu = net.spu + net.posteriors;
    means = permute(net.means, [3, 2, 1]);
    lr = permute(net.posteriors ./ net.sp, [3, 1, 2]);
    diff = (x - means) .* lr;
    means = means + diff;
    updateDiff = x - means;
    if net.useRankOne
        lrInv = (1.0 - lr);
        updateDiff = updateDiff .* sqrt(lr);
        invCovs = net.invCovs ./ lrInv;

        % Rank-one update
        numerator = sum(invCovs .* updateDiff, 2);
        denominator = 1 + sum(updateDiff .* pagectranspose(numerator), 2);
        partial = bsxfun(@mtimes, numerator,  pagetranspose(numerator));
        invCovs = invCovs - partial ./ denominator;
        logdet = net.logDets .* ...
            (squeeze(lrInv)' .^ net.dimension) .* squeeze(denominator)';

        % Rank-one downdate
        numerator = sum(invCovs .* diff, 2);
        denominator = 1 - sum(diff .* pagectranspose(numerator), 2);
        partial = bsxfun(@mtimes, numerator, pagetranspose(numerator));
        net.invCovs = invCovs + partial ./ denominator + net.minCov;
        net.logDets(1:end) = wrapValues(logdet .* squeeze(denominator)');
    else
        deltaMUMult = pagemtimes(permute(diff, [2 1 3]), diff);
        diffMultTemp = pagemtimes(permute(updateDiff,[2 1 3]), updateDiff);
        diffMult = bsxfun(@minus, diffMultTemp, net.covs);
        wightedDiff = bsxfun(@plus, pagemtimes(lr, diffMult), net.minCov);
        deltaSum = bsxfun(@minus, net.covs, deltaMUMult);
        net.covs = bsxfun(@plus, deltaSum, wightedDiff); 
    end
    net.means = reshape(means, net.dimension, net.nc)';
    net.priors = bsxfun(@rdivide, net.sp, sum(net.sp, 2));
end