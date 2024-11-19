% RUN_NATIVE_SCRIPT   Generate static library run_native from run_native.
% 
% Script generated from project 'run_native.prj' on 11-Apr-2024.
% 
% See also CODER, CODER.CONFIG, CODER.TYPEOF, CODEGEN.

inputData = 0:0.01:(2 * pi);
inputData = inputData(randperm(size(inputData, 2)));
outputData = linspace(0, 2 * pi, 100);

maxNc = 8;

problem = Problem( ...
    [inputData; sin(inputData)]', ...
    [outputData; sin(outputData)]', ...
    'ExecutionMode', 'native', ...
    'DoParametersTuning', true, ...
    'CompileOptions', compileoptions(...
        size(inputData, 2), size(outputData, 2),  ...
        'NumberOfVariables', 2, ...
        'NumberOfOutputVars', 1, ...
        'EnableRecompile', true, ...
        'IsOptimization', true ...
    ));

populationSpan = optimizeoptions.initialPopulationSpan([], problem.OptimizeOptions.hyperparameters);
coder.varsize('populationSpan');

% problem.OptimizeOptions.PlotFcns = {};
problem.OptimizeOptions.InitialPopulationSpan = populationSpan;
problem.OptimizeOptions.Algorithm = 'pso';
problem.OptimizeOptions.SelfAdjustment = 1.49;
problem.OptimizeOptions.SocialAdjustment = 1.49;
problem.OptimizeOptions.UseDefaultsFor = {'MaxNc', 'UseRankOne'};
% problem.DefaultIgmnOptions.Phi = 1;
problem.OptimizeOptions.MaxFunEval = 10000;
problem.OptimizeOptions.PopulationSize = 100;
problem.OptimizeOptions.UseParallel = false;
problem.OptimizeOptions.TolFunValue = 1e-12;
problem.DefaultIgmnOptions.MaxNc = maxNc;
problem.DefaultIgmnOptions.UseRankOne = 1;
% problem.DefaultIgmnOptions.SPMin = 4
% problem.DefaultIgmnOptions.Delta = 0.1;

%% Create configuration object of class 'coder.EmbeddedCodeConfig'.
cfg = coder.config('lib', 'ecoder', true);
cfg.TargetLang = 'C++';
cfg.CppNamespace = 'igmnplugin';
cfg.CppNamespaceForMathworksCode = 'igmnplugin';
cfg.CppInterfaceClassName = 'IgmnPlugin';
cfg.CppInterfaceStyle = 'Methods';
cfg.DynamicMemoryAllocationInterface = 'C';
cfg.GenerateMakefile = true;
cfg.GenerateReport = true;
cfg.MATLABFcnDesc = false;
cfg.MaxIdLength = 1024;
cfg.PreserveUnusedStructFields = true;
cfg.PreserveVariableNames = 'All';
cfg.ReportPotentialDifferences = false;
cfg.TargetLangStandard = 'C++11 (ISO)';
cfg.Toolchain = 'Microsoft Visual Studio Project 2019 | CMake (64-bit Windows)';
cfg.SILPILDebugging = true;
cfg.EnableAutoParallelization = true;
cfg.BuildConfiguration = 'Debug';


%% Define argument types for entry-point 'run_native_new'.

options = problem.CompileOptions;
trainSize = options.trainSize;
testSize = options.testSize;
numberOfVars = options.NumberOfVariables;
numberOfOutputVars = options.NumberOfOutputVars;

ARGS = cell(1, 1);
ARGS{1} = cell(1, 1);
ARGS{1}{1} = coder.newtype('Problem');
ARGS{1}{1}.Properties.trainData = coder.typeof(0, [trainSize, numberOfVars], [~isfinite(trainSize), 0]);
ARGS{1}{1}.Properties.testData = coder.typeof(0, [testSize, numberOfVars], [~isfinite(testSize), 0]);
ARGS{1}{1}.Properties.ExecutionMode = coder.typeof('X', [1, inf], [0, 1]);
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

extraEvalArgs = coder.newtype('cell', {coder.typeof(0, [inf inf], [1 1])}, [inf, inf], [1 1]);
extraEvalArgs = extraEvalArgs.makeHomogeneous();

extraEvalCellArgs = coder.newtype('cell', {extraEvalArgs}, [inf, inf], [1 1]);
extraEvalCellArgs = extraEvalCellArgs.makeHomogeneous();

ARGS{1}{1}.Properties.OptimizeOptions.Properties.ExtraEvalArgs = extraEvalArgs;
ARGS{1}{1}.Properties.OptimizeOptions.Properties.ExtraEvalCellArgs = extraEvalCellArgs;

%% Invoke MATLAB Coder.
codegen -config cfg -args ARGS{1} run_native_new

