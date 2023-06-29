% Compute the log probability density of a multivariate normal 
% distribution.
function net = logmvnpdf(net, x, i) %#codegen
    [L, diagL, net.covs(:, :, i)] = computeChol(net.covs(:, :, i));
    diff = x - net.means(i, :);
    xRinv = diff / L;
    net.distances(i) = sum(xRinv .^ 2, 2);
    net.logLike(i) = -0.5 * (net.distances(i) ...
        + 2 * sum(log(diagL)) + size(x, 2) * log(2 * pi));       
end

