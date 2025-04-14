% plotOptimizationRegressions - Plots regression results for optimization tasks.
% 
% This function visualizes the regression results of a trained IGMN (Incremental 
% Gaussian Mixture Network) model, optionally combined with Kriging for 
% conditioning. It supports both MATLAB and MEX implementations of the IGMN 
% functions and allows exporting the resulting plot to a PDF file.
% 
% Inputs:
%     trainData       - A matrix containing the training data.
%     inputVars       - Indices of the input variables in the training data.
%     outputVars      - Indices of the output variables in the training data.
%     igmnOptions     - Options structure for configuring the IGMN model.
%     useMex          - Boolean flag to use MEX implementations of IGMN functions.
%     legends         - Cell array of legend entries for the plot.
%     exportFileName  - (Optional) Base name for exporting the plot as a PDF.
%     useKriging      - Boolean flag to enable Kriging-based conditioning.
%     krigvars        - Variance values for Kriging conditioning.
%     krigmeans       - Mean values for Kriging conditioning.
%     min2norm        - Minimum normalization value (unused in the current code).
%     max2norm        - Maximum normalization value (unused in the current code).
% 
% Outputs:
%     None. The function generates a regression plot and optionally exports it 
%     as a PDF file.
% 
% Notes:
%     - The function uses the `plotregression` function to generate the regression 
%       plots.
%     - If Kriging is enabled, the outputs are conditioned using the provided 
%       Kriging parameters and transformed using a non-parametric mapping.
%     - The function modifies the marker style of the regression plots for better 
%       visualization.
%     - The export functionality requires the `exportgraphics` function, which is 
%       available in MATLAB R2020a and later.
% 
% Example:
%     plotOptimizationRegressions(trainData, [1, 2], [3], igmnOptions, false, ...
%         {'Input1', 'Input2'}, 'regression_plot', true, krigvars, krigmeans, 0, 1);
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

