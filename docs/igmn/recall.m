% recall - Performs the Gaussian Mixture Regression for a given input.
%   This function estimates the missing values in the input data `X` 
%   using the Incremental Gaussian Mixture Network (IGMN). The known 
%   attributes are specified by the `features` parameter, and the 
%   optional `featureGrid` parameter can be used to compute posterior 
%   probabilities over a grid.
%
% Inputs:
%   net (1, 1) igmn:
%       An instance of the IGMN model containing the learned parameters.
%
%   X (:, :) numeric:
%       A numeric matrix where each row represents an input sample with 
%       known values for some attributes.
%
%   features (1, :) numeric (optional):
%       An array of integers specifying the indices of the known attributes 
%       in `X`. If not provided, the function assumes that the first `M` 
%       attributes are known, where `M` is the number of columns in `X`.
%
%   featureGrid (:, :) numeric (optional):
%       A numeric matrix representing a grid of values over which the 
%       posterior probabilities are computed. If not provided, no grid 
%       computation is performed.
%
% Outputs:
%   Y (:, :) numeric:
%       A numeric matrix containing the estimated values for the missing 
%       attributes in `X`.
%
%   probabilities (:, :) numeric:
%       A numeric matrix containing the computed posterior probabilities 
%       for the given `featureGrid`. If `featureGrid` is not provided, 
%       this output will be an empty matrix.
%
% Notes:
%   - The function uses the learned parameters of the IGMN model, such as 
%     means, covariances, and priors, to perform the regression.
%   - If `features` is not specified, the function assumes that the known 
%     attributes are the first `M` columns of `X`.
%   - The `useRankOne` property of the IGMN model determines whether a 
%     rank-one update is used for covariance computations.
%   - The function handles cases where probabilities or posterior 
%     assignments (`pajs`) result in NaN values by setting them to zero.
function [Y, probabilities] = recall(net, X, features, featureGrid) %#codegen
    arguments
        net (1, 1) igmn;
        X (:, :) { ...
            mustBeNumeric, ...
            mustBeNonempty ...
        };
        features (1, :) { ...
            mustBeNumeric, ...
            mustBeNonempty, ...
            mustBeInteger, ...
            mustBeNDimensional(net, X, features) ...
        } = [(size(X, 2) + 1):net.dimension], ...
        featureGrid (:, :) { mustBeNumeric } = [];
    end
    N = size(X, 1);
    computeGrid = ~isempty(featureGrid);
    if computeGrid
        probabilities = zeros(N, size(featureGrid, 1));
    else
        probabilities = zeros(N, 0);
    end
    F = length(features);
    beta = features;
    alpha = setdiff(1:net.dimension, beta);
    pajs = zeros(N, 1, net.nc);
    xm = zeros(N, F, net.nc);

    useRankOne = net.useRankOne;

    alphaMeans = net.means(:, alpha);
    betaMeans = net.means(:, beta);
    if useRankOne; covs = net.invCovs; else; covs = net.covs;end
    alphaAlphaCovs = covs(alpha, alpha, :);
    betaAlphaCovs = covs(beta, alpha, :);
    betaBetaCovs = covs(beta, beta, :);
    priors = net.priors;
    
    for i = 1:net.nc
        diff = X - alphaMeans(i, :);
        alphaAlphaCov = alphaAlphaCovs(:, :, i);
        betaAlphaCov = betaAlphaCovs(:, :, i);
        betaBetaCov = betaBetaCovs(:, :, i);
        determinant = 1;
        if useRankOne
            invBetaAlpha = betaBetaCov \ betaAlphaCov;
            invA = alphaAlphaCov - (betaAlphaCov' * invBetaAlpha);
            determinant = det(betaBetaCov);
            pajs(:, :, i) = computeLoglike(X, invA, alphaMeans(i, :), ...
                useRankOne=true, determinant=determinant) + igmn.minimum;
            xm(:, :, i) = (betaMeans(i, :) - (invBetaAlpha * diff')');  
        else
            xm(:, :, i) = betaMeans(i, :) + (betaAlphaCov / alphaAlphaCov * diff')';
            loglike = computeLoglike(X, alphaAlphaCov, diff);
            pajs(:, :, i) = exp(loglike) * priors(i);
        end
        if computeGrid
            loglikeGrid = computeLoglike(featureGrid, betaBetaCov, xm(:, :, i), ...
                isProbability=true, useRankOne=useRankOne, determinant=determinant);
            if ~useRankOne; loglikeGrid = exp(loglikeGrid); end
            probabilities = probabilities + pajs(:, :, i) .* loglikeGrid;
        end
    end
    pajs = pajs ./ sum(pajs, 3);
    pajs(isnan(pajs)) = 0;
    Y = sum(bsxfun(@times, xm, pajs), 3);
    if computeGrid
        probabilities = probabilities ./ sum(probabilities, 2);
        probabilities(isnan(probabilities)) = 0;
    end
end
