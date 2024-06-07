function [Y, probabilities] = recall(net, X, features, featureGrid) %#codegen
    % RECALL Performs the Gaussian Mixture Regression for a given 
    %        input.
    %   This method returns an estimate for the missing values. The 
    %   X parameter defines the known values while the features
    %   defines which attributes are know. 
    %   
    %   **Notice**: if features is  not given, IGMN assumes that 
    %   the firsts M attributes are known, where M is the dimension 
    %   of X.
    %
    % Inputs:
    %   Y : an NxM attributes array.
    %   features : an optional array of ints or names.
    %   featureGrid : an optional array to doubles with the grid 
    %   to compute probabilities.
    % Output:
    %   Y : an array with the estimate for the missing 
    %       values.
    %   probabilities: the computed posterior probabilities.
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
    pajs = fillmissing(pajs, 'constant', 0);
    Y = sum(bsxfun(@times, xm, pajs), 3);
    if computeGrid
        probabilities = probabilities ./ sum(probabilities, 2);
        probabilities = fillmissing(probabilities, 'constant', 0);
    end
end
