classdef optimizeoptions
    
    properties
        hyperparameters
        Algorithm
        UseDefaultsFor
        InitialPopulation
        InitialPopulationSpan
        PlotFcns
        DisplayInterval
        Display
        PopulationSize
        UseParallel
        StallIterLimit
        StallTimeLimit
        TolFunValue
        InertiaRange
        MaxIter
        MaxTime
        MaxFunEval
        MinFractionNeighbors
        ObjectiveLimit
        SelfAdjustment
        SocialAdjustment
        MinPopulationSize
        PopulationArquiveRate
        GravitationalConstant
        Verbosity
        ExtraEvalArgs
        ExtraEvalCellArgs
    end

    methods(Static)
        function PopulationSpan = initialPopulationSpan(populationSpan, hyperparameters)
            if isempty(populationSpan)
                nvars = length(hyperparameters);
                PopulationSpan = zeros(1, nvars);
                for i = 1:nvars
                    var = hyperparameters{i};
                    span = var.ub - var.lb;
                    if var.isDiscrete; span = round(span); end
                    PopulationSpan(i) = span;
                end
            else 
                PopulationSpan = populationSpan;
            end
        end
    end
    
    methods
        function self = optimizeoptions(hyperparameters, options)
            %   hyperparameters:               An array of Hyperparameters to be used as inputs to be be used 
            %                                  directly, without optimization. Default value is [].
            %   options.Algorithm              Optimzer name as a char. Current options are 'pso' or 'imode'.
            %                                  Default is  'pso'.
            %   options.UseDefaultsFor:        An array of Hyperparameters to be used as inputs, without 
            %                                  doing any optimization. Default value is an empty cell array.
            %   options.InitialPopulation:     Initial population or partial population of individuals. 
            %                                  M-by-nvars matrix, where each row represents one individual. 
            %                                  If M < PopulationSize, then the optimization creates more 
            %                                  individuals so  that the total number is PopulationSize. 
            %                                  If M > PopulationSize, then the optimization uses  the first 
            %                                  PopulationSize rows. Default value is [].
            %   options.InitialPopulationSpan: Initial range of individual positions to be created. Can be a 
            %                                  positive scalar or a vector with nvars elements, where nvars is 
            %                                  the number of Hyperparameters. The range for any individual component 
            %                                  is -InitialPopulationSpan/2, InitialPopulationSpan/2, shifted and scaled 
            %                                  if necessary to match any hyperparameter. Default is [hyperparameter.ub
            %                                  - hyperparameter.lb].
            %   options.PlotFcns:              Function names as a cell array of char. Plot functions can plot 
            %                                  each iteration, and stop the solver, when closed. Default is 
            %                                  {'plotbestf', 'plotpopulation'}.
            %   options.Display:               Level of display returned to the command line.
            %                                    - 'off' or 'none' displays no output.
            %                                    - 'final' displays just the final output (default).
            %                                    - 'iter' gives iterative display.
            %   options.DisplayInterval:       Interval for iterative display. The iterative display prints 
            %                                  one line for every DisplayInterval iterations. Default is 1.
            %   options.PopulationSize:        The number of individualss in the population, an integer greater than 1. 
            %                                  Default is min(100, 10*nvars), where nvars is the number of 
            %                                  hyperparameters.
            %   options.UseParallel:           Compute objective function in parallel when true. Default is false.
            %   options.StallIterLimit:        Positive integer with default 20. Iterations end when the relative 
            %                                  change in best objective function value over the last StallIterLimit 
            %                                  iterations is less than options.TolFunValue.
            %   options.StallTimeLimit:        Maximum number of seconds without an improvement in the best known 
            %                                  objective function value. Positive scalar with default Inf.
            %   options.TolFunValue:           Nonnegative scalar with default 1e-6. Iterations end when the relative 
            %                                  change in best objective function value over the last StallTimeLimit 
            %                                  iterations is less than options.TolFunValue.
            %   options.InertiaRange:          Two-element real vector with same sign values in increasing order. 
            %                                  Gives the lower and upper bound of the adaptive inertia. To obtain a 
            %                                  constant (nonadaptive) inertia, set both elements of InertiaRange to 
            %                                  the same value. Default is [0.1, 1.1]. Only used in the 'pso' Algorithm.
            %   options.MaxIter:               Maximum number of iterations the optimization process takes. 
            %                                  Default is 200*nvars, where nvars is the number of hyperparameters.
            %   options.MaxFunEval:            Maximum number of fun evaluations the optimization process takes.
            %                                  Only used in the 'imode' Algorithm. The default value is 
            %                                  max(10000, options.PopulationSize * 100).
            %
            %   options.MaxTime:               Maximum time in seconds that the optimization runs. Default is Inf.
            %   options.MinFractionNeighbors:  Minimum adaptive neighborhood size, a scalar from 0 to 1. Default 
            %                                  is 0.25. Only used in the 'pso' Algorithm.
            %   options.ObjectiveLimit:        Minimum objective value, a stopping criterion. Scalar, with 
            %                                  default -Inf. Only used in the 'pso' Algorithm.
            %   options.SelfAdjustment:        Weighting of each individual s best position when adjusting 
            %                                  velocity. Finite scalar with default 1.49. Only used in the 'pso' 
            %                                  Algorithm.
            %   options.SocialAdjustment:      Weighting of the neighborhood s best position when adjusting 
            %                                  velocity. Finite scalar with default 1.49. Only used in the 'pso' 
            %                                  Algorithm.
            %   options.MinPopulationSize      Minimum population size. Only used in the 'imode' Algorithm. 
            %                                  The default value is 4. 
            %   options.PopulationArquiveRate  Ratio of archive size to population size. Only used in the 'imode' 
            %                                  Algorithm. The default value is 2.6.
            %   options.GravitationalConstant  The gravitational constant. The default value is 1.
            arguments
                hyperparameters (1,:) { ...
                    mustBeACellArrayOf(hyperparameters, 'Hyperparameter') ...
                } = [],
                options.Algorithm (1, :) char { ...
                    mustBeMember(options.Algorithm, {'pso', 'psogsa', 'imode'}) ...
                }  = 'pso',
                options.UseDefaultsFor (1,:) { ...
                    mustBeACellArrayOf(options.UseDefaultsFor, 'char') ...
                } = {},
                options.InitialPopulation (:, :) double { ...
                    mustBeNumeric, ...
                    mustBeNonNan, ... 
                    mustBeFinite ...
                } = [],
                options.InitialPopulationSpan (1, :) double { ...
                    mustBeNumeric, ...
                    mustBeNonNan, ...
                    mustBeFinite ...
                } = zeros(1, 0),
                options.PlotFuncs (1, :) { ...
                    mustBeMember(options.PlotFuncs, {...
                        'plotbestf', 'plotpopulation', 'plotscorediversity'} ...
                    ) ...
                } = {'plotbestf', 'plotpopulation'},
                options.Display (1, :) char { ...
                    mustBeMember(options.Display, {'off', 'iter', 'final'}) ...
                }  = 'iter',
                options.DisplayInterval (1, 1) double {mustBeInteger} = 1,
                options.PopulationSize (1, 1) double { ...
                    mustBeNumeric, ...
                    mustBeGreaterThan(options.PopulationSize, 1) ...
                } = min(100, 10 * length(hyperparameters)),
                options.UseParallel (1, 1) logical = false,
                options.StallIterLimit (1, 1) double {mustBeInteger, mustBePositive} = 20,
                options.StallTimeLimit (1, 1) double {mustBeNonNan, mustBePositive} = Inf,
                options.TolFunValue (1, 1) double {mustBeNonNan, mustBePositive} = 1e-6,
                options.InertiaRange (1, 2) double {mustBeNonNan, mustBePositive} = [0.1, 1.1],
                options.MaxIter (1, 1) double { ...
                    mustBeInteger, ...
                    mustBePositive ...
                } = 200 * length(hyperparameters),
                options.MaxTime (1, 1) double {mustBeNonNan, mustBePositive} = Inf,
                options.MaxFunEval (1, 1) double { ...
                    mustBeInteger, ...
                    mustBePositive ...
                } = 10000,
                options.MinFractionNeighbors (1, 1) double { ...
                    mustBeInRange(options.MinFractionNeighbors, 0, 1) ...
                } = 0.25,
                options.ObjectiveLimit (1, 1) double {mustBeNumeric, mustBeNonNan} = -Inf,
                options.SelfAdjustment (1, 1) double {mustBeFinite, mustBeNonNan} = 1.49,
                options.SocialAdjustment (1, 1) double {mustBeFinite, mustBeNonNan} = 1.49,
                options.MinPopulationSize (1, 1) double { ...
                    mustBeFinite, ...
                    mustBeNonNan, ...
                    mustBeInteger, ...
                    mustBeGreaterThan(options.MinPopulationSize, 3) ...
                } = 4,
                options.PopulationArquiveRate (1, 1) double {mustBeFinite, mustBeNonNan} = 2.6, ...
                options.GravitationalConstant (1, 1) double {mustBeFinite, mustBeNonNan} = 1, ...
                options.ExtraEvalArgs (:, :) cell = {}, ...
                options.ExtraEvalCellArgs (:, :) cell = {}
            end
            self.hyperparameters = hyperparameters;
            self.Algorithm = options.Algorithm;
            self.UseDefaultsFor = options.UseDefaultsFor;
            self.InitialPopulation = options.InitialPopulation;
            self.InitialPopulationSpan = ...
                optimizeoptions.initialPopulationSpan(options.InitialPopulationSpan, hyperparameters);
            self.PlotFcns = options.PlotFuncs;
            self.Display = options.Display;
            self.DisplayInterval = options.DisplayInterval;
            self.PopulationSize = options.PopulationSize;
            self.UseParallel = options.UseParallel;
            self.StallIterLimit = options.StallIterLimit;
            self.StallTimeLimit = options.StallTimeLimit;
            self.TolFunValue = options.TolFunValue;
            self.InertiaRange = options.InertiaRange;
            self.MaxIter = options.MaxIter;
            self.MaxTime = options.MaxTime;
            self.MaxFunEval = max(options.MaxFunEval, options.PopulationSize * 100);
            self.MinFractionNeighbors = options.MinFractionNeighbors;
            self.ObjectiveLimit = options.ObjectiveLimit;
            self.SelfAdjustment = options.SelfAdjustment;
            self.SocialAdjustment = options.SocialAdjustment;
            self.MinPopulationSize = options.MinPopulationSize;
            self.PopulationArquiveRate = options.PopulationArquiveRate;
            self.GravitationalConstant = options.GravitationalConstant;
            self.ExtraEvalArgs = options.ExtraEvalArgs;
            self.ExtraEvalCellArgs = options.ExtraEvalCellArgs;
            
            % Determine the verbosity
            switch  self.Display
                case {'off','none'}
                    self.Verbosity = 0;
                case 'final'
                    self.Verbosity = 1;
                case 'iter'
                    self.Verbosity = 2;
            end
        end
    end
end
