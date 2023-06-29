function plotOptimizationResults(dataCache, igmnParams, inputVars, outputVars, legends, useMex)

    O = length(outputVars);

    trainData = dataCache{1};
    testData = dataCache{2};
    range = dataCache{3};
    targets = testData(:, outputVars);
    testData = testData(:, inputVars);

    options = {}; 
    options.tau = igmnParams(1); 
    options.delta = igmnParams(2);
    options.spMin = int32(igmnParams(3));
    options.vMin = int32(igmnParams(4));
    options.regValue = igmnParams(5);
    options.compSize = int32(size(trainData, 1));
    
    net = igmn(range, options);
    if useMex
        net = train_mex(net, trainData);
        outputs = classify_mex(net, testData, outputVars, 0);
    else
        net = train(net, trainData);
        outputs = classify(net, testData, outputVars, 0);
    end
    
    regressionEntries = cell(1, 3 * O);
    for i = 1:O
        index = (i - 1) * (O + 1) + 1; 
        regressionEntries{index} = targets(:, i);
        regressionEntries{index + 1} = outputs(:, i);
        regressionEntries{index + 2} = sprintf('%s x %s - Regression', legends{i}{:});
    end
    classes = {legends{1}{1} legends{2}{1}};
    targets = onehotdecode(double(targets), classes, 2);
    outputs = onehotdecode(double(outputs), classes, 2);

    legendNames = horzcat(legends{:});
    figure('Name', sprintf('Regressions: s x %s | %s x %s', legendNames{:}));
    plotregression(regressionEntries{:});
    figure('Name', sprintf('Confusion Matrix: s x %s | %s x %s', legendNames{:}));
    plotconfusion(targets, outputs);
end

