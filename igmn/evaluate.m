function fit = evaluate(params, problem, hpNames, maxPenalty) %#codegen
    
    trainData = problem.trainData;
    testData = problem.testData;
    inputVarIndexes = problem.InputVarIndexes;
    outpuVarIndexes = problem.OutputVarIndexes;
    isClassification = problem.CompileOptions.IsClassification;
    targets = testData(:, outpuVarIndexes);
    testData = testData(:, inputVarIndexes);

    options = igmnoptions.from(problem.DefaultIgmnOptions, hpNames, num2cell(params));
    
    net = igmn(options);
    net = train(net, trainData);

    if ~net.converged
        fit = inf;
        return;
    end

    if isClassification
        outputs = classify(net, testData, outpuVarIndexes);
        fit = sum(targets ~= outputs, "all") / 2;
    else
        outputs = predict(net, testData, outpuVarIndexes);
        fit = sum(sqrt(mean((targets - outputs) .^ 2)), 'all');
    end

    if net.nc > net.maxNc
        fit = fit + barrierPenalty( ...
            net.nc, 0,  net.maxNc, maxPenalty, 0.5 * maxPenalty);
    end
end
