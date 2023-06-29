function dataCache = prepareData(data, combinations, lws, uws)
    dataCache = containers.Map('KeyType', 'int32', 'ValueType','any');
    numberOfTraces = int32(size(data, 2) / 2);
    folds = size(combinations, 1);
    for ws = lws:uws
        traces = containers.Map('KeyType', 'char', 'ValueType','any');
        vs = size(data, 1) - ws + 1;
        for i = 1:folds
            trainIndexes = combinations(i, :);
            testIndexes = setdiff(1:folds, trainIndexes);
            key = string(testIndexes);
            T = length(trainIndexes);
            trainTraces = zeros(T * vs, 2 * ws);
            seismicData = data(:, 1:numberOfTraces);
            vpData = data(:, numberOfTraces+1:end);
            for j = 1:T
                index = trainIndexes(j);
                trace = zeros(vs, 2 * ws);
                for k = 1:vs
                    trace(k, :) = [
                        seismicData(k : k + ws -1, index)' vpData(k : k + ws -1, index)'
                    ];
                end
                trainTraces(vs * (j - 1) + 1:vs * j, :) = trace;
            end
            T = length(testIndexes);
            testTraces = zeros(T * vs, 2 * ws);
            for j = 1:T
                index = testIndexes(j);
                trace = zeros(vs, 2 * ws);
                for k = 1:vs
                    trace(k, :) = [
                        seismicData(k : k + ws -1, index)' vpData(k : k + ws -1, index)'
                    ];
                end
                testTraces(vs * (j - 1) + 1:vs * j, :) = trace;
            end
            curData = [trainTraces ; testTraces];
            targets = data(:, testIndexes + folds);
            traces(key) = {trainTraces, testTraces, targets, max(curData) - min(curData)};
        end
        dataCache(ws) = traces;
    end
end
