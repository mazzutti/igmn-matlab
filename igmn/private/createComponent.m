% Create a component when a data point x matches the novelty 
% criterion.
function net = createComponent(net, x) %#codegen
    net.nc = int32(net.nc + 1);
    net.means(net.nc, :) = x;
    net.sps(1, net.nc) = 1;
    net.vs(1, net.nc) = int32(0);
    net = updatePriors(net);
    net.covs(:, :, net.nc) = net.initialCov;
    net = logmvnpdf(net, x, net.nc);
end
