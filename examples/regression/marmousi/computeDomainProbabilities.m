% computeDomainProbabilities - Computes domain probabilities for a given grid of predictions.

% Syntax:
%   domainProbabilities = computeDomainProbabilities(gridPredictions, features, discretizationSize)

% Inputs:
%   gridPredictions    - A matrix of size (N x M) where N is the number of
%                        predictions and M is the flattened size of the grid.
%   features           - A vector containing the features used for the computation.
%   discretizationSize - An integer specifying the size of the discretization
%                        for each dimension of the grid.

% Outputs:
%   domainProbabilities - A 3D matrix of size (F x N x discretizationSize),
%                         where F is the number of feature pairs, N is the
%                         number of predictions, and discretizationSize is
%                         the size of the discretized domain.

% Description:
%   This function computes the domain probabilities for a given set of grid
%   predictions. It reshapes the grid predictions into a 3D grid and iteratively
%   computes the probabilities for each pair of features by summing over the
%   corresponding dimensions. The probabilities are normalized to ensure they
%   sum to 1.

% Example:
%   gridPredictions = rand(10, 1000); % Example grid predictions
%   features = [1, 2, 3];
%   discretizationSize = 10;
%   domainProbabilities = computeDomainProbabilities(gridPredictions, features, discretizationSize);

% See also:
%   reshape, sum, squeeze
function domainProbabilities = computeDomainProbabilities(gridPredictions, features, discretizationSize)
    N = size(gridPredictions, 1);
    F = length(features);
    domainProbabilities = zeros(F, N, discretizationSize);
    for i = 1:N
        gridPostJoint = reshape(gridPredictions(i, :), discretizationSize, discretizationSize, discretizationSize);
        index = 1;
        for r = F:-1:2
            for c = (r - 1):-1:1
                domainProbabilities(index, i, :) = sum(squeeze(sum(squeeze(gridPostJoint), r)), c);
                domainProbabilities(index, i, :) = ...
                    domainProbabilities(index, i, :) ./ sum(domainProbabilities(index, i, :));
                index  = index + 1;
            end
        end
    end
end
