% PRUNECOMPONENTS Remove spurious components from the network.
%
%   net = pruneComponents(net) removes components from the network `net`
%   that are considered spurious based on specific criteria. The function
%   updates the network structure by pruning components with low variance
%   and insufficient support, and adjusts the network parameters accordingly.
%
%   Input:
%       net - A structure representing the network, containing fields such as:
%           - vs: Variance of the components.
%           - vMin: Minimum variance threshold.
%           - sp: Support of the components.
%           - spMin: Minimum support threshold.
%           - nc: Number of components.
%           - priors: Prior probabilities of the components.
%           - means: Mean values of the components.
%           - invCovs: Inverse covariance matrices (if useRankOne is true).
%           - logDets: Log determinants of covariance matrices (if useRankOne is true).
%           - covs: Covariance matrices (if useRankOne is false).
%           - spu: Support upper bound of the components.
%           - posteriors: Posterior probabilities of the components.
%           - distances: Distances of the components.
%           - logLikes: Log-likelihoods of the components.
%           - useRankOne: Boolean indicating whether rank-one updates are used.
%           - gamma: A scaling factor for support adjustment.
%
%   Output:
%       net - The updated network structure with spurious components removed
%             and parameters adjusted.
%
%   Notes:
%       - Components are considered spurious if their variance (`vs`) is
%         below `vMin` or their support (`sp`) is below `spMin`.
%       - If the number of components exceeds a threshold determined by
%         `exp(net.nc/(1 + net.nc)) > exp(1) * net.gamma`, additional
%         adjustments are made to the support (`sp`) and priors.
%       - The function handles both cases where rank-one updates are used
%         (`useRankOne` is true) and where full covariance matrices are used
%         (`useRankOne` is false).
function net = pruneComponents(net) %#codegen
    indexes = net.vs > net.vMin & net.sp < net.spMin;
    net.nc = net.nc - sum(indexes, 'all');
    net.priors(indexes) = [];
    net.means(indexes, :) = [];
    if net.useRankOne
        net.invCovs(:, :, indexes) = [];
        net.logDets(indexes) = [];
    else
        net.covs(:, :, indexes) = [];
    end
    net.vs(indexes) = [];
    net.sp(indexes) = [];
    net.spu(indexes) = [];
    net.posteriors(indexes) = [];
    net.distances(indexes) = [];
    net.logLikes(indexes) = [];

    if exp(net.nc/(1 + net.nc)) > exp(1) * net.gamma
        indexes = (net.vs > net.vMin) & (net.sp >= net.spMin);
        spuindexes = indexes & (net.spu >= net.spMin);
        if any(spuindexes, 'all')
            net.sp(spuindexes) = ...
                max(net.gamma .* net.sp(spuindexes), igmn.minimum);
            net.priors = net.sp ./ sum(net.sp, 2);
        end
        net.vs(indexes) = 0; net.spu(indexes) = 0;
    end
end
