% plotResults - Visualizes the results of predictions and target values for 
%               multiple datasets with varying noise levels.
% 
% Syntax:
%     plotResults(net, predict, data, inputVars, outputVars, ...
%                 selectedOutVar, traceNumber, initDeth, traces, ...
%                 traceSizes, waveSize, noiseMultipliers, gridSize)
% 
% Inputs:
%     net               - Neural network model used for predictions.
%     predict           - Function handle for making predictions with the model.
%     data              - Cell array containing datasets for different noise levels.
%                         Each dataset is a cell array where the first element 
%                         contains the noisy data.
%     inputVars         - Indices of input variables in the dataset.
%     outputVars        - Indices of output variables in the dataset.
%     selectedOutVar    - Name of the selected output variable for visualization.
%     traceNumber       - Index of the trace to be visualized.
%     initDeth          - Initial depth or time offset for the visualization.
%     traces            - Array of trace indices.
%     traceSizes        - Array of trace sizes corresponding to the traces.
%     waveSize          - Size of the wavelet used in the analysis.
%     noiseMultipliers  - Array of noise multipliers for each dataset.
%     gridSize          - Number of grid points for probability visualization.
% 
% Outputs:
%     A figure displaying the predicted and target values for each dataset 
%     with varying noise levels. The visualization includes probability 
%     distributions, target traces, and predicted traces.
% 
% Internal Function:
%     plotTrace - Helper function to plot individual traces with probability 
%                 distributions and overlayed target and predicted values.
% 
%     Inputs:
%         outputValues   - Predicted output values.
%         targetValues   - Target output values.
%         indexes        - Indices for diagonal extraction of values.
%         initDeth       - Initial depth or time offset.
%         ax             - Axes handle for plotting.
%         legends        - Cell array of legend labels.
%         titleText      - Title text for the plot.
%         gridSize       - Number of grid points for probability visualization.
%         ylabelText     - Label for the y-axis.
%         withColorBar   - Boolean indicating whether to include a color bar.
%         addYTicks      - Boolean indicating whether to add y-axis ticks.
% 
%     Outputs:
%         A subplot displaying the probability distribution, target trace, 
%         and predicted trace for a single dataset.
% 
% Notes:
%     - The function uses a preloaded colormap from "prob_color_map.mat".
%     - The y-axis is reversed to match typical seismic data visualization.
%     - The function supports tiled layouts for side-by-side comparison of 
%       multiple datasets.
function plotResults(net, predict, data, inputVars, outputVars, ...
        selectedOutVar, traceNumber, initDeth, traces, traceSizes, waveSize, noiseMultipliers, gridSize)

    tracesFig = figure('units','normalized', 'outerposition', [0 0 1 1]);
    set(tracesFig, 'color', [0.8 0.8 0.8])
    layout = tiledlayout(1, numel(data), 'Padding', 'tight', 'TileSpacing', 'compact');
    prob_color_map = load("prob_color_map.mat").prob_color_map;
    for m = 1:length(data)
        noiseData = data{m}{1};
        traceSize = traceSizes(traces(traceNumber));
        inputData = noiseData(:, inputVars);
        outputValues = fliplr(predict(net, inputData, outputVars, 0, zeros(2, length(outputVars))));
        targetValues = fliplr(noiseData(:, outputVars));
        indexes = (waveSize-1):-1:(-traceSize + waveSize);

        ax = nexttile(layout);
        
        if m == numel(noiseMultipliers); withColorBar = true; else; withColorBar = false; end
        if m == 1
            legends = {'', selectedOutVar, sprintf('Pred. %s', selectedOutVar)};
            title = 'non-noisy';
            ylabelText = 'Time (ms)';
        else
            legends = {'', selectedOutVar, sprintf('Pred. %s', selectedOutVar)};
            title = sprintf('%.1f × noise ratio', noiseMultipliers(m));
            ylabelText = [];
        end
        hold(ax, 'on');
        plotTrace(outputValues, targetValues, indexes, initDeth, ...
            ax, legends, title, gridSize, ylabelText, withColorBar, m == 1)
        colormap(ax, prob_color_map);
        hold(ax, 'off');
    end
end


function plotTrace(outputValues, targetValues, indexes, initDeth, ...
    ax, legends, titleText, gridSize, ylabelText, withColorBar, addYTicks)
    outputs = arrayfun(@(k) mean(diag(outputValues, k)), indexes)';
    targets = arrayfun(@(k) mean(diag(targetValues, k)), indexes)';
    stds = arrayfun(@(k) sqrt(std(diag(outputValues, k))), indexes)';

    time = initDeth:(initDeth + numel(outputs) - 1);

    minValues = min(outputs - stds);
    maxValues = max(outputs + stds);
    domain = linspace(floor(minValues), ceil(maxValues), gridSize);
    grid = zeros(numel(time), gridSize);
    for k = 1:numel(time)
        grid(k, :) = gaussmf(domain, [stds(k)+eps outputs(k)]);
    end

    % interval = 154:305;
    interval = 1:size(time, 2);
    
    pcolor(domain, time(interval), grid(interval, :));
    shading interp;
    
    plot(ax, targets(interval), time(interval), 'k', 'LineWidth', 1);
    plot(ax, outputs(interval), time(interval), 'r', 'LineWidth', 1.5);

    time = time(interval);
    ylim(time([1, end]));
    if addYTicks
        yticks(round(linspace(time(1), time(end), 11)));
        yticklabels(round(linspace(70, 500, 11)));
    else
        yticks([]);
    end
    legend(ax, legends{:}, 'FontSize', 20);
    title(ax, titleText, 'FontSize', 28, 'FontWeight', 'bold', Interpreter='none');
    ylabel(ax, ylabelText, 'FontSize', 28);
    if withColorBar
        h = colorbar('FontSize', 28);
        ylabel(h, 'Probability', 'FontSize', 28);
    end
    ax.XAxis.FontSize = 28;
    ax.YAxis.FontSize = 28;
    set(ax, 'YDir','reverse');
end

