function run_native_new(problem)

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

