% Update the IGMN priors
function net = updatePriors(net) %#codegen
    net.priors(1:net.nc) = net.sps(1:net.nc) ./ sum(net.sps(1:net.nc));
end