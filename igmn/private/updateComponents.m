function net = updateComponents(net, x) %#codegen
    net.vs = net.vs + 1;
    net.sp = net.sp + net.posteriors;
    net.spu = net.spu + net.posteriors;
    means = permute(net.means, [3, 2, 1]);
    lr = permute(net.posteriors ./ net.sp, [3, 1, 2]);
    diff = (x - means) .* lr;
    means = means + diff;
    updateDiff = x - means;
    if net.useRankOne
        lrInv = (1.0 - lr);
        updateDiff = updateDiff .* sqrt(lr);
        invCovs = net.invCovs ./ lrInv;

        % Rank-one update
        numerator = sum(invCovs .* updateDiff, 2);
        denominator = 1 + sum(updateDiff .* pagectranspose(numerator), 2);
        partial = bsxfun(@mtimes, numerator,  pagetranspose(numerator));
        invCovs = invCovs - partial ./ denominator;
        logdet = net.logDets .* ...
            (squeeze(lrInv)' .^ net.dimension) .* squeeze(denominator)';

        % Rank-one downdate
        numerator = sum(invCovs .* diff, 2);
        denominator = 1 - sum(diff .* pagectranspose(numerator), 2);
        partial = bsxfun(@mtimes, numerator, pagetranspose(numerator));
        net.invCovs = invCovs + partial ./ denominator + net.minCov;
        net.logDets(1:end) = wrapValues(logdet .* squeeze(denominator)');
    else
        deltaMUMult = pagemtimes(permute(diff, [2 1 3]), diff);
        diffMultTemp = pagemtimes(permute(updateDiff,[2 1 3]), updateDiff);
        diffMult = bsxfun(@minus, diffMultTemp, net.covs);
        wightedDiff = bsxfun(@plus, pagemtimes(lr, diffMult), net.minCov);
        deltaSum = bsxfun(@minus, net.covs, deltaMUMult);
        net.covs = bsxfun(@plus, deltaSum, wightedDiff); 
    end
    net.means = reshape(means, net.dimension, net.nc)';
    net.priors = bsxfun(@rdivide, net.sp, sum(net.sp, 2));
end