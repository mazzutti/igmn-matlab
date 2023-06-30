% Update the IGMN parameters 
function net = updateComponents(net, x) %#codegen
    net.sps = net.sps + net.posteriors;
    net.vs = net.vs + 1;
    w = permute(net.posteriors ./ net.sps, [3, 1, 2]); 
    deltaMU = pagemtimes(w, permute(x - net.means, [3, 2, 1]));
    oldMeans = permute(net.means, [3, 2, 1]);
    net.means = reshape(bsxfun(@plus, oldMeans, deltaMU), net.dimension, net.nc)';
    diff = permute(x - net.means, [3, 2, 1]);
    deltaMUMult = pagemtimes(permute(deltaMU, [2 1 3]), deltaMU);
    diffMult = bsxfun(@minus, pagemtimes(permute(diff,[2 1 3]), diff), net.covs);
    wightedDiff = bsxfun(@plus, pagemtimes(w, diffMult), net.minCov);
    deltaSum = bsxfun(@minus, net.covs, deltaMUMult);
    net.covs = bsxfun(@plus, deltaSum, wightedDiff);
    
    % normalize the priors
    net.priors = net.sps ./ sum(net.sps);
end
