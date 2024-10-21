function plotOptimizationRegressions(trainData, inputVars, outputVars, ...
    igmnOptions, useMex, legends, exportFileName, useKriging, krigvars, krigmeans, min2norm, max2norm)

    inputs =  trainData(:, inputVars);
    targets = trainData(:, outputVars);
    O = length(outputVars);

    colormap('jet');

    if useMex
        igmn = @igmnBuilder_mex;
        train = @train_mex;
        predict = @predict_mex;
    else
        igmn = @igmn;
        train = @train;
        predict = @predict;
    end
    
    net = igmn(igmnOptions);
    net = train(net, trainData);
    outputs = predict(net, inputs, outputVars, 0, zeros(2, length(outputVars)));
    if useKriging
        conditionedOutputs = zeros(size(trainData));
        conditionedOutputs(:, outputVars) = outputs .* krigvars + krigmeans;
        conditionedOutputs = normcdf(conditionedOutputs);
        outputs = igmn_uniform_to_nonParametric(conditionedOutputs, trainData, cell_size, inputs);   
    end

    legendNames = horzcat(legends{:});
    regressionEntries = cell(1, 3 * O);
    for i = 1:O
        index = (i - 1) * O + 1; 
        regressionEntries{index} = targets(:, i);
        regressionEntries{index + 1} = outputs(:, i);
        regressionEntries{index + 2} = sprintf('%s Prediction', legends{i}{1});
    end
    f = figure('Name', sprintf('%Regressions: s x %s | %s x %s | %s x %s', legendNames{:}));
    plotregression(regressionEntries{:});
    f.Children(3).Children(1).Marker = '.';
    f.Children(5).Children(1).Marker = '.';
    f.Children(7).Children(1).Marker = '.';

    if exist("exportFileName", 'var')
        exportgraphics(f, sprintf('%s_regression.pdf', exportFileName), 'BackgroundColor', 'none', 'Resolution', 300)
    end
end

