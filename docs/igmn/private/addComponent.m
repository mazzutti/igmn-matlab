% addComponent Adds a new component to the network.
%
%   net = addComponent(net, x) adds a new component to the given network
%   structure `net` using the input data point `x`. This function updates
%   the network's parameters, including the means, priors, and covariance
%   matrices, to account for the new component.
%
%   Inputs:
%       net - A structure representing the network. It contains fields
%             such as means, priors, covariances, and other parameters
%             required for the network's operation.
%       x   - A vector representing the data point to be added as a new
%             component in the network.
%
%   Outputs:
%       net - The updated network structure with the new component added.
%
%   Notes:
%       - The function initializes the covariance matrix for the new
%         component using the `nonOverlappingInitialCov` function.
%       - If the `useRankOne` flag is set in the network, the function
%         updates the inverse covariance matrices and log determinants.
%       - Otherwise, it updates the full covariance matrices.
%       - The function also recalculates the probability density for the
%         new component using the `computeProbDensity` function.
function net = addComponent(net, x) %#codegen
    initialCov = nonOverlappingInitialCov(net, x);
    net.nc = net.nc + 1;
    net.means =  [net.means; x];
    net.sp = [net.sp, 1];
    net.spu = [net.spu, 0];
    net.vs = [net.vs, 0];
    net.distances = [net.distances, 0];
    net.logLikes = [net.logLikes, 0];
    net.priors = net.sp ./ sum(net.sp, 2);
    if net.useRankOne
        if isempty(net.invCovs)
            net.invCovs = initialCov;
            net.logDets = net.initialLogDet;
        else
            net.invCovs = cat(3, net.invCovs, initialCov);
            net.logDets = [net.logDets, net.initialLogDet];
        end
    else
        if isempty(net.covs)
            net.covs = initialCov;
        else
            net.covs = cat(3, net.covs, initialCov);
        end
    end
    net = computeProbDensity(net, x, net.nc);
end