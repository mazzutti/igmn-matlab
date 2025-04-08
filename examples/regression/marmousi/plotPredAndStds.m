%{
% plotPredAndStds - Plots predictions and standard deviations for seismic data.

% Syntax:
%   plotPredAndStds(net, predict, data, inputVars, outputVars, noise, theta, ...
%       traceSizes, testTraces, initDeth, waveSize, traceNumber, noiseMultipliers, gridSize)

% Inputs:
%   net              - Neural network model used for predictions.
%   predict          - Function handle for making predictions with the neural network.
%   data             - Matrix containing the input seismic data.
%   inputVars        - Indices of the input variables in the data matrix.
%   outputVars       - Indices of the output variables in the data matrix.
%   noise            - Noise parameters for adding seismic noise.
%   theta            - Parameter controlling the noise characteristics.
%   traceSizes       - Vector containing the sizes of seismic traces.
%   testTraces       - Indices of the test traces in the data.
%   initDeth         - Initial depth value for plotting.
%   waveSize         - Size of the wave window used for processing.
%   traceNumber      - Index of the trace to be plotted.
%   noiseMultipliers - Array of multipliers for scaling the noise levels.
%   gridSize         - Grid size for plotting (not used in the function).

% Outputs:
%   This function does not return any outputs. It generates a figure with
%   subplots showing the predictions and standard deviations for the selected
%   seismic trace under different noise levels.

% Description:
%   The function visualizes the effect of noise on seismic data predictions
%   by plotting the predicted outputs and their standard deviations for a
%   selected trace. It compares the predictions with and without noise and
%   highlights the absolute differences in standard deviations. The function
%   uses a tiled layout to display results for different noise multipliers.

% Example:
%   plotPredAndStds(net, @predictFunction, seismicData, [1, 2], [3], noiseParams, ...
%       thetaValue, traceSizesArray, testTraceIndices, 100, 50, 1, [0.5, 1.0, 1.5], gridSize);

% Notes:
%   - The function assumes that the input data is preprocessed and formatted
%     appropriately for the neural network.
%   - The `addSeismicNoise` function is used to add noise to the data.
%   - The `predict` function should return a matrix where each diagonal
%     corresponds to predictions for a specific time lag.

% See also:
%   addSeismicNoise, predict
%}
function plotPredAndStds(net, predict, data, inputVars, outputVars, noise, theta, ...
        traceSizes, testTraces, initDeth, waveSize, traceNumber, noiseMultipliers, gridSize)
    ends = cumsum(traceSizes(testTraces) - waveSize + 1);
    starts = ends - (traceSizes(testTraces) - waveSize + 1) + 1;
    traceSize = traceSizes(testTraces(traceNumber));
    indexes = (waveSize-1):-1:(-traceSize + waveSize);
    colormap('jet');

    stdsFig = figure;
    set(stdsFig,'Color', [.8 .8 .8])
    layout = tiledlayout(1, numel(noiseMultipliers), 'Padding', 'tight', 'TileSpacing', 'tight');

    inputData = data(starts(traceNumber):ends(traceNumber), inputVars);
    outputValues = fliplr(predict(net, inputData, outputVars, 0));
    nonNousyStds = arrayfun(@(k) sqrt(std(diag(outputValues, k))), indexes)';
    nonNoisyOutputs = arrayfun(@(k) mean(diag(outputValues, k)), indexes)';

    for m = 1:numel(noiseMultipliers)
        noiseData = addSeismicNoise(data, theta, waveSize, ...
            noise, testTraces, traceSizes, starts, noiseMultipliers(m));
        inputData = noiseData(starts(traceNumber):ends(traceNumber), inputVars);
        outputValues = fliplr(predict(net, inputData, outputVars, 0));
        outputs = arrayfun(@(k) mean(diag(outputValues, k)), indexes)';
        stds = arrayfun(@(k) sqrt(std(diag(outputValues, k))), indexes)';
    
        time = initDeth:(initDeth + numel(outputs) - 1);

        ax = nexttile(layout);
        hold(ax, 'on');

        plot(nonNoisyOutputs(2:end-1), time(2:end-1), 'r', 'LineWidth', 0.75);
        plot(outputs(2:end-1), time(2:end-1), 'k', 'LineWidth', 0.75);
        barh(time(2:end-1), abs(stds(2:end-1) - nonNousyStds(2:end-1, 1)), 'b',  'FaceAlpha', 0.4);
        ylim(time([2, end-1]));
        set(gca, 'YDir','reverse');
        legend('non-noisy pred.', sprintf('noisy pred. (%.1f)', noiseMultipliers(m)), 'abs. std diff');
        hold(ax, 'off');
    end
end

