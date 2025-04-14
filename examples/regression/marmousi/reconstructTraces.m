% reconstructTraces - Reconstructs and visualizes seismic traces using a neural network.
%
%   reconstructTraces(net, data, traceSizes, inputVars, outputVars, outvarNames, predict)
%
%   This function processes seismic trace data, applies a neural network
%   model to predict output variables, and visualizes the real and predicted
%   traces side by side for comparison.
%
%   Inputs:
%       net         - Neural network model used for prediction.
%       data        - Matrix containing the input and output data.
%       traceSizes  - Vector specifying the size of each trace.
%       inputVars   - Indices of the input variables in the data matrix.
%       outputVars  - Indices of the output variables in the data matrix.
%       outvarNames - Cell array of strings containing names of the output variables.
%       predict     - Function handle for the prediction method of the neural network.
%
%   Outputs:
%       None. The function generates a figure displaying the real and
%       predicted traces for each output variable.
%
%   Visualization:
%       - The function creates a tiled layout with two columns for each
%         output variable: one for the real traces and one for the predicted
%         traces.
%       - The depth axis is reversed for better visualization of seismic data.
%       - The figure includes a title summarizing the comparison.
%
%   Example:
%       reconstructTraces(net, data, traceSizes, [1, 2], [3], {'Velocity'}, @predict)
%
%   Notes:
%       - The function assumes that the input data is preprocessed and
%         normalized appropriately for the neural network.
%       - The exponential function (exp) is applied to both the predicted
%         and real data, assuming the data is in log scale.
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
