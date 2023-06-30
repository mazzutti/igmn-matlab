% Create a component when a data point x matches the novelty 
% criterion.
function net = createComponent(net, x) %#codegen
    net.nc = int32(net.nc + 1);
    net.means =  [net.means; x];
    net.sps = [net.sps, 1];
    net.vs = [net.vs, 0];
    net.distances = [net.distances, 0];
    net.logLikes = [net.logLikes, 0];
    net.priors = net.sps ./ sum(net.sps);
    net.covs = cat(3, net.covs, net.initialCov);
    net = logmvnpdf(net, x, net.nc);
end
