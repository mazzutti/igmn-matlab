% roundDiscreteHyperparameters - Rounds discrete hyperparameters in a population matrix.
%
% Syntax:
%   population = roundDiscreteHyperparameters(population, hyperparameters, hpIndexes)
%
% Description:
%   This function iterates over a set of hyperparameters and rounds the values
%   of discrete hyperparameters in the given population matrix. It modifies the
%   population matrix in-place for the specified hyperparameter indexes.
%
% Inputs:
%   population      - A matrix where each row represents an individual in the
%                     population, and each column corresponds to a hyperparameter.
%   hyperparameters - A cell array of hyperparameter structures. Each structure
%                     contains information about a hyperparameter, including
%                     whether it is discrete (isDiscrete field).
%   hpIndexes       - A vector of indexes indicating which hyperparameters in
%                     the hyperparameters cell array should be processed.
%
% Outputs:
%   population      - The updated population matrix with discrete hyperparameters
%                     rounded to the nearest integer.
%
% Notes:
%   - The function assumes that the `isDiscrete` field in each hyperparameter
%     structure is a logical value indicating whether the hyperparameter is discrete.
%   - The function uses MATLAB's `round` function to round the values.
%
% Example:
%   % Define a population matrix
%   population = [1.2, 3.5; 4.7, 2.8];
%
%   % Define hyperparameters
%   hyperparameters = {struct('isDiscrete', true), struct('isDiscrete', false)};
%
%   % Specify indexes of hyperparameters to process
%   hpIndexes = [1];
%
%   % Round discrete hyperparameters
%   population = roundDiscreteHyperparameters(population, hyperparameters, hpIndexes);
function population = roundDiscreteHyperparameters(population, hyperparameters, hpIndexes) %#codegen
    for i = 1:length(hpIndexes)
        hp = hyperparameters{hpIndexes(i)};
        if hp.isDiscrete
            population(:, i) = round(population(:, i));
        end
    end
end
