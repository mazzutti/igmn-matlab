function [ ...
    bestParams, ...
    dataCache, ...
    combinations ...
    ] = optimize(data, lb, ub, numberOfTestTraces)

    algOptions = optimoptions(...
        'ga', ...
        'Display', 'iter', ...
        'UseParallel', true, ...
        'MaxStallGenerations', 200, ...
        'PlotFcns', {@gaplotdistance, @gaplotbestf});

    indexes = 1:int32(size(data, 2) / 2);
    combinations = nchoosek(indexes, length(indexes) - numberOfTestTraces);
    dataCache = prepareData(data, combinations, lb(end), ub(end));

    doOptimizization = @(params) runOptimization(params, data, combinations, dataCache);

    bestParams = ga( ...
        doOptimizization, length(lb), [], [], [], [], lb, ub, [], [3 4 5], algOptions);
end

function fit = runOptimization(params, data, combinations, dataCache)
    folds = size(combinations, 1);
    fits = zeros(1, folds);
    ws = int32(params(end));
    vs = size(data, 1) - ws + 1;
    dataForWs = dataCache(ws);
    k = keys(dataForWs);
    parfor i = 1:folds
        key = k{i};
        curData = dataForWs(key); %#ok<*PFBNS>
        [trainData, testData, targets, range] = curData{:};
        fits(i) = fitness(range, params, trainData, testData, vs, targets);
    end
    fit = mean(fits);
end

function fit  = fitness(range, params,  trainData, testData, vs, targets)
    ws = int32(params(end));
    options = {}; 
    options.tau = params(1); 
    options.delta = params(2);
    options.spMin = int32(params(3));
    options.vMin = int32(params(4));
    net = igmn(range, options);
    T = int32(size(range, 2) / 2);
    logTrainData = trainData(:, :);
    logTrainData(:, T+1:end) = log(logTrainData(:, T+1:end));
    net.train(logTrainData);
    outputs = exp(toTraces(net.predict(testData(:, 1:ws)), ws, vs));
    fit = sum(sqrt(mean((targets - outputs) .^ 2)));
end


function traces = toTraces(outputs, ws, vs)
    numberOfTraces = size(outputs, 1) / vs;
    N = vs + ws - 1;
    traces = zeros(N, numberOfTraces);
    chunks = reshape(outputs, [vs, ws, numberOfTraces]);
    for i = 1:numberOfTraces
        ptrace = fliplr(chunks(:, :, i));
        traces(:, i) = arrayfun(@(k) mean(diag(ptrace, k)), ws-1:-1:-vs+1)';
    end
end