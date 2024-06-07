% Remove spurious components
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
