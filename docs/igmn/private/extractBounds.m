% extractBounds - Extracts the lower and upper bounds of hyperparameters.

% Syntax:
%   [lbRow, ubRow, nhps] = extractBounds(hyperparameters, hpIndexes)

% Inputs:
%   hyperparameters - A cell array where each element is a structure 
%                     containing the fields 'lb' (lower bound) and 'ub' 
%                     (upper bound) for a hyperparameter.
%   hpIndexes       - A vector of indices specifying which hyperparameters 
%                     to extract bounds for.

% Outputs:
%   lbRow           - A row vector containing the lower bounds of the 
%                     specified hyperparameters.
%   ubRow           - A row vector containing the upper bounds of the 
%                     specified hyperparameters.
%   nhps            - The number of hyperparameters specified by hpIndexes.

% Notes:
%   This function uses arrayfun to extract the 'lb' and 'ub' fields from 
%   the hyperparameters cell array based on the indices provided in 
%   hpIndexes.

% Example:
%   hyperparameters = {struct('lb', 0, 'ub', 1), struct('lb', -1, 'ub', 2)};
%   hpIndexes = [1, 2];
%   [lbRow, ubRow, nhps] = extractBounds(hyperparameters, hpIndexes);
%   % lbRow = [0, -1], ubRow = [1, 2], nhps = 2
function [lbRow, ubRow, nhps] = extractBounds(hyperparameters, hpIndexes) %#codegen
    nhps = length(hpIndexes);
    lbRow = arrayfun(@(i) hyperparameters{i}.lb, hpIndexes);
    ubRow = arrayfun(@(i) hyperparameters{i}.ub, hpIndexes);
end
