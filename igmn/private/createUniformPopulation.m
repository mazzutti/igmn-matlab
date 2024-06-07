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

