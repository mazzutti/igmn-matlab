function fit = evaluate(params, problem, hpNames, maxPenalty) %#codegen
    global traceSizes
    global targets
    global testTraces
    
    trainData = problem.trainData;
    testData = problem.testData;
    inputVarIndexes = problem.InputVarIndexes;
    outpuVarIndexes = problem.OutputVarIndexes;
    
    inputTestData = testData(:, inputVarIndexes);

    options = igmnoptions.from(problem.DefaultIgmnOptions, hpNames, num2cell(params));
    
    net = igmn(options);
    net = train(net, trainData);

    T = numel(testTraces);

    waveSize = numel(outpuVarIndexes);
    
    outputValues = predict(net, inputTestData, outpuVarIndexes);
    
    ends = cumsum(traceSizes(testTraces) - waveSize + 1);
    starts = ends - (traceSizes(testTraces) - waveSize);

    outputs = nan(sum(traceSizes(testTraces), 'all'), 1);
    cumTraceSizes = cumsum([1 traceSizes(testTraces)]);
    for i = 1:T
        predictTrace = fliplr(outputValues(starts(i):ends(i), :));
        % outputs(cumTraceSizes(i):cumTraceSizes(i+1)-1) = ...
        %     exp(arrayfun(@(k) mean(diag(predictTrace, k)), (waveSize-1):-1:(-(traceSizes(testTraces(i)) - waveSize)))');
        outputs(cumTraceSizes(i):cumTraceSizes(i+1)-1) = ...
            arrayfun(@(k) mean(diag(predictTrace, k)), (waveSize-1):-1:(-(traceSizes(testTraces(i)) - waveSize)))';
    end
    
    fit = sum(sqrt(mean((targets - outputs) .^ 2)), 'all');
    

    if net.nc > net.maxNc
        fit = fit + barrierPenalty( ...
            net.nc, 0,  net.maxNc, maxPenalty, 0.5 * maxPenalty);
    end
end
