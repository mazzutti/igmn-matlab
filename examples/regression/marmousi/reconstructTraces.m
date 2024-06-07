function reconstructTraces(net, data, traceSizes, inputVars, outputVars, outvarNames, predict)
    starts = cumsum(traceSizes) - traceSizes + 1;
    height = max(traceSizes);

    T = numel(starts);
    O = numel(outputVars);
    targets = nan(height, T, O);
    outputs = nan(height, T, O);
    for i = 1:T
        endIndex = starts(i) + traceSizes(i) - 1;
        inputData = data(starts(i):endIndex, inputVars);
        outputs(1:traceSizes(i), i, :) = exp(predict(net, inputData, outputVars, 0));
        targets(1:traceSizes(i), i, :) = exp(data(starts(i):endIndex, outputVars));
    end
    fig = figure('units', 'normalized', 'outerposition', [0.1 0.1 0.9 0.9]);
    set(fig,'Color', [.8 .8 .8])
    tiledlayout(3, 2, 'Padding', 'none', 'TileSpacing', 'loose');
    colormap('jet');
    for var = 1:numel(outputVars)
        ax = nexttile;
        imagesc(targets(:, :, var));
        xlabel(sprintf('Real %s', outvarNames{var}));
        ylabel('Depth (ms)');
        set(ax, 'YDir','reverse');
        ax = nexttile;
        imagesc(outputs(:, :, var));
        xlabel(sprintf('Predicted %s', outvarNames{var}));
        ylabel('Depth (ms)');
        set(ax, 'YDir','reverse');
    end
    sgtitle('Targets x Outputs');
end
