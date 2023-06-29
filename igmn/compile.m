function compile(inputSize, outputSize, compSize, trainSize, testSize, options)
    arguments
        inputSize int32, ...
        outputSize int32, ...
        compSize int32, ...
        trainSize int32, ...
        testSize int32, ...
        options struct = struct();
    end

    if ~isfield(options,'compSize')
        options.compSize = compSize;
    end

    if ~isfield(options,'useGpu')
        options.useGpu = false;
    end

    if ~isfield(options,'profile')
        options.profile = false;
    end

    if ~isfield(options,'report')
        options.report = false;
    end

    %% Create configuration object of class 'coder.MexCodeConfig'.
    if options.useGpu
        cfg = coder.gpuConfig('mex');
        cfg.GpuConfig.SafeBuild = true;
        cfg.EnableJITSilentBailOut = true;
        cfg.GpuConfig.EnableMemoryManager = true;
    else
        cfg = coder.config('mex');
        cfg.NumberOfCpuThreads = 16;
        cfg.EnableAutoParallelization = true;
        cfg.OptimizeReductions = true;
    end
    cfg.GenerateReport = options.report;
    cfg.ReportPotentialDifferences = false;
    cfg.EnableMexProfiling = options.profile;

    
    featuresSize = inputSize + outputSize;
    compSize = options.compSize;

    %% Define argument types for entry-point 'predict' or 'classify'.
    ARGS = cell(2,1);
    ARGS{1} = cell(4,1);
    ARGS{1}{1} = coder.newtype('igmn');
    ARGS{1}{1}.Properties.name = coder.typeof('X',[1 4]);
    ARGS{1}{1}.Properties.dimension = coder.typeof(int32(0));
    ARGS{1}{1}.Properties.maxDistance = coder.typeof(0);
    ARGS{1}{1}.Properties.initialCov = coder.typeof(0,[featuresSize featuresSize]);
    ARGS{1}{1}.Properties.minCov = coder.typeof(0,[featuresSize featuresSize]);
    ARGS{1}{1}.Properties.range = coder.typeof(0,[2 featuresSize]);
    ARGS{1}{1}.Properties.nc = coder.typeof(int32(0));
    ARGS{1}{1}.Properties.sampleSize = coder.typeof(int32(0));
    ARGS{1}{1}.Properties.compSize = coder.typeof(int32(0));
    ARGS{1}{1}.Properties.delta = coder.typeof(0);
    ARGS{1}{1}.Properties.tau = coder.typeof(0);
    ARGS{1}{1}.Properties.spMin = coder.typeof(int32(0));
    ARGS{1}{1}.Properties.vMin = coder.typeof(int32(0));
    ARGS{1}{1}.Properties.priors = coder.typeof(0,[1 compSize]);
    ARGS{1}{1}.Properties.means = coder.typeof(0,[compSize featuresSize]);
    ARGS{1}{1}.Properties.covs = coder.typeof(0,[featuresSize featuresSize compSize]);
    ARGS{1}{1}.Properties.sps = coder.typeof(0,[1 compSize]);
    ARGS{1}{1}.Properties.vs = coder.typeof(int32(0),[1 compSize]);
    ARGS{1}{1}.Properties.distances = coder.typeof(0,[1 compSize]);
    ARGS{1}{1}.Properties.logLike = coder.typeof(0,[1 compSize]);
    ARGS{1}{1}.Properties.post = coder.typeof(0,[1 compSize]);
    ARGS{1}{2} = coder.typeof(0, [testSize  inputSize],'Gpu', options.useGpu);
    ARGS{1}{3} = coder.typeof(0, [1, outputSize]);
    ARGS{1}{4} = coder.typeof(0);
    if isfield(options, 'isClassifyProblem') && options.isClassifyProblem
        codegen -config cfg classify -args ARGS{1}
    else
        codegen -config cfg predict -args ARGS{1}
    end
   

    %% Define argument types for entry-point 'train'.
    ARGS{1} = cell(2,1);
    ARGS{1}{1} = coder.newtype('igmn');
    ARGS{1}{1}.Properties.name = coder.typeof('X',[1 4]);
    ARGS{1}{1}.Properties.dimension = coder.typeof(int32(0));
    ARGS{1}{1}.Properties.maxDistance = coder.typeof(0);
    ARGS{1}{1}.Properties.initialCov = coder.typeof(0,[featuresSize featuresSize]);
    ARGS{1}{1}.Properties.minCov = coder.typeof(0,[featuresSize featuresSize]);
    ARGS{1}{1}.Properties.range = coder.typeof(0,[2 featuresSize]);
    ARGS{1}{1}.Properties.nc = coder.typeof(int32(0));
    ARGS{1}{1}.Properties.sampleSize = coder.typeof(int32(0));
    ARGS{1}{1}.Properties.compSize = coder.typeof(int32(0));
    ARGS{1}{1}.Properties.delta = coder.typeof(0);
    ARGS{1}{1}.Properties.tau = coder.typeof(0);
    ARGS{1}{1}.Properties.spMin = coder.typeof(int32(0));
    ARGS{1}{1}.Properties.vMin = coder.typeof(int32(0));
    ARGS{1}{1}.Properties.priors = coder.typeof(0,[1 compSize]);
    ARGS{1}{1}.Properties.means = coder.typeof(0,[compSize featuresSize]);
    ARGS{1}{1}.Properties.covs = coder.typeof(0,[featuresSize featuresSize compSize]);
    ARGS{1}{1}.Properties.sps = coder.typeof(0,[1 compSize]);
    ARGS{1}{1}.Properties.vs = coder.typeof(int32(0),[1 compSize]);
    ARGS{1}{1}.Properties.distances = coder.typeof(0,[1 compSize]);
    ARGS{1}{1}.Properties.logLike = coder.typeof(0,[1 compSize]);
    ARGS{1}{1}.Properties.post = coder.typeof(0,[1 compSize]);
    ARGS{1}{2} = coder.typeof(0, [trainSize featuresSize],'Gpu', options.useGpu);
    
    %% Invoke MATLAB Coder.
    codegen -config cfg train -args ARGS{1}
end

