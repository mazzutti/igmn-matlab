% Remove spurious components
function net = removeSpurious(net) %#codege
    indexes = net.sps < net.spMin & net.vs > net.vMin;
    net.nc = net.nc - sum(indexes);
    net.priors(indexes) = [];
    net.means(indexes, :) = [];
    net.covs(:, :, indexes) = [];
    net.vs(indexes) = [];
    net.sps(indexes) = [];                  
    net.posteriors(indexes) = [];
    net.distances(indexes) = [];
    net.logLikes(indexes) = [];
end
