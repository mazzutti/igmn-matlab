% computeLoglike - Computes the log-likelihood and distance for given data.
%
% Syntax:
%   [logLike, distance] = computeLoglike(X, cov, data, options)
%
% Inputs:
%   X       - (double) Input data matrix of size [M, D], where M is the number
%             of samples and D is the dimensionality of the data.
%   cov     - (double) Covariance matrix of size [D, D].
%   data    - (double) Data matrix of size [N, D], where N is the number of
%             data points.
%   options - (struct) Optional parameters:
%             - isProbability: (logical) If true, computes probabilities
%               instead of distances. Default is false.
%             - useRankOne: (logical) If true, uses a rank-one update
%               approach. Default is false.
%             - determinant: (double) Determinant of the covariance matrix.
%               Default is 1.
%
% Outputs:
%   logLike  - (double) Log-likelihood values of size [N, M] or [N, 1],
%              depending on the options.
%   distance - (double) Distance values of size [N, M] or [N, 1], depending
%              on the options.
%
% Description:
%   This function computes the log-likelihood and distance for the given
%   data points using the provided covariance matrix. It supports both
%   standard and rank-one update approaches, and can optionally compute
%   probabilities instead of distances.
%
% Notes:
%   - The function uses Cholesky decomposition for efficient computation
%     when the 'useRankOne' option is false.
%   - Parallel computation (parfor) is used for certain operations to
%     improve performance when the 'isProbability' option is true.
%
% See also:
%   computeChol
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