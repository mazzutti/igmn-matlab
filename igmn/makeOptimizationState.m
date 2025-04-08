% makeOptimizationState - Initializes the optimization state structure for an optimization algorithm.
%
% Syntax:
%   state = makeOptimizationState(nhps, lbMatrix, ubMatrix, optOptions, objFun, hpIndexes)
%
% Inputs:
%   nhps       - Number of hyperparameters (scalar).
%   lbMatrix   - Lower bounds matrix for the hyperparameters (matrix of size [1, nhps]).
%   ubMatrix   - Upper bounds matrix for the hyperparameters (matrix of size [1, nhps]).
%   optOptions - Structure containing optimization options, including:
%                - PopulationSize: Number of individuals in the population.
%                - Algorithm: Algorithm type ('pso', 'psogsa', etc.).
%                - InitialPopulation: Initial population matrix (optional).
%                - InitialPopulationSpan: Span for initializing velocities.
%                - PlotFcns: Plot functions for visualization (optional).
%                - UseParallel: Boolean flag for parallel computation.
%                - Verbosity: Verbosity level for logging.
%   objFun     - Objective function handle to evaluate the fitness of individuals.
%   hpIndexes  - Indices of hyperparameters (vector).
%
% Outputs:
%   state - Structure containing the optimization state, including:
%           - PopulationRange: Range of the population ([lb; ub]).
%           - Iteration: Current generation counter.
%           - StartTime: Start time of the optimization process.
%           - StopFlag: Flag to indicate termination of optimization.
%           - LastImprovement: Counter for the last generation with improvement.
%           - LastImprovementTime: Time since the last improvement.
%           - FunEval: Total number of function evaluations.
%           - Fvals: Objective function values for the population.
%           - IndividualBestFvals: Best objective function values for individuals.
%           - IndividualBestPositions: Best positions of individuals.
%           - PlotFcns: Plot functions for visualization.
%           - Velocities: Velocities of individuals (for PSO-based algorithms).
%           - Accelerations: Accelerations of individuals (for PSOGSA algorithm).
%           - Mass: Mass of individuals (for PSOGSA algorithm).
%           - Forces: Forces acting on individuals (for PSOGSA algorithm).
%           - Archive: Archive for storing additional data (optional).
%           - MCR: Memory control rate for optimization.
%           - MF: Mutation factor for optimization.
%           - k: Counter for specific optimization processes.
%           - MOP: Multi-objective optimization parameters.
%           - Positions: Current positions of individuals in the population.
%
% Description:
%   This function initializes the optimization state structure for use in
%   optimization algorithms such as PSO (Particle Swarm Optimization) and
%   PSOGSA (Particle Swarm Optimization with Gravitational Search Algorithm).
%   It sets up the initial population, velocities, and other algorithm-specific
%   parameters. The function also enforces bounds on the population and evaluates
%   the objective function for the initial population.
%
% See also:
%   createUniformPopulation
function state = makeOptimizationState(nhps, lbMatrix, ubMatrix, optOptions, objFun, hpIndexes) %#codegen
    % Create an initial set of individuals and objective function values

    % makeOptimizationState needs the vector of bounds, not the expanded matrix.
    lb = lbMatrix(1, :);
    ub = ubMatrix(1, :);

    % A variety of data used in various places
    state = struct;
    state.PopulationRange = [lb; ub];
    state.Iteration = 0; % current generation counter
    state.StartTime = tic; % tic identifier
    state.StopFlag = false; % OutputFcns flag to end the optimization
    state.LastImprovement = 1; % generation stall counter
    state.LastImprovementTime = 0; % stall time counter
    state.FunEval = 0;
    state.Fvals = [];
    state.IndividualBestFvals = [];
    state.IndividualBestPositions = [];
    state.PlotFcns = optOptions.PlotFcns;
    state.Velocities = [];
    state.Accelerations = [];
    state.Mass = [];
    state.Forces = [];
    state.Archive = [];
    state.MCR = zeros(20 * nhps, 1) + 0.2;
    state.MF = zeros(20 * nhps, 1) + 0.2;
    state.k = 1;
    state.MOP = ones(1, 3) / 3;
     
    coder.varsize('state.Archive');
    coder.varsize('state.Velocities');
    coder.varsize('state.Accelerations');
    coder.varsize('state.Forces');
    coder.varsize('state.Mass');
    coder.varsize('state.Fvals');
    coder.varsize('state.IndividualBestFvals');
    coder.varsize('state.IndividualBestPositions');

    numIndividuals = optOptions.PopulationSize;

    if strcmp(optOptions.Algorithm, 'pso') || strcmp(optOptions.Algorithm, 'psogsa')
        % Initialize velocities by randomly sampling over the smaller of
        % options.InitialPopulationSpan or ub-lb. Note that min will be
        % InitialPopulationSpan if either lb or ub is not finite.
        vmax = min(ub-lb, optOptions.InitialPopulationSpan);
        state.Velocities = repmat(-vmax, numIndividuals, 1) + ...
            repmat(2 * vmax, numIndividuals, 1) .* rand(numIndividuals, nhps);
    end

    if strcmp(optOptions.Algorithm, 'psogsa')
        state.Accelerations = zeros(numIndividuals, nhps);
        state.Forces = zeros(numIndividuals, nhps);
        state.Mass = zeros(numIndividuals, 1);
    end

    % If InitialPopulation is partly empty use the creation function to generate
    % population (CreationFcn can utilize InitialPopulation)
    if numIndividuals ~= size(optOptions.InitialPopulation, 1)
        problemStruct = struct( ...
            'objective', objFun, ...
            'nhps', nhps, ...
            'lb', lb, ...
            'ub', ub, ...
            'rngstate', [], ...
            'options', optOptions...
        );
        state.Positions = createUniformPopulation(problemStruct, hpIndexes);
    else % the initial population was passed in!
        state.Positions = optOptions.InitialPopulation;
    end

    % Enforce bounds
    if any(any(state.Positions < lbMatrix)) || any(any(state.Positions > ubMatrix))
        state.Positions = max(lbMatrix, state.Positions);
        state.Positions = min(ubMatrix, state.Positions);
        if optOptions.Verbosity > 1
            fprintf('igmn:optimization:shiftX0ToBnds');
        end
    end

    % Calculate the objective function for all individuals.
    popSize = size(state.Positions, 1);
    fvals = zeros(popSize, 1);
    pos = state.Positions;
    if optOptions.UseParallel
        parfor i = 1:popSize
            fvals(i) = objFun(pos(i, :)); %#ok<PFBNS>
        end
    else
        for i = 1:popSize
            fvals(i) = objFun(pos(i, :));
        end
    end
    % Concatenate the fvals of the first individual to the rest
    state.Fvals = fvals(:);
    state.FunEval = numIndividuals;

    state.IndividualBestFvals = state.Fvals;
    state.IndividualBestPositions = state.Positions;
end % function makeState


