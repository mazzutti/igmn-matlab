% psogsa - Particle Swarm Optimization with Gravitational Search Algorithm (PSOGSA)
%
% This function implements a hybrid optimization algorithm combining Particle 
% Swarm Optimization (PSO) and Gravitational Search Algorithm (GSA) to solve 
% optimization problems. The algorithm is designed to optimize hyperparameters 
% for a given problem.
%
% Inputs:
%     problem - A structure containing the following fields:
%         OptimizeOptions - A structure with optimization options, including:
%             PopulationSize - Number of particles in the swarm.
%             SelfAdjustment - Coefficient for self-adjustment in velocity update.
%             SocialAdjustment - Coefficient for social adjustment in velocity update.
%             MinFractionNeighbors - Minimum fraction of neighbors for adaptive neighborhood size.
%             InertiaRange - Range for inertia coefficient [min, max].
%             hyperparameters - Hyperparameter bounds and types.
%             StallIterLimit - Maximum number of iterations without improvement before stopping.
%             PlotFcns - Plot functions for visualization during optimization.
%             Verbosity - Level of verbosity for displaying progress.
%             UseParallel - Boolean indicating whether to use parallel computation.
%         DefaultIgmnOptions - Default options for the IGMN algorithm, including:
%             range - Range of output variables.
%         OutputVarIndexes - Indexes of output variables.
%
% Outputs:
%     x - The best solution found by the algorithm.
%     fval - The objective function value of the best solution.
%     exitFlag - A flag indicating the reason for termination.
%
% Subfunctions:
%     psogsacore - Core implementation of the PSOGSA algorithm.
%     generateBestNeighborIndex - Generates the index of the best neighbor for each particle.
%     updateVelocities - Updates the velocities of particles based on PSO and GSA rules.
%     updatePositions - Updates the positions of particles and enforces bounds.
%     updateInertia - Updates the adaptive inertia and neighborhood size.
%     calculateMass - Calculates the mass of particles based on their fitness values.
%     updateForces - Updates the gravitational forces acting on particles.
%     updateAccelerations - Updates the accelerations of particles based on forces and mass.
%     update - Updates the state of the swarm, including positions, velocities, forces, and accelerations.
%
% Notes:
% - The algorithm uses adaptive parameters for inertia and neighborhood size to balance exploration and exploitation.
% - Parallel computation can be enabled for faster evaluation of the objective function.
% - Plot functions can be used to visualize the optimization process.
%
% Example Usage:
%     problem.OptimizeOptions = struct(...);
%     [x, fval, exitFlag] = psogsa(problem);
function [x, fval, exitFlag] = psogsa(problem) %#codegen
    
    optOptions = problem.OptimizeOptions;
    [hpNames, hpIndexes] = extractHyperarameterNames(optOptions);

    [lbRow , ubRow, nhps] =  extractBounds(optOptions.hyperparameters, hpIndexes); 

    optOptions = validateOptimizationOptions(optOptions, nhps, hpIndexes);

    % Perform check on initial population, fvals, and range
    problem.OptimizeOptions = initialPopulationCheck(optOptions);

    % Start the core algorithm
    [x, fval, exitFlag] = psogsacore(nhps, lbRow, ubRow, problem, hpNames, hpIndexes);
end

