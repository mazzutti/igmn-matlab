% Compute the log probability density of a multivariate normal 
% distribution.
function [logLike, distance] = computeLoglike(X, cov, data, options) %#codegen
    arguments
        X double
        cov double
        data double
        options.isProbability (1, 1) logical = false
        options.useRankOne (1, 1) logical = false
        options.determinant (1, 1) double = 1
    end
    dim = size(X, 2);
    twopi = 2 * pi;
    if options.useRankOne
        N = size(data, 1);
        distance = zeros(N, size(X, 1));
        regularization = (twopi .^ (dim / 2.0)) * sqrt(options.determinant);
        if ~options.isProbability
            diff = bsxfun(@minus, X, data);
            distance = sum(diff * cov .* diff, 2);
        else
            parfor i = 1:N
                diff = bsxfun(@minus, data(i, :), X);
                distance(i, :) = sum(diff * cov .* diff, 2);
            end
        end
        logLike = exp(-0.5 .* distance) ./ regularization;
        logLike = fillmissing(logLike, 'constant', 0);
    else
        [L, diagL, ~] = computeChol(cov);
        if ~options.isProbability
            xRinv = data / L;
            distance = sum(xRinv .^ 2, 2);
        else
            N = size(data, 1);
            distance = zeros(N, size(X, 1));
            parfor i = 1:N
                distance(i, :) = sum((L \ bsxfun(@minus, X, data(i, :))') .^ 2, 1);
            end
        end
        logDetCov = 2 * sum(log(diagL));
        regValue = dim * log(twopi);
        logLike = -0.5 * (distance + logDetCov + regValue);
    end
end