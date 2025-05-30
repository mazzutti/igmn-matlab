% compile - Compiles MATLAB functions into MEX or library files based on the specified problem configuration.
%
% Syntax:
%   compile(problem)
%
% Description:
%   This function compiles MATLAB functions into MEX or library files using MATLAB Coder. 
%   The compilation process is determined by the execution mode and compile options specified 
%   in the input 'problem' object. It supports different configurations for classification, 
%   prediction, training, and optimization tasks.
%
% Input Arguments:
%   problem - An object of class 'Problem' containing the following properties:
%       ExecutionMode          - A string specifying the execution mode ('script', 'mex', or 'lib').
%       CompileOptions         - A structure containing compile options such as:
%           EnableProfile       - Enable profiling for MEX files.
%           EnableReport        - Enable generation of code generation reports.
%           EnableRecompile     - Force recompilation of MEX or library files.
%           IsClassification    - Boolean indicating if the task is classification.
%           IsOptimization      - Boolean indicating if the task is optimization.
%           NumberOfVariables   - Number of input variables.
%           NumberOfOutputVars  - Number of output variables.
%           trainSize           - Size of the training dataset.
%           testSize            - Size of the testing dataset.
%       Other properties specific to the problem configuration.
%
% Functionality:
%   - Configures MATLAB Coder for MEX or library generation based on the execution mode.
%   - Defines argument types for entry-point functions such as 'predict', 'classify', 'train', 
%     'igmnBuilder', and 'optimize'.
%   - Invokes MATLAB Coder to generate MEX or library files for the specified functions.
%   - Supports additional configurations for optimization tasks, including hyperparameter tuning.
%
% Notes:
%   - The function checks for the existence of previously compiled files and recompiles them 
%     only if 'EnableRecompile' is set to true.
%   - The generated code can be configured for different toolchains, target languages, and 
%     optimization settings.
%
% Example:
%   problem = Problem();
%   problem.ExecutionMode = 'mex';
%   problem.CompileOptions.EnableProfile = true;
%   problem.CompileOptions.EnableReport = true;
%   compile(problem);
%
% See also:
%   coder.config, codegen
function compile(problem)
    arguments
        problem (1, 1) Problem;
    end

    if ~strcmp(problem.ExecutionMode,  'script') 

        options = problem.CompileOptions;
        cfg = [];
    
        if strcmp(problem.ExecutionMode,  'mex') 
            %% Create configuration object of class 'coder.MexCodeConfig'.
            cfg = coder.config('mex');
            cfg.GenerateReport = true;
            cfg.EnableMexProfiling = options.EnableProfile;
            cfg.EnableVariableSizing = true;
            cfg.SIMDAcceleration = 'Full';
            cfg.IntegrityChecks = false;
            cfg.ExtrinsicCalls = false;
            cfg.ResponsivenessChecks = false;
            cfg.GlobalDataSyncMethod = 'NoSync';
        else
            %% Create configuration object of class 'coder.CodeConfig'.
            cfg = coder.config('lib', 'ecoder', true);
            cfg.RuntimeChecks = false;
            cfg.BuildConfiguration = 'Debug';
            cfg.GenerateExampleMain = 'GenerateCodeOnly';
            cfg.SILPILDebugging = true;
            cfg.Toolchain = 'Microsoft Visual Studio Project 2019 | CMake (64-bit Windows)';
            cfg.GenerateMakefile = false;
            cfg.TargetLang = 'C++';
            cfg.TargetLangStandard = 'C++11 (ISO)';
            cfg.CppInterfaceClassName = 'IgmnPlugin';
            cfg.CppInterfaceStyle = 'Methods';
            cfg.CppNamespace = 'igmnplugin';
            cfg.CppNamespaceForMathworksCode = 'igmnplugin';
            cfg.InstructionSetExtensions = 'SSE2';
            cfg.DynamicMemoryAllocationInterface = 'C++';
            cfg.PreserveUnusedStructFields = true;
            cfg.ReportPotentialDifferences = false;
            cfg.PreserveVariableNames = 'All';
            cfg.MATLABFcnDesc = false;
            % cfg.InlineBetweenMathWorksFunctions = 'Readability';
            % cfg.InlineBetweenUserAndMathWorksFunctions = 'Readability';
            % cfg.InlineBetweenUserFunctions = 'Readability';
        end


        cfg.NumberOfCpuThreads = 6;
        cfg.EnableAutoParallelization = true;
        cfg.OptimizeReductions = true;
        cfg.GenerateReport = options.EnableReport;
        cfg.ReportPotentialDifferences = false;
        cfg.EnableVariableSizing = true;
    
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
        ARGS{1}{2} = coder.typeof(0, [testSize, numberOfVars - numberOfOutputVars], [~isfinite(testSize), 1]);
        ARGS{1}{3} = coder.typeof(0, [1, numberOfOutputVars], [0, 0]);
        if isClassification
            if ~exist('classify_mex', 'file') || enableRecompile
                codegen -config cfg classify -args ARGS{1}
            end
        else
            if ~exist('predict_mex', 'file') || enableRecompile
                ARGS{1}{4} = coder.typeof(0);
                ARGS{1}{5} = coder.typeof(0, [2, numberOfOutputVars], [0, 0]);
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
            if ~exist('optimize_mex', 'file') || enableRecompile
                 codegen -config cfg optimize -args ARGS{1}
            end
        end
    end
end