function [x,fval,exitFlag] = psogsacore(nhps, lbRow, ubRow, problem, hpNames, hpIndexes) %#codegen

    coder.extrinsic('callPlotFcns');

    optOptions = problem.OptimizeOptions;
    
    exitFlag = [];
    coder.varsize('exitFlag');

    % Get algorithmic options
    numParticles = optOptions.PopulationSize;
    cSelf = optOptions.SelfAdjustment;
    cSocial = optOptions.SocialAdjustment;

    minNeighborhoodSize = max(2, floor(numParticles * optOptions.MinFractionNeighbors));
    minInertia = optOptions.InertiaRange(1);
    maxInertia = optOptions.InertiaRange(2);
    hyperparameters = optOptions.hyperparameters;

    lbMatrix = repmat(lbRow, numParticles, 1);
    ubMatrix = repmat(ubRow, numParticles, 1);

    range = problem.DefaultIgmnOptions.range;
    outVarIndexes = problem.OutputVarIndexes;
    maxPenalty = 0.1 * mean( ...
        range(2, outVarIndexes) - range(1, outVarIndexes), 'all');

    objFun = @(params) evaluate(params, problem, hpNames, maxPenalty);
      
    % Create initial state: particle positions & velocities, fvals, status data
    state = makeOptimizationState(nhps, lbMatrix, ubMatrix, optOptions, objFun, hpIndexes);

    bestFvals = min(state.Fvals, [], "all");
    % Create a vector to store the last StallIterLimit bestFvals.
    % bestFvalsWindow is a circular buffer, so that the value from the i'th
    % iteration is stored in element with index mod(i-1,StallIterLimit)+1.
    bestFvalsWindow = nan(optOptions.StallIterLimit, 1);

    % Initialize adaptive parameters:
    %   initial inertia = maximum *magnitude* inertia
    %   initial neighborhood size = minimum neighborhood size
    adaptiveInertiaCounter = 0;
    if all(optOptions.InertiaRange >= 0)
        adaptiveInertia = maxInertia;
    elseif all(optOptions.InertiaRange <= 0)
        adaptiveInertia = minInertia;
    else
        % checkfield should prevent InertiaRange from having positive and
        % negative vlaues.
        error('The InertiaRange option should not contain both positive and negative numbers.');
    end
    adaptiveNeighborhoodSize = minNeighborhoodSize;

  
    % Allow plot functions to perform any initialization tasks
    if isempty(optOptions.PlotFcns)
        haveplotfcn = false;
    else
        if coder.target('MATLAB') || coder.target('MEX')
            haveplotfcn = true;
            state.StopFlag = false;
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

    pIdx = (1:numParticles)';

    % Run the main loop until some exit condition becomes true
    while isempty(exitFlag)
        state.Iteration = state.Iteration + 1;

        bestNeighborIndex = generateBestNeighborIndex(state, adaptiveNeighborhoodSize, numParticles);
        G = optOptions.GravitationalConstant * exp(-23 * state.Iteration / optOptions.MaxIter);

        % Update velocities, positions, forces, accelarations and mass.
        state = update(state, adaptiveInertia, bestNeighborIndex, ...
            cSelf, cSocial, pIdx, numParticles, nhps, lbMatrix, ubMatrix, hyperparameters, hpIndexes, G);

        pos = state.Positions;
        popSize = size(pos, 1);
        fvals = zeros(popSize, 1);
        if optOptions.UseParallel
            parfor (i = 1:popSize)
                fvals(i) = objFun(pos(i, :));
            end
        else
            for i = 1:popSize
                fvals(i) = objFun(pos(i, :));
            end
        end

        state.Fvals = fvals(:);

        % Update state with best fvals and best individual positions.
        state = updateState(state, numParticles, pIdx);

        bestFvalsWindow(1 + mod(state.Iteration - 1, optOptions.StallIterLimit)) = min(state.IndividualBestFvals);

        [state, adaptiveInertiaCounter, bestFvals, adaptiveNeighborhoodSize, adaptiveInertia] = ...
              updateInertia(state, minInertia, maxInertia, bestFvals, ...
              adaptiveInertiaCounter, adaptiveNeighborhoodSize, adaptiveInertia, numParticles, minNeighborhoodSize);

        % Call plot functions
        if haveplotfcn
            if coder.target('MATLAB') || coder.target('MEX')
                state.StopFlag = callPlotFcns(i_updateOptimValues, 'iter');
            end
        else
            state.StopFlag = false;
        end

        % check to see if any stopping criteria have been met
        exitFlag = stopOptimization(optOptions, state, bestFvalsWindow);
    end % End while loop


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
        optimValues.algorithm = 'PSOGSA';
    end

end % End function pswcore

