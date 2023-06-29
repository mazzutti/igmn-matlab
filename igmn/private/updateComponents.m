% Update the IGMN parameters 
function net = updateComponents(net, x) %#codegen
    net.sps(1:net.nc) = net.sps(1:net.nc) + net.post(1:net.nc);
    net.vs(1:net.nc) = int32(net.vs(1:net.nc) + 1);
    w = permute(net.post(1:net.nc) ./ net.sps(1:net.nc), [3, 1, 2]); 
    deltaMU = pagemtimes(w, permute(x - net.means(1:net.nc, :), [3, 2, 1]));
    oldMeans = permute(net.means(1:net.nc, :), [3, 2, 1]);
    net.means(1:net.nc, :) = reshape( ...
        bsxfun(@plus, oldMeans, deltaMU), net.dimension, net.nc)';
    diff = permute(x - net.means(1:net.nc, :), [3, 2, 1]);
    deltaMUMult = pagemtimes(permute(deltaMU,[2 1 3]), deltaMU);
    diffMult = bsxfun(@minus, pagemtimes( ...
        permute(diff,[2 1 3]), diff), net.covs(:, :, 1:net.nc));
    wightedDiff = bsxfun(@plus, pagemtimes(w, diffMult), net.minCov);
    deltaSum = bsxfun(@minus, net.covs(:, :, 1:net.nc), deltaMUMult);
    net.covs(:, :, 1:net.nc) = bsxfun(@plus, deltaSum, wightedDiff);
    
    % normalize the priors
    net = updatePriors(net);
end