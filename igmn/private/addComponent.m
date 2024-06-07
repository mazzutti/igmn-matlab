% Create a component when a data point x matches the novelty 
% criterion.
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