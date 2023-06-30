function compile(featuresCount, outputVars, options)
    arguments
        featuresCount int32, ...
        outputVars double, ...
        options struct = struct();
    end

    if ~isfield(options, 'profile')
        options.profile = false;
    end

    if ~isfield(options, 'report')
        options.report = false;
    end

    %% Create configuration object of class 'coder.MexCodeConfig'.
    cfg = coder.config('mex');
    cfg.NumberOfCpuThreads = 16;
    cfg.EnableAutoParallelization = true;
    cfg.OptimizeReductions = true;
    cfg.GenerateReport = options.report;
    cfg.ReportPotentialDifferences = false;
    cfg.EnableMexProfiling = options.profile;
    cfg.EnableVariableSizing = true;
    cfg.EnableAutoParallelization = true;
    cfg.SIMDAcceleration = 'Full';

    %% Define argument types for entry-point 'predict' or 'classify'.
    ARGS = cell(2,1);
    if isfield(options, 'isClassifyProblem') && options.isClassifyProblem
        ARGS{1} = cell(3,1);
    else
        ARGS{1} = cell(4,1);
    end
    ARGS{1}{1} = coder.newtype('igmn');
    ARGS{1}{1}.Properties.name = coder.typeof('X',[1 4]);
    ARGS{1}{1}.Properties.dimension = coder.typeof(int32(0));
    ARGS{1}{1}.Properties.maxDistance = coder.typeof(0);
    ARGS{1}{1}.Properties.initialCov = coder.typeof(0, [featuresCount, featuresCount]);
    ARGS{1}{1}.Properties.minCov = coder.typeof(0, [featuresCount, featuresCount]);
    ARGS{1}{1}.Properties.range = coder.typeof(0, [2, featuresCount]);
    ARGS{1}{1}.Properties.nc = coder.typeof(int32(0));
    ARGS{1}{1}.Properties.sampleSize = coder.typeof(int32(0));
    ARGS{1}{1}.Properties.delta = coder.typeof(0);
    ARGS{1}{1}.Properties.tau = coder.typeof(0);
    ARGS{1}{1}.Properties.spMin = coder.typeof(int32(0));
    ARGS{1}{1}.Properties.vMin = coder.typeof(int32(0));
    ARGS{1}{1}.Properties.priors = coder.typeof(0, [1, inf], [0, 1]);
    ARGS{1}{1}.Properties.means = coder.typeof(0, [inf, featuresCount], [1, 0]);
    ARGS{1}{1}.Properties.covs = coder.typeof(0, [featuresCount, featuresCount, inf], [0, 0, 1]);
    ARGS{1}{1}.Properties.sps = coder.typeof(0, [1, inf], [0, 1]);
    ARGS{1}{1}.Properties.vs = coder.typeof(0, [1, inf], [0, 1]);
    ARGS{1}{1}.Properties.distances = coder.typeof(0, [1, inf], [0, 1]);
    ARGS{1}{1}.Properties.logLikes = coder.typeof(0, [1, inf], [0, 1]);
    ARGS{1}{1}.Properties.posteriors = coder.typeof(0, [1, inf], [0, 1]);
    ARGS{1}{2} = coder.typeof(0, [inf, featuresCount - 1], [1, 1]);
    ARGS{1}{3} = coder.typeof(0, [1, length(outputVars)]);
    if isfield(options, 'isClassifyProblem') && options.isClassifyProblem
        codegen -config cfg classify -args ARGS{1}
    else
        ARGS{1}{4} = coder.typeof(0);
        codegen -config cfg predict -args ARGS{1}
    end
   

    %% Define argument types for entry-point 'train'.
    ARGS{1} = cell(2,1);
    ARGS{1}{1} = coder.newtype('igmn');
    ARGS{1}{1}.Properties.name = coder.typeof('X', [1, 4]);
    ARGS{1}{1}.Properties.dimension = coder.typeof(int32(0));
    ARGS{1}{1}.Properties.maxDistance = coder.typeof(0);
    ARGS{1}{1}.Properties.initialCov = coder.typeof(0, [featuresCount, featuresCount]);
    ARGS{1}{1}.Properties.minCov = coder.typeof(0, [featuresCount, featuresCount]);
    ARGS{1}{1}.Properties.range = coder.typeof(0, [2, featuresCount]);
    ARGS{1}{1}.Properties.nc = coder.typeof(int32(0));
    ARGS{1}{1}.Properties.sampleSize = coder.typeof(int32(0));
    ARGS{1}{1}.Properties.delta = coder.typeof(0);
    ARGS{1}{1}.Properties.tau = coder.typeof(0);
    ARGS{1}{1}.Properties.spMin = coder.typeof(int32(0));
    ARGS{1}{1}.Properties.vMin = coder.typeof(int32(0));
    ARGS{1}{1}.Properties.priors = coder.typeof(0, [1, inf], [0, 1]);
    ARGS{1}{1}.Properties.means = coder.typeof(0, [inf, featuresCount], [1, 0]);
    ARGS{1}{1}.Properties.covs = coder.typeof(0, [featuresCount, featuresCount, inf], [0, 0, 1]);
    ARGS{1}{1}.Properties.sps = coder.typeof(0, [1, inf], [0, 1]);
    ARGS{1}{1}.Properties.vs = coder.typeof(0, [1, inf], [0, 1]);
    ARGS{1}{1}.Properties.distances = coder.typeof(0, [1, inf], [0, 1]);
    ARGS{1}{1}.Properties.logLikes = coder.typeof(0, [1, inf], [0, 1]);
    ARGS{1}{1}.Properties.posteriors = coder.typeof(0, [1, inf], [0, 1]);
    ARGS{1}{2} = coder.typeof(0, [inf, featuresCount], [1, 0]); %#ok<*NASGU>
    
    %% Invoke MATLAB Coder.
    codegen -config cfg train -args ARGS{1}
end

