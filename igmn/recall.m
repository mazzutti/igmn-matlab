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
    
    % if nargin < 3
    %     features  = (M + 1):net.dimension;
    % end
    F = length(features);
    beta = features;
    alpha = setdiff(1:net.dimension, beta);
    
    pajs = zeros(N, 1, net.nc);
    xm = zeros(N, F, net.nc);
    
    computeGrid = ~isempty(featureGrid);
    if computeGrid
        probabilities = zeros(N, size(featureGrid, 1));
    else
        probabilities = zeros(N, 0);
    end

    
    alphaCovs = net.covs(alpha, alpha, :);
    alphaBetaCovs = net.covs(beta, alpha, :);
    betaBetaCovs = net.covs(beta, beta, :);
    alphaMeans = net.means(:, alpha);
    betaMeans = net.means(:, beta);
    priors = net.priors(:);
    
    parfor i = 1:net.nc
        alphaDiff = X - alphaMeans(i, :);
        alphaCov = alphaCovs(:, :, i);
        alphaBetaCov = alphaBetaCovs(:, :, i);
        xm(:, :, i) = betaMeans(i, :) + (alphaBetaCov / alphaCov * alphaDiff')';
        loglike = computeLoglike(X, alphaCov, alphaDiff, false);
        pajs(:, :, i) = exp(loglike) * priors(i);
        if computeGrid
            loglikeGrid = computeLoglike(featureGrid, betaBetaCovs(:, :, i), xm(:, :, i), true);
            probabilities = probabilities + pajs(:, :, i) .* exp(loglikeGrid);
        end
    end
    
    pajs = pajs ./ sum(pajs, 3);
    pajs(isnan(pajs)) = 0;
    Y = sum(bsxfun(@times, xm, pajs), 3);
    if computeGrid
        probabilities = probabilities ./ sum(probabilities, 2);
    end
end
