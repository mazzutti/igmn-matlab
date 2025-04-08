%{
imode.m - Perform optimization using the IMODE algorithm.

This script contains the implementation of the IMODE (Improved Multi-Operator Differential Evolution) 
algorithm for optimization. It includes the main function `imode` and its core implementation 
`imodecore`, along with helper functions for updating positions and managing the optimization state.

FUNCTIONS:
1. imode(problem)
    - Main entry point for the IMODE optimization algorithm.
    - Parameters:
      - problem: A structure containing the optimization problem definition and options.
    - Returns:
      - x: The best solution found.
      - fval: The objective function value at the best solution.
      - exitFlag: A flag indicating the reason for termination.

2. imodecore(nhps, lbRow, ubRow, problem, hpNames, hpIndexes)
    - Core implementation of the IMODE algorithm.
    - Parameters:
      - nhps: Number of hyperparameters.
      - lbRow: Lower bounds for hyperparameters.
      - ubRow: Upper bounds for hyperparameters.
      - problem: The optimization problem structure.
      - hpNames: Names of hyperparameters.
      - hpIndexes: Indexes of hyperparameters.
    - Returns:
      - x: The best solution found.
      - fval: The objective function value at the best solution.
      - exitFlag: A flag indicating the reason for termination.

3. updatePositions(state, lbRow, ubRow, pIdx, numIndividuals, nhps, hyperparameters, hpIndexes, F, OP, CR)
    - Updates the positions of individuals in the population.
    - Parameters:
      - state: Current state of the optimization process.
      - lbRow: Lower bounds for hyperparameters.
      - ubRow: Upper bounds for hyperparameters.
      - pIdx: Indexes of the current population.
      - numIndividuals: Number of individuals in the population.
      - nhps: Number of hyperparameters.
      - hyperparameters: Hyperparameter definitions.
      - hpIndexes: Indexes of hyperparameters.
      - F: Scaling factors for mutation.
      - OP: Operators for generating offspring.
      - CR: Crossover probabilities.
    - Returns:
      - newPositions: Updated positions of individuals.

NOTES:
- The IMODE algorithm uses a combination of mutation, crossover, and selection operators to evolve 
  a population of candidate solutions.
- The algorithm supports parallel computation for evaluating the objective function.
- Stopping criteria include maximum function evaluations, stall iterations, and user-defined conditions.
- The implementation includes support for plotting and monitoring the optimization process.

USAGE:
- Define the optimization problem and options in the `problem` structure.
- Call the `imode` function with the problem structure to perform optimization.
- The best solution and its objective function value are returned upon completion.

DEPENDENCIES:
- This implementation relies on several helper functions, such as `extractHyperarameterNames`, 
  `extractBounds`, `validateOptimizationOptions`, `initialPopulationCheck`, `evaluate`, 
  `makeOptimizationState`, `stopOptimization`, and `roundDiscreteHyperparameters`.

%}
function [x, fval, exitFlag] = imode(problem) %#codegen

    optOptions = problem.OptimizeOptions;
    [hpNames, hpIndexes] = extractHyperarameterNames(optOptions);

    [lbRow , ubRow, nhps] =  extractBounds(optOptions.hyperparameters, hpIndexes); 
    
    optOptions = validateOptimizationOptions(optOptions, nhps, hpIndexes);
    
    % Perform check on initial population, fvals, and range
    problem.OptimizeOptions = initialPopulationCheck(optOptions);

    % Start the core algorithm
    [x, fval, exitFlag] = imodecore(nhps, lbRow, ubRow, problem, hpNames, hpIndexes);
end

