function fit = evaluate(params, problem, hpNames, maxPenalty) %#codegen

    global useKriging inKrigingMode krigingStartIteration iterationCount %#ok<*GVMIS>

    trainData = problem.trainData;
    testData = problem.testData;
    inputVarIndexes = problem.InputVarIndexes;
    outpuVarIndexes = problem.OutputVarIndexes;
    targets = testData(:, outpuVarIndexes);
    testData = testData(:, inputVarIndexes);

    options = igmnoptions.from(problem.DefaultIgmnOptions, hpNames, num2cell(params));
    popSize = problem.OptimizeOptions.PopulationSize;
    
    iterationCount = iterationCount + 1;

    if all([~inKrigingMode, floor(iterationCount / popSize) == krigingStartIteration], 'all')
        inKrigingMode = true;
        fprintf("Entering in kriging mode...\n");
    end

    net = igmn(options);
    net = train(net, trainData);    

    outputs = predict(net, testData, outpuVarIndexes);

    if all([useKriging; inKrigingMode], 'all')
        nonParametricData = problem.OptimizeOptions.ExtraEvalArgs{1};
        krigmeans = problem.OptimizeOptions.ExtraEvalArgs{2};
        krigvars = problem.OptimizeOptions.ExtraEvalArgs{3};
        infinitesimal = problem.OptimizeOptions.ExtraEvalArgs{4}; 
        sortedTrainData = problem.OptimizeOptions.ExtraEvalArgs{5};
        dataFiltered = problem.OptimizeOptions.ExtraEvalCellArgs{1};
        conditionedOutputs = zeros(size(testData, 1), size(trainData, 2));
        conditionedOutputs(:, outpuVarIndexes) = outputs .* krigvars + krigmeans;
        conditionedOutputs = normcdf(conditionedOutputs);
        T = size(dataFiltered, 2);
        steps = [1:10000:T, T];
        
        for i = 2:size(steps, 2)
            indexes = steps(i-1):steps(i);
            T = length(indexes);
            dFiltered = coder.nullcopy(cell(1, T));
            for k=1:T; dFiltered{k} = dataFiltered{indexes(k)}; end
            nonParametricData(indexes, :) = uniformToNonParametric(conditionedOutputs(indexes, :), ...
                sortedTrainData, dFiltered, 0.1, nonParametricData(indexes, :), outpuVarIndexes, infinitesimal);
        end
        outputs = nonParametricData(:, outpuVarIndexes);
    end

    weight = [1 4 4];
    weight = weight/sum(weight);
    % fit = sqrt(mean(((outputs-targets) .^ 2) .* weight, 'all'));

    Phi_rmse = sqrt(mean((targets(:, 1) - outputs(:, 1)) .^ 2));
    Sw13_rmse = sqrt(mean((targets(:, 2) - outputs(:, 2)) .^ 2));
    Sw24_rmse = sqrt(mean((targets(:, 3) - outputs(:, 3)) .^ 2));

    
    fit = sum([Phi_rmse, Sw13_rmse, Sw24_rmse] .* weight);

    if net.nc > net.maxNc
        fit = fit + barrierPenalty( ...
            net.nc, 0,  net.maxNc, maxPenalty, 0.5 * maxPenalty);
    end
end
