% Compute the posterior probability for each IGMN component
function net = computePosteriors(net) %#codegen
    if net.useRankOne
        net.posteriors = net.logLikes .* net.priors;
        net.posteriors = net.posteriors / sum(net.posteriors);
    	net.posteriors = fillmissing(net.posteriors, 'constant', 0);
    else
        logDensity = bsxfun(@plus, net.logLikes, log(net.priors));
        % minus maxll to avoid underflow
        logDensity = exp(bsxfun(@minus, logDensity, max(logDensity, [], 2)));
        % normalize
        net.posteriors = bsxfun(@rdivide, logDensity, sum(logDensity, 2));
    end
end
