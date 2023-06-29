% Remove spurious components
function net = removeSpurious(net) %#codegen
    indexes = zeros(size(net.sps), 'logical');
    indexes(1:net.nc) = ~( ...
        net.sps(1:net.nc) < net.spMin & net.vs(1:net.nc) > net.vMin);
    net.nc = int32(sum(indexes));
    net.priors(1:net.nc) = net.priors(indexes);
    net.means(1:net.nc, :) = net.means(indexes, :);
    net.covs(:, :, 1:net.nc) = net.covs(:, :, indexes);
    net.vs(1:net.nc) = net.vs(indexes);
    net.sps(1:net.nc) = net.sps(indexes);                  
    net.post(1:net.nc) = net.post(indexes);
    net.distances(1:net.nc) = net.distances(indexes);
    net.logLike(1:net.nc) = net.logLike(indexes);
end
