% transpile - Transpile MATLAB code to MEX functions using MATLAB Coder.
%
%   transpile(options) generates MEX functions for various entry points
%   ('predict', 'classify', 'train', 'igmnBuilder', and optionally 'optimize')
%   based on the provided options. The function uses MATLAB Coder to
%   configure and compile the code for performance optimization.
%
%   INPUT:
%       options - A structure of type 'compileoptions' containing the
%                 following fields:
%           - EnableReport: Boolean, enables or disables the generation of
%                           a code generation report.
%           - EnableRecompile: Boolean, forces recompilation of MEX files
%                              if set to true.
%           - IsClassification: Boolean, specifies whether the task is
%                               classification or regression.
%           - IsOptimization: Boolean, specifies whether optimization
%                             routines should be compiled.
%           - NumberOfVariables: Integer, the total number of input
%                                variables.
%           - NumberOfOutputVars: Integer, the number of output variables.
%           - trainSize: Integer, the size of the training dataset.
%           - testSize: Integer, the size of the testing dataset.
%           - allDataSize: Integer, the size of the complete dataset
%                          (used for optimization).
%
%   FUNCTIONALITY:
%       - Configures MATLAB Coder with various optimization settings such
%         as parallelization, variable sizing, and report generation.
%       - Defines argument types for entry points ('predict', 'classify',
%         'train', 'igmnBuilder', and 'optimize') based on the provided
%         options.
%       - Invokes MATLAB Coder to generate MEX files for the specified
%         entry points.
%
%   ENTRY POINTS:
%       - 'predict' or 'classify': Generates MEX files for prediction or
%         classification tasks based on the 'IsClassification' flag.
%       - 'train': Generates MEX files for training the IGMN model.
%       - 'igmnBuilder': Generates MEX files for building IGMN options.
%       - 'optimize': (Optional) Generates MEX files for optimization
%         routines if 'IsOptimization' is true.
%
%   NOTES:
%       - The function checks for the existence of MEX files before
%         recompiling, unless 'EnableRecompile' is set to true.
%       - The function supports heterogeneous data types and variable
%         sizing for flexibility in input data.
%
%   EXAMPLES:
%       options = compileoptions();
%       options.EnableReport = true;
%       options.EnableRecompile = false;
%       options.IsClassification = true;
%       options.NumberOfVariables = 10;
%       options.NumberOfOutputVars = 2;
%       options.trainSize = 1000;
%       options.testSize = 200;
%       transpile(options);
%
%   See also: coder.CodeConfig, coder.newtype, codegen
function transpile(options)
    arguments
        options (1, 1) compileoptions;
    end

    %% Create configuration object of class 'coder.MexCodeConfig'.
    cfg = coder.CodeConfig();
    cfg.NumberOfCpuThreads = 24;
    cfg.EnableAutoParallelization = true;
    cfg.OptimizeReductions = true;
    cfg.GenerateReport = options.EnableReport;
    cfg.ReportPotentialDifferences = false;
    % cfg.EnableMexProfiling = options.EnableProfile;
    cfg.EnableVariableSizing = true;
    % cfg.SIMDAcceleration = 'Full';

    % cfg.IntegrityChecks = false;
    % cfg.ExtrinsicCalls = false;
    % cfg.ResponsivenessChecks = false;
    % cfg.GlobalDataSyncMethod = 'NoSync';

    % cfg.TargetLang = 'C++';
    % cfg.TargetLangStandard = 'C++11 (ISO)';
    % cfg.DynamicMemoryAllocationInterface = 'C++';
    % % cfg.CppNamespaceForMathworksCode = 'igmn_api';
    % % cfg.CppNamespace = 'igmn_api';
    % cfg.CppInterfaceStyle = 'Methods';
    % cfg.CppInterfaceClassName = 'NeuralModel';
    % cfg.GenerateExampleMain = 'GenerateCodeAndCompile';

    numberOfVars = options.NumberOfVariables;
    numberOfOutputVars = options.NumberOfOutputVars;
    enableRecompile = options.EnableRecompile;
    isClassification = options.IsClassification;
    isOptimization = options.IsOptimization;
    trainSize = options.trainSize;
    testSize = options.testSize;

    %% Define argument types for entry-point 'predict' or 'classify'.
    ARGS = cell(1,1);
    if isClassification; ARGS{1} = cell(3, 1); else; ARGS{1} = cell(4, 1); end
    ARGS{1}{1} = coder.newtype('igmn');
    ARGS{1}{1}.Properties.name = coder.typeof('X', [1, 4]);
    ARGS{1}{1}.Properties.dimension = coder.typeof(0);
    ARGS{1}{1}.Properties.maxDistance = coder.typeof(0);
    ARGS{1}{1}.Properties.initialCov = coder.typeof(0, [numberOfVars, numberOfVars], [0, 0]);
    ARGS{1}{1}.Properties.initialInvCov = coder.typeof(0, [numberOfVars, numberOfVars], [0, 0]);
    ARGS{1}{1}.Properties.initialLogDet = coder.typeof(0);
    ARGS{1}{1}.Properties.minCov = coder.typeof(0, [numberOfVars, numberOfVars], [0, 0]);
    ARGS{1}{1}.Properties.useRankOne = coder.typeof(false);
    ARGS{1}{1}.Properties.converged = coder.typeof(false);
    ARGS{1}{1}.Properties.range = coder.typeof(0, [2, numberOfVars], [0, 0]);
    ARGS{1}{1}.Properties.nc = coder.typeof(0);
    ARGS{1}{1}.Properties.numSamples = coder.typeof(0);
    ARGS{1}{1}.Properties.delta = coder.typeof(0);
    ARGS{1}{1}.Properties.gamma = coder.typeof(0);
    ARGS{1}{1}.Properties.phi = coder.typeof(0);
    ARGS{1}{1}.Properties.tau = coder.typeof(0);
    ARGS{1}{1}.Properties.spMin = coder.typeof(0);
    ARGS{1}{1}.Properties.vMin = coder.typeof(0);
    ARGS{1}{1}.Properties.maxNc = coder.typeof(0);
    ARGS{1}{1}.Properties.priors = coder.typeof(0, [1, inf], [0, 1]);
    ARGS{1}{1}.Properties.means = coder.typeof(0, [inf, numberOfVars], [1, 0]);
    ARGS{1}{1}.Properties.covs = coder.typeof(0, [numberOfVars, numberOfVars, inf], [0, 0, 1]);
    ARGS{1}{1}.Properties.invCovs = coder.typeof(0, [numberOfVars, numberOfVars, inf], [0, 0, 1]);
    ARGS{1}{1}.Properties.logDets = coder.typeof(0, [1, inf], [0, 1]);
    ARGS{1}{1}.Properties.sp = coder.typeof(0, [1, inf], [0, 1]);
    ARGS{1}{1}.Properties.spu = coder.typeof(0, [1, inf], [0, 1]);
    ARGS{1}{1}.Properties.vs = coder.typeof(0, [1, inf], [0, 1]);
    ARGS{1}{1}.Properties.distances = coder.typeof(0, [1, inf], [0, 1]);
    ARGS{1}{1}.Properties.logLikes = coder.typeof(0, [1, inf], [0, 1]);
    ARGS{1}{1}.Properties.posteriors = coder.typeof(0, [1, inf], [0, 1]);
    ARGS{1}{2} = coder.typeof(0, [testSize, numberOfVars - numberOfOutputVars], [~isfinite(testSize), 0]);
    ARGS{1}{3} = coder.typeof(0, [1, numberOfOutputVars], [0, 0]);
    if isClassification
        if ~exist('classify_mex', 'file') || enableRecompile
            codegen -config cfg classify -args ARGS{1}
        end
    else
        if ~exist('predict_mex', 'file') || enableRecompile
            ARGS{1}{4} = coder.typeof(0);
            codegen -config cfg predict -args ARGS{1}
        end
    end
   

    %% Define argument types for entry-point 'train'.
    ARGS{1} = cell(1, 1);
    ARGS{1}{1} = coder.newtype('igmn');
    ARGS{1}{1}.Properties.name = coder.typeof('X', [1, 4]);
    ARGS{1}{1}.Properties.dimension = coder.typeof(0);
    ARGS{1}{1}.Properties.maxDistance = coder.typeof(0);
    ARGS{1}{1}.Properties.initialCov = coder.typeof(0, [numberOfVars, numberOfVars], [0, 0]);
    ARGS{1}{1}.Properties.minCov = coder.typeof(0, [numberOfVars, numberOfVars], [0, 0]);
    ARGS{1}{1}.Properties.initialInvCov = coder.typeof(0, [numberOfVars, numberOfVars], [0, 0]);
    ARGS{1}{1}.Properties.initialLogDet = coder.typeof(0);
    ARGS{1}{1}.Properties.useRankOne = coder.typeof(false);
    ARGS{1}{1}.Properties.converged = coder.typeof(false);
    ARGS{1}{1}.Properties.range = coder.typeof(0, [2, numberOfVars], [0, 0]);
    ARGS{1}{1}.Properties.nc = coder.typeof(0);
    ARGS{1}{1}.Properties.numSamples = coder.typeof(0);
    ARGS{1}{1}.Properties.delta = coder.typeof(0);
    ARGS{1}{1}.Properties.gamma = coder.typeof(0);
    ARGS{1}{1}.Properties.phi = coder.typeof(0);
    ARGS{1}{1}.Properties.tau = coder.typeof(0);
    ARGS{1}{1}.Properties.spMin = coder.typeof(0);
    ARGS{1}{1}.Properties.vMin = coder.typeof(0);
    ARGS{1}{1}.Properties.maxNc = coder.typeof(0);
    ARGS{1}{1}.Properties.priors = coder.typeof(0, [1, inf], [0, 1]);
    ARGS{1}{1}.Properties.means = coder.typeof(0, [inf, numberOfVars], [1, 1]);
    ARGS{1}{1}.Properties.covs = coder.typeof(0, [numberOfVars, numberOfVars, inf], [0, 0, 1]);
    ARGS{1}{1}.Properties.invCovs = coder.typeof(0, [numberOfVars, numberOfVars, inf], [0, 0, 1]);
    ARGS{1}{1}.Properties.logDets = coder.typeof(0, [1, inf], [0, 1]);
    ARGS{1}{1}.Properties.sp = coder.typeof(0, [1, inf], [0, 1]);
    ARGS{1}{1}.Properties.spu = coder.typeof(0, [1, inf], [0, 1]);
    ARGS{1}{1}.Properties.vs = coder.typeof(0, [1, inf], [0, 1]);
    ARGS{1}{1}.Properties.distances = coder.typeof(0, [1, inf], [0, 1]);
    ARGS{1}{1}.Properties.logLikes = coder.typeof(0, [1, inf], [0, 1]);
    ARGS{1}{1}.Properties.posteriors = coder.typeof(0, [1, inf], [0, 1]);
    ARGS{1}{2} = coder.typeof(0, [trainSize, numberOfVars], [~isfinite(trainSize), 0]); %#ok<*NASGU>
    
    %% Invoke MATLAB Coder.
    if ~exist('train_mex', 'file') || enableRecompile
        codegen -config cfg train -args ARGS{1}
    end

    %% Define argument types for entry-point 'igmnBuilder'.
    ARGS = cell(1, 1);
    ARGS{1} = cell(1, 1);
    ARGS{1}{1} = coder.newtype('igmnoptions');
    ARGS{1}{1}.Properties.range = coder.typeof(0, [2, numberOfVars], [0, 0]);
    ARGS{1}{1}.Properties.Tau = coder.typeof(0);
    ARGS{1}{1}.Properties.Delta = coder.typeof(0);
    ARGS{1}{1}.Properties.Gamma = coder.typeof(0);
    ARGS{1}{1}.Properties.Phi = coder.typeof(0);
    ARGS{1}{1}.Properties.SPMin = coder.typeof(0);
    ARGS{1}{1}.Properties.MaxNc = coder.typeof(0);
    ARGS{1}{1}.Properties.VMin = coder.typeof(0);
    ARGS{1}{1}.Properties.RegValue = coder.typeof(0);
    ARGS{1}{1}.Properties.UseRankOne = coder.typeof(0);
    
    %% Invoke MATLAB Coder.
    if ~exist('igmnBuilder_mex', 'file') || enableRecompile
        codegen -config cfg igmnBuilder -args ARGS{1}
    end
    
    if isOptimization
        %% Define argument types for entry-point 'optimize'.
        ARGS = cell(1, 1);
        ARGS{1} = cell(1, 1);
        ARGS{1}{1} = coder.newtype('Problem');
        ARGS{1}{1}.Properties.trainData = coder.typeof(0, [trainSize, numberOfVars], [~isfinite(trainSize), 0]);
        ARGS{1}{1}.Properties.testData = coder.typeof(0, [testSize, numberOfVars], [~isfinite(testSize), 0]);
        ARGS{1}{1}.Properties.UseMex = coder.typeof(false);
        ARGS{1}{1}.Properties.DoParametersTuning = coder.typeof(false);
        ARGS{1}{1}.Properties.AllData = coder.typeof(0, ...
            [options.allDataSize, numberOfVars], [~isfinite(trainSize) | ~isfinite(testSize), 0]);
        ARGS{1}{1}.Properties.InputVarIndexes = coder.typeof(0, [1, numberOfVars - numberOfOutputVars], [0, 0]);
        ARGS{1}{1}.Properties.OutputVarIndexes = coder.typeof(0, [1, numberOfOutputVars], [0, 0]);
        ARGS{1}{1}.Properties.DefaultIgmnOptions = coder.newtype('igmnoptions');
        ARGS{1}{1}.Properties.DefaultIgmnOptions.Properties.range = coder.typeof(0, [2, numberOfVars], [0, 0]);
        ARGS{1}{1}.Properties.DefaultIgmnOptions.Properties.Tau = coder.typeof(0);
        ARGS{1}{1}.Properties.DefaultIgmnOptions.Properties.Delta = coder.typeof(0);
        ARGS{1}{1}.Properties.DefaultIgmnOptions.Properties.Gamma = coder.typeof(0);
        ARGS{1}{1}.Properties.DefaultIgmnOptions.Properties.Phi = coder.typeof(0);
        ARGS{1}{1}.Properties.DefaultIgmnOptions.Properties.SPMin = coder.typeof(0);
        ARGS{1}{1}.Properties.DefaultIgmnOptions.Properties.VMin = coder.typeof(0);
        ARGS{1}{1}.Properties.DefaultIgmnOptions.Properties.MaxNc = coder.typeof(0);
        ARGS{1}{1}.Properties.DefaultIgmnOptions.Properties.RegValue = coder.typeof(0);
        ARGS{1}{1}.Properties.DefaultIgmnOptions.Properties.UseRankOne = coder.typeof(0);
        ARGS{1}{1}.Properties.CompileOptions = coder.newtype('compileoptions');
        ARGS{1}{1}.Properties.CompileOptions.Properties.trainSize = coder.typeof(0);
        ARGS{1}{1}.Properties.CompileOptions.Properties.testSize = coder.typeof(0);
        ARGS{1}{1}.Properties.CompileOptions.Properties.allDataSize = coder.typeof(0);
        ARGS{1}{1}.Properties.CompileOptions.Properties.EnableProfile = coder.typeof(false);
        ARGS{1}{1}.Properties.CompileOptions.Properties.EnableReport = coder.typeof(false);
        ARGS{1}{1}.Properties.CompileOptions.Properties.EnableRecompile = coder.typeof(false);
        ARGS{1}{1}.Properties.CompileOptions.Properties.IsClassification = coder.typeof(false);
        ARGS{1}{1}.Properties.CompileOptions.Properties.IsOptimization = coder.typeof(false);
        ARGS{1}{1}.Properties.CompileOptions.Properties.NumberOfVariables = coder.typeof(0);
        ARGS{1}{1}.Properties.CompileOptions.Properties.NumberOfOutputVars = coder.typeof(0);
        ARGS{1}{1}.Properties.OptimizeOptions = coder.newtype('optimizeoptions');
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameter = cell([1, 9]);
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{1} = coder.newtype('Hyperparameter');
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{1}.Properties.value = coder.typeof(0);
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{1}.Properties.name = coder.typeof('X', [1, inf], [0, 1]);
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{1}.Properties.lb = coder.typeof(0);
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{1}.Properties.ub = coder.typeof(0);
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{1}.Properties.isDiscrete = coder.typeof(false);
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{2} = coder.newtype('Hyperparameter');
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{2}.Properties.value = coder.typeof(0);
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{2}.Properties.name = coder.typeof('X', [1, inf], [0, 1]);
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{2}.Properties.lb = coder.typeof(0);
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{2}.Properties.ub = coder.typeof(0);
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{2}.Properties.isDiscrete = coder.typeof(false);
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{3} = coder.newtype('Hyperparameter');
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{3}.Properties.value = coder.typeof(0);
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{3}.Properties.name = coder.typeof('X', [1, inf], [0, 1]);
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{3}.Properties.lb = coder.typeof(0);
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{3}.Properties.ub = coder.typeof(0);
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{3}.Properties.isDiscrete = coder.typeof(false);
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{4} = coder.newtype('Hyperparameter');
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{4}.Properties.value = coder.typeof(0);
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{4}.Properties.name = coder.typeof('X', [1, inf], [0, 1]);
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{4}.Properties.lb = coder.typeof(0);
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{4}.Properties.ub = coder.typeof(0);
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{4}.Properties.isDiscrete = coder.typeof(false);
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{5} = coder.newtype('Hyperparameter');
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{5}.Properties.value = coder.typeof(0);
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{5}.Properties.name = coder.typeof('X', [1, inf], [0, 1]);
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{5}.Properties.lb = coder.typeof(0);
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{5}.Properties.ub = coder.typeof(0);
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{5}.Properties.isDiscrete = coder.typeof(false);
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{6} = coder.newtype('Hyperparameter');
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{6}.Properties.value = coder.typeof(0);
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{6}.Properties.name = coder.typeof('X', [1, inf], [0, 1]);
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{6}.Properties.lb = coder.typeof(0);
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{6}.Properties.ub = coder.typeof(0);
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{6}.Properties.isDiscrete = coder.typeof(false);
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{7} = coder.newtype('Hyperparameter');
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{7}.Properties.value = coder.typeof(0);
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{7}.Properties.name = coder.typeof('X', [1, inf], [0, 1]);
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{7}.Properties.lb = coder.typeof(0);
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{7}.Properties.ub = coder.typeof(0);
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{7}.Properties.isDiscrete = coder.typeof(false);
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{8} = coder.newtype('Hyperparameter');
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{8}.Properties.value = coder.typeof(0);
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{8}.Properties.name = coder.typeof('X', [1, inf], [0, 1]);
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{8}.Properties.lb = coder.typeof(0);
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{8}.Properties.ub = coder.typeof(0);
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{8}.Properties.isDiscrete = coder.typeof(false);
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{9} = coder.newtype('Hyperparameter');
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{9}.Properties.value = coder.typeof(0);
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{9}.Properties.name = coder.typeof('X', [1, inf], [0, 1]);
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{9}.Properties.lb = coder.typeof(0);
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{9}.Properties.ub = coder.typeof(0);
        ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters{9}.Properties.isDiscrete = coder.typeof(false);
        ARGS{1}{1}.Properties.OptimizeOptions.Properties.hyperparameters = coder.typeof(ARGS_1_1_Properties_OptimizeOptions_Properties_hyperparameters, [1, 9]);
        ARGS{1}{1}.Properties.OptimizeOptions.Properties.hyperparameters = ARGS{1}{1}.Properties.OptimizeOptions.Properties.hyperparameters.makeHeterogeneous();
        ARG_1 = coder.typeof('X', [1, inf], [0, 1]);
        ARGS{1}{1}.Properties.OptimizeOptions.Properties.Algorithm = coder.typeof('X', [1, inf], [0, 1]);
        ARGS{1}{1}.Properties.OptimizeOptions.Properties.UseDefaultsFor = coder.typeof({ARG_1}, [1, 9], [0, 1]);
        ARGS{1}{1}.Properties.OptimizeOptions.Properties.InitialPopulation = coder.typeof(0, [inf, 9], [1, 1]);
        ARGS{1}{1}.Properties.OptimizeOptions.Properties.InitialPopulationSpan = coder.typeof(0, [1, 9], [0, 1]);
        ARGS{1}{1}.Properties.OptimizeOptions.Properties.PlotFcns = coder.typeof({ARG_1}, [1, 3], [0, 1]);
        ARGS{1}{1}.Properties.OptimizeOptions.Properties.DisplayInterval = coder.typeof(0);
        ARGS{1}{1}.Properties.OptimizeOptions.Properties.Display = coder.typeof('X', [1, inf], [0, 1]);
        ARGS{1}{1}.Properties.OptimizeOptions.Properties.PopulationSize = coder.typeof(0);
        ARGS{1}{1}.Properties.OptimizeOptions.Properties.UseParallel = coder.typeof(false);
        ARGS{1}{1}.Properties.OptimizeOptions.Properties.StallIterLimit = coder.typeof(0);
        ARGS{1}{1}.Properties.OptimizeOptions.Properties.StallTimeLimit = coder.typeof(0);
        ARGS{1}{1}.Properties.OptimizeOptions.Properties.TolFunValue = coder.typeof(0);
        ARGS{1}{1}.Properties.OptimizeOptions.Properties.InertiaRange = coder.typeof(0, [1, 2]);
        ARGS{1}{1}.Properties.OptimizeOptions.Properties.MaxIter = coder.typeof(0);
        ARGS{1}{1}.Properties.OptimizeOptions.Properties.MaxTime = coder.typeof(0);
        ARGS{1}{1}.Properties.OptimizeOptions.Properties.MaxFunEval = coder.typeof(0);
        ARGS{1}{1}.Properties.OptimizeOptions.Properties.MinFractionNeighbors = coder.typeof(0);
        ARGS{1}{1}.Properties.OptimizeOptions.Properties.ObjectiveLimit = coder.typeof(0);
        ARGS{1}{1}.Properties.OptimizeOptions.Properties.SelfAdjustment = coder.typeof(0);
        ARGS{1}{1}.Properties.OptimizeOptions.Properties.SocialAdjustment = coder.typeof(0);
        ARGS{1}{1}.Properties.OptimizeOptions.Properties.MinPopulationSize = coder.typeof(0);
        ARGS{1}{1}.Properties.OptimizeOptions.Properties.PopulationArquiveRate = coder.typeof(0);
        ARGS{1}{1}.Properties.OptimizeOptions.Properties.GravitationalConstant = coder.typeof(0);
        ARGS{1}{1}.Properties.OptimizeOptions.Properties.Verbosity = coder.typeof(0);
          
        %% Invoke MATLAB Coder.
        if ~exist('optimize_mex', 'file') || enableRecompile
             codegen -config cfg optimize -args ARGS{1}
        end
    end
end

