function fit = evaluate(params, problem, hpNames, maxPenalty) %#codegen

    trainData = problem.trainData;
    testData = problem.testData;
    inputVarIndexes = problem.InputVarIndexes;
    outpuVarIndexes = problem.OutputVarIndexes;
    targets = testData(:, outpuVarIndexes);
    testData = testData(:, inputVarIndexes);

    options = igmnoptions.from(problem.DefaultIgmnOptions, hpNames, num2cell(params));
    
    net = igmn(options);
    net = train(net, trainData);

    outputs = predict(net, testData, outpuVarIndexes);
    % fit = sqrt(mean((targets(:, end) - outputs(:, end)) .^ 2));
    % fit = 0.25 * sum(sqrt(mean((targets(:, 1:2) - outputs(:, 1:2)) .^ 2))) + fit;
    weight = [1, 7, 16];
    weight = weight/sum(weight);
    fit = sqrt(mean(sum(((outputs-targets) .^ 2) .* weight, 2)));

    if net.nc > net.maxNc
        fit = fit + barrierPenalty( ...
            net.nc, 0,  net.maxNc, maxPenalty, 0.5 * maxPenalty);
    end    
end
