% initialPopulationCheck - Validates and adjusts the initial population for optimization.
%
% Syntax:
%   options = initialPopulationCheck(options)
%
% Description:
%   This function checks the initial population provided in the options
%   structure for an optimization problem. It ensures that the initial
%   population is consistent with the specified population size and
%   removes any excess individuals if necessary. If the initial population
%   is empty, no checks are performed.
%
% Input:
%   options - A structure containing the following fields:
%       - InitialPopulation: A matrix where each row represents an
%         individual in the initial population.
%       - PopulationSize: A scalar specifying the desired number of
%         individuals in the population.
%
% Output:
%   options - The updated options structure with the initial population
%             adjusted if necessary.
%
% Notes:
%   - If the number of individuals in the initial population exceeds the
%     specified population size, a warning is issued, and the excess
%     individuals are removed.
%   - If the initial population is empty, the function exits without
%     performing any checks.
function options = initialPopulationCheck(options) %#codegen
    numInitPositions = size(options.InitialPopulation, 1);
    
    % No tests if initial positions is empty
    if numInitPositions == 0; return; end
    
    % Warn if too many positions were specified.
    numIndividuals = options.PopulationSize;
    if numInitPositions > numIndividuals
        warning('Too many positions were specified');
        options.InitialPopulation((numIndividuals + 1):numInitPositions, :) = [];
    end

end
