function plotOptimizationResults(trainData, inputVars, outputVars, ...
    igmnOptions, useMex, legends, xlabels, minMaxProportion, exportFileName)

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
    outputs = predict(net, inputs, outputVars, 0);

    if  ~isempty(minMaxProportion)
        outputs = denormalizeData(outputs, minMaxProportion, outputVars);
    end
    
    legendNames = horzcat(legends{:});
    figure;
    wellFig = tiledlayout('horizontal', 'Padding', 'none', 'TileSpacing', 'tight');
    wellFig.Parent.Name = sprintf('%s x %s | %s x %s | %s x %s', legendNames{:});
    depth = 1:size(targets, 1);
    for i = 1:O
        ax = nexttile;
        ax.FontSize = 10;
        hold on;
        plot(targets(:, i), depth, 'LineWidth', 0.5);
        xlabel(xlabels{i}, 'FontSize', 10);
        plot(outputs(:, i), depth, 'LineWidth', 1);
        legend(legends{i}{:}, 'FontSize', 10, 'Location','southoutside');
        set(ax, 'YDir','reverse');
        set(ax, 'YTick', [])
        hold off;
    end

    pos = wellFig.Parent.Position;
    wellFig.Parent.Position = [pos(1), pos(2)/1.5, pos(3)*1.1, pos(4)*1.5];
    
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
        exportgraphics(wellFig, sprintf('%s.pdf', exportFileName), 'BackgroundColor', 'none', 'Resolution', 1000)
    end
end

