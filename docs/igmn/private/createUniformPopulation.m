
% createUniformPopulation - Generates a uniform population of individuals for optimization.
%
% Syntax:
%   population = createUniformPopulation(problemStruct, hpIndexes)
%
% Inputs:
%   problemStruct - A structure containing the problem definition, including:
%       - nhps: Number of hyperparameters.
%       - options: A structure with options for the optimization process, including:
%           - PopulationSize: Total number of individuals in the population.
%           - InitialPopulation: Matrix of initial individuals (optional).
%           - InitialPopulationSpan: Span for generating initial individuals.
%       - lb: Lower bounds for the hyperparameters.
%       - ub: Upper bounds for the hyperparameters.
%   hpIndexes - Indices of discrete hyperparameters in the population.
%
% Outputs:
%   population - A matrix where each row represents an individual in the population,
%                and each column corresponds to a hyperparameter.
%
% Description:
%   This function generates a population of individuals for an optimization problem.
%   It uses the provided initial population (if any) and fills the remaining slots
%   by sampling uniformly within the specified bounds. The function ensures that
%   all values are finite and rounds discrete hyperparameters to valid values.
%
% Notes:
%   - The function relies on the helper functions `determinePositionInitBounds` to
%     calculate finite bounds and `roundDiscreteHyperparameters` to handle discrete
%     hyperparameters.
%   - An error is raised if any value in the generated population is not finite.
%
% See also:
%   determinePositionInitBounds, roundDiscreteHyperparameters
function population = createUniformPopulation(problemStruct, hpIndexes) %#codegen

    nhps = problemStruct.nhps;
    options = problemStruct.options;
    % Determine finite bounds for the initial individuals based on the problem's
    % bounds and options.InitialPopulationSpan.
    [lb, ub] = determinePositionInitBounds(problemStruct.lb, problemStruct.ub, options.InitialPopulationSpan);

    numIndividuals = options.PopulationSize;
    numInitPositions = size(options.InitialPopulation, 1);
    numPositionsToCreate = numIndividuals - numInitPositions;

    % Initialize individuals to be created
    population = zeros(numIndividuals, nhps);
    
    % Use initial individuals provided already
    if numInitPositions > 0
        population(1:numInitPositions, :) = options.InitialPopulation;
    end
    
    % Create remaining individuals, randomly sampling within lb and ub

    population(numInitPositions + 1:end, :) = unifrnd( ...
        repmat(lb, numPositionsToCreate, 1), repmat(ub, numPositionsToCreate, 1));

    % Error if any values are not finite
    if ~all(isfinite(population(:)))
        error('Position not finite');
    end
    population = roundDiscreteHyperparameters(population, options.hyperparameters, hpIndexes);
end

% DETERMINEPOSITIONINITBOUNDS Adjusts lower and upper bounds for initialization.
%
%   [LB, UB] = DETERMINEPOSITIONINITBOUNDS(LB, UB, INITIALPOPULATIONSPAN)
%   updates the lower bounds (LB) and upper bounds (UB) based on the
%   specified INITIALPOPULATIONSPAN. This ensures that the initial bounds
%   are always finite.
%
%   Inputs:
%       LB - Vector of lower bounds. Can contain finite or infinite values.
%       UB - Vector of upper bounds. Can contain finite or infinite values.
%       INITIALPOPULATIONSPAN - Vector specifying the span for initializing
%                               the population. Must be the same size as LB
%                               and UB.
%
%   Outputs:
%       LB - Updated vector of lower bounds with finite values.
%       UB - Updated vector of upper bounds with finite values.
%
%   Behavior:
%       - If both LB and UB are finite, the bounds remain unchanged.
%       - If both LB and UB are infinite, the range is centered around 0
%         using INITIALPOPULATIONSPAN.
%       - If only LB is finite, UB is set to LB + INITIALPOPULATIONSPAN.
%       - If only UB is finite, LB is set to UB - INITIALPOPULATIONSPAN.
%
%   Note:
%       This function is designed to handle cases where bounds may be
%       partially or fully infinite, ensuring that the resulting bounds
%       are always finite and suitable for initialization purposes.
function [lb, ub] = determinePositionInitBounds(lb, ub, initialPopulationSpan) %#codegen
    % Update lb and ub using positionInitSpan, so that initial bounds are
    % always finite
    lbFinite = isfinite(lb);
    ubFinite = isfinite(ub);
    lbInf = ~lbFinite;
    ubInf = ~ubFinite;
    
    % If lb and ub are both finite, do not update the bounds.
    
    % If lb & ub are both infinite, center the range around 0.
    idx = lbInf & ubInf;
    lb(idx) = -initialPopulationSpan(idx)/2;
    ub(idx) = initialPopulationSpan(idx)/2;
    
    % If only lb is finite, start the range at lb.
    idx = lbFinite & ubInf;
    ub(idx) = lb(idx) + initialPopulationSpan(idx);
    
    % If only ub is finite, end the range at ub.
    idx = lbInf & ubFinite;
    lb(idx) = ub(idx) - initialPopulationSpan(idx);
end

