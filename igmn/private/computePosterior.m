% Compute the posterior probability for each IGMN component
function net = computePosterior(net) %#codegen
    logDensity = bsxfun(@plus, ...
        net.logLike(1:net.nc), double(log(net.priors(1:net.nc))));
    % minus maxll to avoid underflow
    logDensity = exp(bsxfun(@minus, logDensity, max(logDensity, [], 2)));
    % normalize
    net.post(1:net.nc) = bsxfun(@rdivide, logDensity, sum(logDensity, 2));
end
