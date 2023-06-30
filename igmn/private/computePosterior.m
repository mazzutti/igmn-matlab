% Compute the posterior probability for each IGMN component
function net = computePosterior(net) %#codegen
    logDensity = bsxfun(@plus, net.logLikes, double(log(net.priors)));
    % minus maxll to avoid underflow
    logDensity = exp(bsxfun(@minus, logDensity, max(logDensity, [], 2)));
    % normalize
    net.posteriors = bsxfun(@rdivide, logDensity, sum(logDensity, 2));
end