function [x,fval,exitFlag] = imodecore(nhps, lbRow, ubRow, problem, hpNames, hpIndexes)
    coder.extrinsic('callPlotFcns');

    optOptions = problem.OptimizeOptions;

    exitFlag = [];
    coder.varsize('exitFlag');
   
    % Get algorithmic options
    minN = optOptions.MinPopulationSize;
    aRate = optOptions.PopulationArquiveRate;
    hyperparameters = optOptions.hyperparameters;
    numIndividuals = optOptions.PopulationSize;
    lbMatrix = repmat(lbRow, numIndividuals, 1);
    ubMatrix = repmat(ubRow, numIndividuals, 1);

    range = problem.DefaultIgmnOptions.range;
    outVarIndexes = problem.OutputVarIndexes;
    maxPenalty = 0.125 * mean( ...
        range(2, outVarIndexes) - range(1, outVarIndexes), 'all');
    
    objFun = @(params) evaluate(params, problem, hpNames, maxPenalty);

    state = makeOptimizationState(nhps, lbMatrix, ubMatrix, optOptions, objFun, hpIndexes);
    bestFvals = min(state.Fvals, [], "all");

    % Create a vector to store the last StallIterLimit bestFvals.
    % bestFvalsWindow is a circular buffer, so that the value from the i'th
    % iteration is stored in element with index mod(i-1,StallIterLimit)+1.
    bestFvalsWindow = nan(optOptions.StallIterLimit, 1);

    % Allow plot functions to perform any initialization tasks
    if isempty(optOptions.PlotFcns)
        haveplotfcn = false;
    else
        if coder.target('MATLAB') || coder.target('MEX')
            haveplotfcn = true;
            state.StopFlag = callPlotFcns(i_updateOptimValues, 'init');
            % check to see if any stopping criteria have been met
            exitFlag = stopOptimization(optOptions, state, bestFvalsWindow);
        else
            haveplotfcn = false;
        end
    end

    % Setup display header
    if  optOptions.Verbosity > 1
        bestFvalDisplay = bestFvals;
        meanFvalDisplay = mean(state.Fvals, 'all');
        fprintf('\n                                 Best            Mean    Stall\n');
        fprintf(  'Iteration     f-count            f(x)            f(x)    Iterations\n');
        fprintf('%5.0f         %7.0f    %12.4g    %12.4g    %5.0f\n', ...
            0, state.FunEval, bestFvalDisplay, meanFvalDisplay, 0);
        pause(0.000001);
    end

    %% Optimization
    while isempty(exitFlag)

        state.Iteration = state.Iteration + 1;

        % Reduce the population size
        numIndividuals = ceil((minN - optOptions.PopulationSize) ...
            * state.FunEval / optOptions.MaxFunEval) + optOptions.PopulationSize;
        pIdx = 1:numIndividuals;

        [~, rank] = sort(state.Fvals);
        indexes = (1:numIndividuals)';
        state.Positions = state.Positions(rank(indexes), :);
        state.Fvals = state.Fvals(rank(indexes), :);
        state.Archive = state.Archive(randperm(end, min(end, ceil(aRate * numIndividuals))), :);
        CR = randn(numIndividuals, 1) .* sqrt(0.1) + state.MCR(randi(end, numIndividuals, 1));
        CR = sort(CR);
        CR = repmat(max(0, min(1, CR)), 1, nhps);
        F = min(1, trnd(1, numIndividuals, 1) .* sqrt(0.1) + state.MF(randi(end, numIndividuals, 1)));
        while any(F <= 0)
            F(F <= 0) = min(1, trnd(1, sum(F <= 0), 1) .* sqrt(0.1) + state.MF(randi(end, sum(F <= 0), 1)));
        end
        F  = repmat(F, 1, nhps);

        mopSum = cumsum(state.MOP);
        OP1 = []; coder.varsize('OP1');
        OP2 = []; coder.varsize('OP2');
        OP3 = []; coder.varsize('OP3');
        OP = {OP1, OP2, OP3};
        for i = 1:numIndividuals
            index = find(rand <= mopSum, 1);
            OP{index} = [OP{index}, i];
        end

        newPositions = updatePositions(state, lbRow, ...
                ubRow, pIdx, numIndividuals, nhps, hyperparameters, hpIndexes, F, OP, CR);
        
        popSize = size(newPositions, 1);
        fvals = zeros(popSize, 1);
        if optOptions.UseParallel
            setenv('OMP_NUM_THREADS', '12');
            parfor (i = 1:popSize, 12)
                fvals(i) = objFun(newPositions(i, :));
            end
        else
            for i = 1:popSize
                fvals(i) = objFun(newPositions(i, :));
            end
        end 
        % Update the population and archive
        delta = state.Fvals - fvals;
        replace = delta > 0;
        state.Archive = [state.Archive; state.Positions(replace, :)];
        state.Archive = state.Archive(randperm(end, min(end, ceil(aRate * numIndividuals))), :);
        state.Positions(replace, :) = newPositions(replace, :);
        state.Fvals(replace) = fvals(replace);

        % Update CR, F, and probabilities of operators
        if any(replace)
            w = delta(replace) ./ sum(delta(replace));
            state.MCR(state.k) = (w' * CR(replace, 1) .^ 2) ./ (w' * CR(replace, 1));
            state.MF(state.k)  = (w' * F(replace, 1) .^ 2) ./ (w' * F(replace, 1));
            state.k = mod(state.k, length(state.MCR)) + 1;
        else
            state.MCR(state.k) = 0.5;
            state.MF(state.k) = 0.5;
        end
        delta = max(0, delta ./ abs(state.Fvals));
        if any(arrayfun(@(i) isempty(OP{i}), 1:length(OP)))
        	state.MOP = ones(1, 3) / 3;
        else
            mop = zeros(1, length(OP));
            for i = 1:length(OP);  mop(i) = mean(delta(OP{i}')); end
            state.MOP = max(0.1, min(0.9, mop ./ sum(mop)));
        end

        % Update state with best fvals and best individual positions.
        state = updateState(state, numIndividuals, pIdx');

        % Call plot functions
        if haveplotfcn
            if coder.target('MATLAB') || coder.target('MEX')
                state.StopFlag = callPlotFcns(i_updateOptimValues, 'iter');
            end
        else
            state.StopFlag = false;
        end

        bestFvalsWindow(1 + mod(state.Iteration - 1, optOptions.StallIterLimit)) = min(state.IndividualBestFvals);
        
        newBest = min(state.IndividualBestFvals, [], "all");
        if isfinite(newBest) && newBest < bestFvals
            bestFvals = newBest;
            state.LastImprovement = state.Iteration;
            state.LastImprovementTime = toc(state.StartTime);
        end

        % check to see if any stopping criteria have been met
        exitFlag  = stopOptimization(optOptions, state, bestFvalsWindow);
    end

    % Find and return the best solution
    [fval, indexBestFval] = min(state.IndividualBestFvals);
    x = state.IndividualBestPositions(indexBestFval, :);
    

    % Allow output and plot functions to perform any clean up tasks.
    if haveplotfcn
        if coder.target('MATLAB') || coder.target('MEX')
            callPlotFcns(i_updateOptimValues, 'done');
        end
    end

    % Nested function
    function optimValues = i_updateOptimValues
        optimValues.bestfval = min(state.IndividualBestFvals);
        optimValues.iteration = state.Iteration;
        optimValues.meanfval = meanf(state.Fvals);
        optimValues.population = state.Positions;
        optimValues.populationRange = state.PopulationRange;
        optimValues.populationfvals = state.Fvals;
        optimValues.plotFcns = state.PlotFcns;
        optimValues.hpNames = hpNames;
        optimValues.algorithm = 'IMODE';
    end
end

function newPositions = updatePositions( ...
    state, lbRow, ubRow, pIdx, numIndividuals, nhps, hyperparameters, hpIndexes, F, OP, CR) %#codegen
     % Generate parents, CR, F, and operator for each offspring
    Xp1 = state.Positions(ceil(rand(1, numIndividuals) .* max(1, 0.25 * numIndividuals)), :);
    Xp2 = state.Positions(ceil(rand(1, numIndividuals) .* max(2, 0.5 * numIndividuals)), :);
    Xr1 = state.Positions(randi(end, 1, numIndividuals), :);
    Xr3 = state.Positions(randi(end, 1, numIndividuals), :);
    P = [state.Positions; state.Archive];
    Xr2 = P(randi(end, 1, numIndividuals), :);

    % Generate offspring
    newPositions = state.Positions(:, :);
    newPositions(OP{1}, :) = state.Positions(OP{1}, :) + F(OP{1}, :) .* ...
        (Xp1(OP{1}, :) - state.Positions(OP{1}, :) + Xr1(OP{1}, :) - Xr2(OP{1}, :));
    newPositions(OP{2}, :) = state.Positions(OP{2}, :) + F(OP{2}, :) .* ...
        (Xp1(OP{2}, :) - state.Positions(OP{2}, :) + Xr1(OP{2}, :) - Xr3(OP{2}, :));
    newPositions(OP{3}, :) = F(OP{3}, :) .* (Xr1(OP{3}, :) + Xp2(OP{3}, :) - Xr3(OP{3}, :));
    if rand < 0.4
        Site = rand(size(CR)) > CR;
        newPositions(Site) = state.Positions(Site);
    else
        p1 = randi(nhps, numIndividuals, 1);
        p2 = zeros(1, numIndividuals);
        for i = 1:numIndividuals
            p2(i) = find([rand(1, nhps), 2] > CR(i, 1), 1);
        end
        for i = 1 :numIndividuals
            Site = [1:p1(i) - 1, p1(i) + p2(i):nhps];
            newPositions(i, Site) = state.Positions(i, Site);
        end
    end

    newPositions = roundDiscreteHyperparameters(newPositions, hyperparameters, hpIndexes);
    
    % Remove positions if infinite.
    tfInvalid = any(~isfinite(newPositions), 2);
    tfInvalidFull = false(numIndividuals, 1);
    tfInvalidFull(pIdx) = tfInvalid;
    newPositions(tfInvalid, :) = state.Positions(tfInvalidFull, :);

    lbMatrix = repmat(lbRow, numIndividuals, 1);
    ubMatrix = repmat(ubRow, numIndividuals, 1);
    
    % Enforce bounds on positions and return logical array to update velocities where position exceeds bounds.
    tfInvalidLB = newPositions < lbMatrix(pIdx, :);
    if any(tfInvalidLB(:))
        tfInvalidLBFull = false(numIndividuals, nhps);
        tfInvalidLBFull(pIdx, :) = tfInvalidLB;
        newPositions(tfInvalidLB) = lbMatrix(tfInvalidLBFull);
    end
    
    tfInvalidUB = newPositions > ubMatrix(pIdx,:);
    if any(tfInvalidUB(:))
        tfInvalidUBFull = false(numIndividuals,nhps);
        tfInvalidUBFull(pIdx,:) = tfInvalidUB;
        newPositions(tfInvalidUB) = ubMatrix(tfInvalidUBFull);
    end 
end

