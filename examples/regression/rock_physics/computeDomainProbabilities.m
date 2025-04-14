% computeDomainProbabilities - Computes domain probabilities for a given grid of predictions.
%
% Syntax:
%   domainProbabilities = computeDomainProbabilities(gridPredictions, features, discretizationSize)
%
% Inputs:
%   gridPredictions     - A matrix of size [N x M], where N is the number of samples
%                         and M is the total number of grid points in the discretized space.
%   features            - A vector containing the features used for the computation.
%   discretizationSize  - An integer specifying the size of the discretized grid along each dimension.
%
% Outputs:
%   domainProbabilities - A 3D array of size [F x N x discretizationSize], where F is the number
%                         of feature pairs (combinations of features), N is the number of samples,
%                         and discretizationSize is the size of the discretized grid along each dimension.
%                         This array contains the computed domain probabilities for each feature pair.
%
% Description:
%   This function computes the domain probabilities for a given grid of predictions by reshaping
%   the grid predictions into a 3D grid and summing over specific dimensions to marginalize the
%   probabilities. The probabilities are normalized for each feature pair and sample.
%
% Example:
%   gridPredictions = rand(10, 1000); % Example grid predictions
%   features = [1, 2, 3];             % Example features
%   discretizationSize = 10;          % Example discretization size
%   domainProbabilities = computeDomainProbabilities(gridPredictions, features, discretizationSize);
%
% Notes:
%   - The function assumes that the grid predictions can be reshaped into a 3D grid of size
%     [discretizationSize x discretizationSize x discretizationSize].
%   - The order of feature pairs is determined by iterating over combinations of features
%     in reverse order.
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
