%{

This script demonstrates the use of Incremental Gaussian Mixture Networks (IGMN) 
for regression tasks using sinusoidal data. The script includes data preparation, 
parameter tuning, model training, and prediction. It also visualizes the results 
and exports the Gaussian components of the trained network.

Main Steps:
1. Clear workspace, close figures, and set random seed for reproducibility.
2. Add the IGMN library to the MATLAB path.
3. Generate input and output data for the regression task.
4. Define the maximum number of Gaussian components (`maxNc`).
5. Create a `Problem` object to configure the regression task, including:
    - Input and output data.
    - Execution mode (e.g., 'mex' or 'native').
    - Parameter tuning options.
    - Compilation options for optimization.
6. Configure optimization options for hyperparameter tuning, such as:
    - Algorithm type.
    - Self and social adjustment factors.
    - Population size and parallel execution.
    - Tolerance and stopping criteria.
7. Compile the problem if the execution mode is 'mex' or 'native'.
8. Perform parameter tuning if enabled.
9. Train the IGMN model using the training data.
10. Predict the output for test data and evaluate the results.
11. Visualize the regression results and Gaussian components of the trained network.
12. Export the visualization as a PDF file.

Key Parameters:
- `maxNc`: Maximum number of Gaussian components.
- `ExecutionMode`: Determines whether to use 'mex' or 'native' execution.
- `OptimizeOptions`: Contains settings for hyperparameter optimization.
- `DefaultIgmnOptions`: Default options for the IGMN model.

Visualization:
- Regression results are plotted using `plotregression`.
- Gaussian components are visualized using `plotNet`.

Dependencies:
- The script requires the IGMN library and its associated functions 
  (e.g., `optimize_mex`, `igmnBuilder_mex`, `train_mex`, `predict_mex`).

Output:
- Regression performance visualization.
- Exported PDF file showing the Gaussian components of the trained network.
%}
clear all; %#ok<CLALL> 
close all;
clc;
rng('default');
rng(42);

addpath('../../../igmn/');

inputData = 0:0.01:(2 * pi);
inputData = inputData(randperm(size(inputData, 2)));
outputData = linspace(0, 2 * pi, 100);

maxNc = 3;

problem = Problem( ...
    [inputData; sin(inputData)]', ...
    [outputData; sin(outputData)]', ...
    'ExecutionMode', 'mex', ...
    'DoParametersTuning', true, ...
    'CompileOptions', compileoptions(...
        size(inputData, 2), size(outputData, 2),  ...
        'NumberOfVariables', 2, ...
        'NumberOfOutputVars', 1, ...
        'EnableRecompile', true, ...
        'IsOptimization', true ...
    ));

% problem.OptimizeOptions.PlotFcns = {};
problem.OptimizeOptions.Algorithm = 'imode';
problem.OptimizeOptions.SelfAdjustment = 1.49;
problem.OptimizeOptions.SocialAdjustment = 1.49;
problem.OptimizeOptions.UseDefaultsFor = {'MaxNc', 'UseRankOne'};
% problem.DefaultIgmnOptions.Phi = 1;
problem.OptimizeOptions.MaxFunEval = 100000;
problem.OptimizeOptions.PopulationSize = 30;
problem.OptimizeOptions.UseParallel = true;
problem.OptimizeOptions.StallIterLimit = 200;
problem.OptimizeOptions.TolFunValue = 1e-12;
problem.DefaultIgmnOptions.MaxNc = maxNc;
problem.DefaultIgmnOptions.UseRankOne = 1;
problem.DefaultIgmnOptions.SPMin = 2;
% problem.DefaultIgmnOptions.Delta = 0.1;
problem.OptimizeOptions.hyperparameters{5}.ub = 6;
problem.OptimizeOptions.hyperparameters{5}.lb = 2;


if strcmpi(problem.ExecutionMode, 'mex') || strcmpi(problem.ExecutionMode, 'native') 
    compile(problem);
    if strcmpi(problem.ExecutionMode, 'mex')
        optimize = @optimize_mex;
        igmnBuilder = @igmnBuilder_mex;
        train = @train_mex;
        predict = @predict_mex;
    end
end

if ~strcmpi(problem.ExecutionMode, 'native')
    igmnOptions = problem.DefaultIgmnOptions;
    if problem.DoParametersTuning
        tic;
        igmnOptions = optimize(problem);
        toc;
    end
    
    trainData = problem.trainData;
    testData = problem.testData;    
    inputVarIndexes = problem.InputVarIndexes;
    outputVarIndexes = problem.OutputVarIndexes;
    
    tic;
    net = igmnBuilder(igmnOptions);
    net = train(net, trainData);
    Y = predict(net, testData(:, inputVarIndexes), ...
        outputVarIndexes, 0, zeros(size(net.range(:, outputVarIndexes))));
    toc;
    
    figure; plotregression(testData(:, outputVarIndexes), Y);
    figure;
    scatter(inputData + rand(1, size(inputData, 2)) .* 0.2, sin(inputData), 'Marker', '.' ,'Color', [0 0.4470 0.7410]);
    plotNet(net, 'sd', 4.5, 'ax', gca, 'sd', 2);
    exportgraphics(gcf, sprintf('%s.pdf', 'igmn_gaussians'), 'BackgroundColor', 'none', 'Resolution', 300)

end
