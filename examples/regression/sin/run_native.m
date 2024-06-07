function run_native()
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

    igmnOptions = problem.DefaultIgmnOptions;
    if problem.DoParametersTuning
        tic;
        igmnOptions = optimize(problem);
        toc;
    end
    
    trainData = problem.trainData;
    testData = problem.testData;    
    inputVarIndexes = problem.InputVarIndexes;
    outputVarIndexes = problem.OutputVarIndexes;

    net = igmnBuilder(igmnOptions);
    net = train(net, trainData);
    Y = predict(net, testData(:, inputVarIndexes), outputVarIndexes, 0);
    coder.extrinsic('plotregression');
    figure; plotregression(testData(:, outputVarIndexes), Y);
end

