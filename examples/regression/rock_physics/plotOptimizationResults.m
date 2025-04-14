% plotOptimizationResults - Plots optimization results for regression analysis.
%
% Syntax:
%   plotOptimizationResults(trainData, inputVars, outputVars, ...
%       igmnOptions, useMex, legends, xlabels, minMaxProportion, ranges, exportFileName)
%
% Inputs:
%   trainData          - Matrix containing the training data.
%   inputVars          - Indices of the input variables in the training data.
%   outputVars         - Indices of the output variables in the training data.
%   igmnOptions        - Structure containing options for the IGMN model.
%   useMex             - Boolean flag to use MEX functions for IGMN operations.
%   legends            - Cell array of legends for the plots.
%   xlabels            - Cell array of x-axis labels for the plots.
%   minMaxProportion   - Normalization parameters for denormalizing the outputs (optional).
%   ranges             - Matrix specifying the x-axis limits for each output variable.
%   exportFileName     - String specifying the base name for exporting plots (optional).
%
% Outputs:
%   None. This function generates and displays plots, and optionally exports them as files.
%
% Description:
%   This function trains an IGMN (Incremental Gaussian Mixture Network) model using the provided
%   training data and plots the optimization results. It compares the predicted outputs with the
%   reference targets for each output variable. The function also generates regression plots to
%   evaluate the prediction performance. Optionally, the plots can be exported as PDF files.
%
% Example:
%   plotOptimizationResults(trainData, [1, 2], [3], igmnOptions, false, ...
%       {'Input 1', 'Input 2'}, {'Output'}, [], [-1, 1; -1, 1], 'results')
%
% Notes:
%   - The function supports both MATLAB and MEX implementations of the IGMN model.
%   - The depth axis is reversed in the plots to represent typical geological data visualization.
%   - Ensure that the 'ranges' input matches the number of output variables.
%
% See also:
%   igmn, train, predict, denormalizeData, plotregression
function plotOptimizationResults(trainData, inputVars, outputVars, ...
    igmnOptions, useMex, legends, xlabels, minMaxProportion, ranges, exportFileName)

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

    if  ~isempty(minMaxProportion)
        outputs = denormalizeData(outputs, minMaxProportion, outputVars);
    end
    
    legendNames = horzcat(legends{:});
    wellFig = figure('units','normalized', 'outerposition', [0.2 0.3 0.5 0.5]);
    set(0, 'DefaultAxesFontSize', 16,  'defaultTextInterpreter', 'none');
    tiledlayout('horizontal', 'Padding', 'none', 'TileSpacing', 'loose');
    % wellFig.Parent.Name = sprintf('%s x %s | %s x %s | %s x %s', legendNames{:});
    depth = 1:size(targets, 1);
    for i = 1:O
        ax = nexttile;
        ax.FontSize = 16;
        hold on;
        plot(targets(:, i), depth, 'k', 'LineWidth', 0.5);
        xlabel(xlabels{i}, 'FontSize', 16);
        plot(outputs(:, i), depth, 'r', 'LineWidth', 1);
        legend({'Reference', 'Prediction'}, 'FontSize', 16, 'Location','best');
        if i == 1
            ylabel('Depth (m)');
        end
        set(ax, 'YTick', [])
        set(ax, 'YDir','reverse');
        xlim(ranges(:, i));
        hold off;
    end
    
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

