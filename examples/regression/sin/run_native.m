% run_native - Executes a regression example using the IGMN algorithm.
%
% This function demonstrates the use of the Incremental Gaussian Mixture
% Network (IGMN) for regression on a sine wave dataset. It includes
% parameter tuning using a custom Particle Swarm Optimization (PSO)
% implementation located in `igmn/private/pso.m` and plots the regression
% results.
%
% The function performs the following steps:
% 1. Generates input and output data for a sine wave.
% 2. Configures the optimization problem for tuning IGMN parameters.
% 3. Optimizes the IGMN hyperparameters using the custom PSO implementation
%    if parameter tuning is enabled.
% 4. Trains the IGMN model on the training data.
% 5. Predicts the output for test data using the trained IGMN model.
% 6. Plots the regression results using a regression plot.
%
% INPUTS:
%   None.
%
% OUTPUTS:
%   None. The function generates a regression plot as output.
%
% DEPENDENCIES:
%   - Problem: A class or function to define the optimization problem.
%   - compileoptions: A function to configure compilation options.
%   - optimizeoptions: A function to configure optimization options.
%   - optimize: A function to perform parameter optimization using the
%     custom PSO implementation in `igmn/private/pso.m`.
%   - igmnBuilder: A function to create an IGMN model.
%   - train: A function to train the IGMN model.
%   - predict: A function to make predictions using the trained IGMN model.
%   - plotregression: A function to plot regression results.
%
% NOTES:
%   - The function uses a custom PSO implementation for hyperparameter tuning.
%   - The IGMN model is trained and tested on shuffled sine wave data.
%   - The function includes options for parallel computation and fine-tuning
%     of optimization parameters.
function run_native()
    inputData = 0:0.01:(2 * pi);
    inputData = inputData(randperm(size(inputData, 2)));
    outputData = linspace(0, 2 * pi, 100);

    maxNc = 8;

    problem = Problem( ...
        [inputData; sin(inputData)]', ...
        [outputData; sin(outputData)]', ...
        'ExecutionMode', 'native', ...
        'DoParametersTuning', true, ...
        'CompileOptions', compileoptions(...
            size(inputData, 2), size(outputData, 2),  ...
            'NumberOfVariables', 2, ...
            'NumberOfOutputVars', 1, ...
            'EnableRecompile', true, ...
            'IsOptimization', true ...
        ));

    populationSpan = optimizeoptions.initialPopulationSpan([], problem.OptimizeOptions.hyperparameters);
    coder.varsize('populationSpan');
    
    % problem.OptimizeOptions.PlotFcns = {};
    problem.OptimizeOptions.InitialPopulationSpan = populationSpan;
    problem.OptimizeOptions.Algorithm = 'pso';
    problem.OptimizeOptions.SelfAdjustment = 1.49;
    problem.OptimizeOptions.SocialAdjustment = 1.49;
    problem.OptimizeOptions.UseDefaultsFor = {'MaxNc', 'UseRankOne'};
    % problem.DefaultIgmnOptions.Phi = 1;
    problem.OptimizeOptions.MaxFunEval = 10000;
    problem.OptimizeOptions.PopulationSize = 100;
    problem.OptimizeOptions.UseParallel = false;
    problem.OptimizeOptions.TolFunValue = 1e-12;
    problem.DefaultIgmnOptions.MaxNc = maxNc;
    problem.DefaultIgmnOptions.UseRankOne = 1;
    % problem.DefaultIgmnOptions.SPMin = 4
    % problem.DefaultIgmnOptions.Delta = 0.1;

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

    net = igmnBuilder(igmnOptions);
    net = train(net, trainData);
    Y = predict(net, testData(:, inputVarIndexes), outputVarIndexes, 0);
    coder.extrinsic('plotregression');
    figure; plotregression(testData(:, outputVarIndexes), Y);
end

