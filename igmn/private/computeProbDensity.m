% Compute the probability density of a multivariate normal 
% distribution.
function net = computeProbDensity(net, x, i) %#codegen
    coder.inline('always');
    diff = x - net.means(i, :);
    dim = net.dimension;
    twopi = 2 * pi;
    if net.useRankOne
        diff = x - net.means(i, :);
        net.distances(i) = diff * net.invCovs(:, :, i) * diff';
        regularization = ((2 * pi) .^ (dim / 2.0)) * sqrt(net.logDets(i));
        net.logLikes(i) = wrapValues(exp(-0.5 * net.distances(i)) / regularization);
    else
        [L, diagL, net.covs(:, :, i)] = computeChol(net.covs(:, :, i));
        xRinv = diff / L;
        net.distances(i) = sum(xRinv .^ 2, 2);
        net.logLikes(i) = -0.5 * ( ...
            net.distances(i) + 2 * sum(log(diagL)) + dim * log(twopi));
    end
end


