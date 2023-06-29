% Compute the log probability density of a multivariate normal 
% distribution.
function [loglike, distance] = computeLoglike(X, cov, data, isProbabity) %#codegen
    [L, diagL, ~] = computeChol(cov);
    logDetCov = 2 * sum(log(diagL));
    if ~isProbabity
        xRinv = data / L;
        distance = sum(xRinv .^ 2, 2);
    else
        N = size(data, 1);
        distance = zeros(N, size(X, 1));
        parfor i = 1:N
            distance(i, :) = sum((L \ bsxfun(@minus, X, data(i, :))') .^ 2, 1);
        end
    end
    regValue = size(X, 2) * log(2 * pi);
    loglike = -0.5 * (distance + logDetCov + regValue);
end