function bestNeighborIndex = generateBestNeighborIndex(state ,adaptiveNeighborhoodSize, numParticles) %#codegen
    % Generate the particle index corresponding to the best particle in random
    % neighborhood. The size of the random neighborhood is controlled by the
    % adaptiveNeighborhoodSize parameter.

    neighborIndex = zeros(numParticles, adaptiveNeighborhoodSize);
    neighborIndex(:, 1) = 1:numParticles; % First neighbor is self
    for i = 1:numParticles
        % Determine random neighbors that exclude the particle itself,
        % which is (numParticles-1) particles
        neighbors = randperm(numParticles - 1, adaptiveNeighborhoodSize - 1);
        % Add 1 to indicies that are >= current particle index
        iShift = neighbors >= i;
        neighbors(iShift) = neighbors(iShift) + 1;
        neighborIndex(i, 2:end) = neighbors;
    end
    % Identify the best neighbor
    [~, bestRowIndex] = min(state.IndividualBestFvals(neighborIndex), [], 2);
    % Create the linear index into neighborIndex
    bestLinearIndex = (bestRowIndex.' - 1) .* numParticles + (1:numParticles);
    bestNeighborIndex = neighborIndex(bestLinearIndex);
end

function newVelocities = updateVelocities(state, adaptiveInertia, bestNeighborIndex, cSelf, cSocial, pIdx, nhps) %#codegen
    % Update the velocities of particles with indices pIdx, according to an
    % update rule.

    % Generate random number distributions for Self and Social components
    randSelf = rand(numel(pIdx), nhps);
    randSocial = rand(numel(pIdx), nhps);

    oldVelocities = state.Velocities(pIdx,:);
    accelerations = state.Accelerations(pIdx,:);

    % Update rule
    newVelocities = adaptiveInertia * oldVelocities + ...
        cSelf * randSelf .* accelerations .* (state.IndividualBestPositions(pIdx,:) - state.Positions(pIdx,:)) + ...
        cSocial * randSocial .* (state.IndividualBestPositions(bestNeighborIndex(pIdx), :) - state.Positions(pIdx,:));

    % Ignore infinite velocities
    tfInvalid = ~all(isfinite(newVelocities), 2);
    newVelocities(tfInvalid) = oldVelocities(tfInvalid);
end

function [newPositions, tfInvalid] = updatePositions( ...
    state, lbMatrix, ubMatrix, pIdx, numParticles, nhps, hyperparameters, hpIndexes) %#codegen
    % Update positions of particles with indices pIdx.

    newPositions = state.Positions(pIdx, :) + state.Velocities(pIdx, :);

    % Remove positions if infinite.
    tfInvalid = any(~isfinite(newPositions), 2);
    tfInvalidFull = false(numParticles, 1);
    tfInvalidFull(pIdx) = tfInvalid;
    newPositions(tfInvalid, :) = state.Positions(tfInvalidFull, :);

    % Enforce bounds on positions and return logical array to update velocities where position exceeds bounds.
    tfInvalidLB = newPositions < lbMatrix(pIdx, :);
    if any(tfInvalidLB(:))
        tfInvalidLBFull = false(numParticles, nhps);
        tfInvalidLBFull(pIdx, :) = tfInvalidLB;
        newPositions(tfInvalidLB) = lbMatrix(tfInvalidLBFull);
        tfInvalid = tfInvalidLBFull;
    else
        tfInvalid = false(numParticles,nhps);
    end

    tfInvalidUB = newPositions > ubMatrix(pIdx,:);
    if any(tfInvalidUB(:))
        tfInvalidUBFull = false(numParticles,nhps);
        tfInvalidUBFull(pIdx,:) = tfInvalidUB;
        newPositions(tfInvalidUB) = ubMatrix(tfInvalidUBFull);
        tfInvalid = tfInvalid | tfInvalidUBFull;
    end

    newPositions = roundDiscreteHyperparameters(newPositions, hyperparameters, hpIndexes);
end

function [state,adaptiveInertiaCounter,bestFvals,adaptiveNeighborhoodSize,adaptiveInertia] = ...
    updateInertia(state,minInertia,maxInertia,bestFvals, ...
        adaptiveInertiaCounter, adaptiveNeighborhoodSize,adaptiveInertia,numParticles,minNeighborhoodSize) %#codegen
    % Keep track of improvement in bestFvals and update the adaptive
    % parameters according to the approach described in S. Iadevaia et
    % al. Cancer Res 2010;70:6704-6714 and M. Liu, D. Shin, and H. I.
    % Kang. International Conference on Information, Communications and
    % Signal Processing 2009:1-5.
    newBest = min(state.IndividualBestFvals, [], "all");
    if isfinite(newBest) && newBest < bestFvals 
        bestFvals = newBest;
        state.LastImprovement = state.Iteration;
        state.LastImprovementTime = toc(state.StartTime);
        adaptiveInertiaCounter = max(0, adaptiveInertiaCounter - 1);
        adaptiveNeighborhoodSize = minNeighborhoodSize;
    else
        adaptiveInertiaCounter = adaptiveInertiaCounter + 1;
        adaptiveNeighborhoodSize = min(numParticles, adaptiveNeighborhoodSize + minNeighborhoodSize);
    end

    % Update the inertia coefficient, enforcing limits (Since inertia
    % can be negative, enforcing both upper *and* lower bounds after
    % multiplying.)
    if adaptiveInertiaCounter < 2
        adaptiveInertia = max(minInertia, min(maxInertia, 2 * adaptiveInertia));
    elseif adaptiveInertiaCounter > 5
        adaptiveInertia = max(minInertia, min(maxInertia, 0.5 * adaptiveInertia));
    end
end

function mass = calculateMass(state, numParticles) %#codegen
    fvals = state.Fvals;
    best = min(fvals, [], 'all');
    worst = max(fvals, [], 'all');
    mass = (fvals - 0.99 .* worst) ./ (best - worst);
    for i = 1:numParticles
        mass(i) = mass(i) * 5 / sum(mass);    
    end
end

function newForces = updateForces(state, nhps, G, pIdx) %#codegen
    np = numel(pIdx);
    pos = state.Positions(pIdx, :);
    newForces = state.Forces(pIdx, :);
    repMass = repmat(state.Mass(pIdx), 1, nhps);
    diffs = cell(1, np);
    for i = 1:np; diffs{i} = pos - pos(i, :); end

    for i = 1:np
        diffMatrix = diffs{i};
        diffIndexes = diffMatrix ~= 0;
        for j = 1:nhps
            indexes = diffIndexes(:, j);
            diff = diffMatrix(indexes, j);
            diff = diff ./ abs(diff);
            r = randn(sum(indexes, 'all'), 1);
            newForces(pIdx(i), j) = newForces(pIdx(i), j) + sum(r .* G .* repMass(indexes) .* repMass(i, 1) .* diff);
        end
    end
end

function newAccelerations = updateAccelerations(state, pIdx) %#codegen
    newAccelerations = state.Accelerations(pIdx, :);
    mass = state.Mass(pIdx);
    forces = state.Forces(pIdx, :);
    nonZeroMass = mass ~= 0;
    newAccelerations(nonZeroMass, :) = forces(nonZeroMass, :) ./ mass(nonZeroMass, 1);
end

function state = update(state, adaptiveInertia, bestNeighborIndex, cSelf, ...
    cSocial, pIdx, numParticles, nhps, lbMatrix, ubMatrix, hyperparameters, hpIndexes, G) %#codegen

    % Calculate mass
    state.Mass(pIdx, :) = calculateMass(state, numParticles);

    % Update forces
    state.Forces(pIdx, :) = updateForces(state, nhps, G, pIdx);

    % Update Accelerations
    state.Accelerations(pIdx, :) = updateAccelerations(state, pIdx);

    % Update the velocities.
    state.Velocities(pIdx, :) = updateVelocities( ...
        state, adaptiveInertia, bestNeighborIndex, cSelf, cSocial, pIdx, nhps);

    % Update the positions.
    [state.Positions(pIdx, :), tfInvalid] = updatePositions( ...
        state, lbMatrix, ubMatrix, pIdx, numParticles, nhps, hyperparameters, hpIndexes);

    % For any particle on the boundary, enforce velocity = 0.
    if any(tfInvalid(:))
        state.Velocities(tfInvalid) = 0;
    end
end
