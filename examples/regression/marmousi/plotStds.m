% plotStds - Computes and optionally plots the standard deviations of predictions 
%            for the Incremental Gaussian Mixture Network (IGMN) model under 
%            different noise conditions.
% 
% Syntax:
%     stds = plotStds(net, predict, data, inputVars, outputVars, ...
%                     traceSizes, testTraces, initDeth, waveSize, ...
%                     traceNumber, noiseMultipliers, gridSize)
% 
% Inputs:
%     net              - IGMN model used for predictions.
%     predict          - Function handle for making predictions with the IGMN model.
%     data             - Cell array containing noisy data for each noise multiplier.
%     inputVars        - Indices of input variables in the data.
%     outputVars       - Indices of output variables in the predictions.
%     traceSizes       - Array specifying the size of each trace in the dataset.
%     testTraces       - Indices of traces used for testing.
%     initDeth         - Initial depth or starting point for the analysis.
%     waveSize         - Size of the wave window used for processing.
%     traceNumber      - Index of the trace to be analyzed.
%     noiseMultipliers - Array of noise multipliers applied to the data.
%     gridSize         - Grid size for visualization (not used in the current implementation).
% 
% Outputs:
%     stds - Matrix containing the computed standard deviations for each noise 
%            multiplier and the non-noisy case.
% 
% Description:
%     This function computes the standard deviations of the predictions made by 
%     the IGMN model for a given trace under different noise conditions. 
%     The function processes the data for each noise multiplier, extracts the 
%     relevant input variables, and computes the diagonal elements of the 
%     prediction covariance matrix for each wave window. The results are 
%     concatenated into a single matrix.
% 
%     The function includes commented-out sections for plotting the results, 
%     which can be enabled for visualization purposes.
% 
% Notes:
%     - The function assumes that the input data is organized in a cell array, 
%       where each cell corresponds to a specific noise multiplier.
%     - The commented-out sections provide additional functionality for 
%       visualization and debugging but are not executed by default.
% 
% Example:
%     stds = plotStds(net, @predictFunction, data, [1, 2], [3], ...
%                     traceSizes, testTraces, 0, 50, 1, [0.1, 0.5, 1.0], 100);
% 
%     This example computes the standard deviations for the IGMN model 
%     using the specified parameters and noise multipliers.
function stds = plotStds(net, predict, data, inputVars, outputVars, ...
        traceSizes, testTraces, initDeth, waveSize, traceNumber, noiseMultipliers, gridSize)
    ends = cumsum(traceSizes(testTraces) - waveSize + 1);
    starts = ends - (traceSizes(testTraces) - waveSize + 1) + 1;
    traceSize = traceSizes(testTraces(traceNumber));
    indexes = (waveSize-1):-1:(-traceSize + waveSize);
    % colormap('jet');

    % stdsFig = figure('units','normalized', 'outerposition', [0.15 -0.1 0.7 1.1]);
    % set(stdsFig,'Color', [.8 .8 .8])
    % layout = tiledlayout(1, numel(noiseMultipliers), 'Padding', 'tight', 'TileSpacing', 'compact');

    % figure;
    % hold on;

    % inputData = data(starts(traceNumber):ends(traceNumber), inputVars);
    % outputValues = fliplr(predict(net, inputData, outputVars, 0, zeros(2, length(outputVars))));
    % nonNousyStds = arrayfun(@(k) diag(outputValues, k)', indexes, 'UniformOutput', false);

    % plot(nonNousyStds);
    % disp(mean(nonNousyStds));

    % nonNousyStds = cat(1, nonNousyStds{waveSize:end-waveSize});
    
    % stds = zeros(size(nonNousyStds, 1) - 2*waveSize + 1, length(noiseMultipliers) + 1);
    % stds = zeros(size(Vp, 1), waveSize * (length(noiseMultipliers) + 1));
    % stds(:, 1:waveSize) = nonNousyStds;

    stds = [];

    for m = 1:numel(data)
        noiseData = data{m}{1};
        inputData = noiseData(:, inputVars);
        outputValues = fliplr(predict(net, inputData, outputVars, 0, zeros(2, length(outputVars))));
        % outputs = arrayfun(@(k) mean(diag(outputValues, k)), indexes)';
        cur_stds = arrayfun(@(k) diag(outputValues, k)', indexes, 'UniformOutput', false)';
        stds = [stds, cat(1, cur_stds{waveSize:end-waveSize})]; %#ok<AGROW>
        % plot(cur_stds);
        % disp(mean(cur_stds));
    
        % time = initDeth:(initDeth + numel(outputs) - 1);
        % 
        % ax = nexttile(layout);
        % hold(ax, 'on');
        % 
        % plot(nonNousyStds(2:end-1), time(2:end-1), 'Color', 'k', 'LineWidth', 0.5);
        % plot(stds(2:end-1), time(2:end-1), 'Color', 'r', 'LineWidth', 0.5);
        % barh(time(2:end-1), abs(stds(2:end-1) - nonNousyStds(2:end-1, 1)), 'FaceColor', "#EDB120");
        % % plot(targets(2:end-1), time(2:end-1), 'Color', colors(4, :), 'LineWidth', 1);
        % % plot(nonNoisyOutputs(2:end-1), time(2:end-1), 'Color', colors(5, :), 'LineWidth', 1);
        % % plot(outputs(2:end-1), time(2:end-1), 'Color', colors(6, :), 'LineWidth', 1);
        % if m == 1
        %     ylabel(ax, 'Time (ms)', 'FontSize', 38);
        % end
        % titleText = sprintf('%.1f × noise ratio', noiseMultipliers(m));
        % title(ax, titleText, 'FontSize', 38) 
        % ylim(time([2, end-1]));
        % yticklabels(round(linspace(70, 500, 11)))
        % if m == 1
        %     yticks(round(linspace(time(2), time(end-1), 11)));
        %     yticklabels(round(linspace(70, 500, 11)));
        % else
        %     yticks([]);
        % end
        % xlim([0, max([nonNousyStds(2:end-1), stds(2:end-1)], [], 'all')])
        % set(gca, 'YDir','reverse');
        % legend('Non-Noisy', 'Noisy', 'Uncert.', 'FontSize', 30, 'Location', 'northeast');
        % ax.XAxis.FontSize = 38;
        % ax.YAxis.FontSize = 38;
        % hold(ax, 'off');
    end
end

