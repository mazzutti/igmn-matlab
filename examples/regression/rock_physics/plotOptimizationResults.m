function plotOptimizationResults(dataCache, igmnParams, ...
    inputVars, outputVars, depth, legends, useMex, minMaxProportion)

    O = length(outputVars);

    colors = distinguishableColors(2*O);
    colororder(colors);

    trainData = dataCache{1};
    wellData = dataCache{2};
    range = dataCache{3};
    targets = dataCache{4};
    testData = wellData(:, inputVars);

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
        outputs = predict_mex(net, testData, outputVars, 0);
    else
        net = train(net, trainData);
        outputs = predict(net, testData, outputVars, 0);
    end
    if nargin == 8
        outputs = denormalizeData(outputs, minMaxProportion, outputVars);
    end
    
    legendNames = horzcat(legends{:});
    wellFig = figure('NumberTitle', 'off', 'Name', ...
    sprintf('%s x %s | %s x %s | %s x %s', legendNames{:}));

    axes('Units', 'normalized', 'Position', [0 0 1 1]);
    
    for i = 1:O
        subplot(1, O, i, 'Parent', wellFig);
        hold on;
        plot(targets(:, i), depth, 'LineWidth', 0.1, 'Color', colors(i, :));
        plot(outputs(:, i), depth, 'LineWidth', 0.1, 'Color', colors(i + O, :));
        legend(legends{i}{:})
        hold off;
    end
    
    regressionEntries = cell(1, 3 * O);
    for i = 1:O
        index = (i - 1) * O + 1; 
        regressionEntries{index} = targets(:, i);
        regressionEntries{index + 1} = outputs(:, i);
        regressionEntries{index + 2} = sprintf('%s x %s - Regression', legends{i}{:});
    end
    figure('Name', sprintf('%Regressions: s x %s | %s x %s | %s x %s', legendNames{:}));
    plotregression(regressionEntries{:});
end

