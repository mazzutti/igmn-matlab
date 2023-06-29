function [train, test] = splitData(data, proportion, T, VS)
    trainTraces = randperm(T, ceil(T * proportion));
    testTraces = 1:T;
    testTraces(trainTraces) = [];
    train = zeros(VS * length(trainTraces), size(data, 2));
    test = zeros(VS * length(testTraces), size(data, 2));
    for i = 1:length(trainTraces)
        trace = trainTraces(i);
        indexesFrom = ((trace-1)*VS + 1):trace*VS;
        indexesTo = ((i-1)*VS + 1):i*VS;
        train(indexesTo, :) = data(indexesFrom, :);
    end
    for i = 1:length(testTraces)
        trace = testTraces(i);
        indexesFrom = ((trace-1)*VS + 1):trace*VS;
        indexesTo = ((i-1)*VS + 1):i*VS;
        test(indexesTo, :) = data(indexesFrom, :);
    end
end