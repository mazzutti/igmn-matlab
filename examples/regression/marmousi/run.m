%{

This script performs regression analysis using the Incremental Gaussian Mixture Network (IGMN) 
and compares its performance with Ensemble Smoother with Multiple Data Assimilation (ES-MDA). 
The script includes data preparation, model training, optimization, and visualization of results.

Key functionalities:
1. Data Preparation:
    - Generates synthetic data or loads pre-existing data.
    - Configures training and testing datasets with specified trace numbers and noise levels.

2. Model Configuration:
    - Defines input and output variables for the regression problem.
    - Configures hyperparameters and optimization settings for the IGMN model.

3. Model Training and Optimization:
    - Compiles the IGMN model for execution in 'mex' or 'native' mode.
    - Tunes model parameters or loads pre-tuned parameters.
    - Trains the IGMN model on the training dataset.

4. Visualization:
    - Plots results, including predictions, uncertainties, and comparisons with ES-MDA.
    - Exports visualizations to PDF files for further analysis.

5. Statistical Analysis:
    - Computes and visualizes variance and uncertainty metrics for different noise levels.
    - Normalizes and compares the performance of IGMN and ES-MDA.

Global Variables:
- traceSizes: Stores the sizes of seismic traces.
- testTraces: Contains indices of test traces.
- targets: Stores target values for regression.

Dependencies:
- Requires external libraries: 'igmn', 'GeoStatRockPhysics/SeReM', and 'Seislab 3.02'.
- Uses custom functions such as `prepareData`, `optimize`, `igmnBuilder_mex`, `train_mex`, 
  `predict_mex`, `plotResults`, `plotStds`, and `runSeReM`.

Execution Modes:
- 'mex': Executes compiled MATLAB code for improved performance.
- 'native': Executes MATLAB code without compilation.

Note:
- Ensure all required dependencies and data files are available in the specified paths.
- Modify hyperparameter bounds and optimization settings as needed for specific use cases.
%}
%#ok<*UNRCH>
%#ok<*CLALL> 

dbstop if error
clear all;
close all;
clc;

global traceSizes %#ok<*GVMIS>
global testTraces
global targets

rng('default');
rng(23);

addpath(genpath('../../../examples/'));
addpath('../../../igmn/');
addpath(genpath('../../../GeoStatRockPhysics/SeReM/'));
addpath(genpath('../../../Seislab 3.02/Seislab 3.02/')); presets;
load('cmaps.mat');

theta = 15:15:45;
genSynthData = true;
discretizationSize = 10;
initDeth = 396;
noiseMultipliers = [0, 0.1, 0.5, 1];

trainTraces = [680, 2040, 3400, 4760, 6120, 7481, 8841, 10201, 11561, 12921];
testTraces = [2334, 6941, 8277, 11238];
waveSize = 5;

selectedOutVar = 'AI';
variableNames = [arrayfun(@num2str, 15:15:45, 'UniformOutput', 0), {'lowAI'}, {'AI'}];

[trainData, testData, allData, traceSizes, targets, noisyTestData] = ...
    prepareData(genSynthData, trainTraces, testTraces, initDeth, waveSize, noiseMultipliers, false);

traceNumber = 3;
% plotAIForPaper(squeeze(allData(:, :, end)), trainTraces, testTraces(traceNumber), initDeth, 'AI_data');

numberOfOutputVars = waveSize;
nvars = (numel(theta) + 1) * waveSize + numberOfOutputVars;
inputVars = 1:(nvars - numberOfOutputVars);
outputVars = (numel(inputVars) + 1):nvars;

logIndexes = outputVars;
valTrainData = [trainData ; testData];

problem = Problem( ...
    trainData, ...
    testData, ...
    'InputVarIndexes', inputVars, ...
    'OutputVarIndexes', outputVars, ...
    'AllData', valTrainData, ...
    'ExecutionMode', 'mex', ...
    'DoParametersTuning', false, ...
    'CompileOptions', compileoptions(...
        'EnableRecompile', false, ...
        'NumberOfVariables', nvars, ...
        'NumberOfOutputVars', numberOfOutputVars, ...
        'IsOptimization', true));

problem.OptimizeOptions.Algorithm = 'gsapso';
problem.OptimizeOptions.UseDefaultsFor = {'MaxNc', 'UseRankOne'};
problem.OptimizeOptions.MaxFunEval = 3000000;
problem.OptimizeOptions.PopulationSize = 120;
problem.OptimizeOptions.StallIterLimit = 400;
problem.OptimizeOptions.UseParallel = true;
problem.OptimizeOptions.TolFunValue = 1e-18;

problem.OptimizeOptions.hyperparameters{6}.ub = 50;
problem.OptimizeOptions.hyperparameters{6}.lb = 9;
problem.OptimizeOptions.hyperparameters{5}.ub = 8;
problem.OptimizeOptions.hyperparameters{5}.lb = 2;
problem.OptimizeOptions.hyperparameters{2}.ub = 0.99;
problem.OptimizeOptions.hyperparameters{2}.lb = 1e-18;
problem.OptimizeOptions.hyperparameters{1}.ub = 0.99;
problem.OptimizeOptions.hyperparameters{1}.lb = 1e-18;
problem.OptimizeOptions.hyperparameters{7}.ub = 1e-2;

problem.DefaultIgmnOptions.UseRankOne = 1;
problem.DefaultIgmnOptions.MaxNc = 100;

if strcmpi(problem.ExecutionMode, 'mex') || strcmpi(problem.ExecutionMode, 'native') 
    compile(problem);
    if strcmpi(problem.ExecutionMode, 'mex')
        optimize = @optimize_mex;
        igmn = @igmnBuilder_mex;
        train = @train_mex;
        predict = @predict_mex;
    end
end

if ~strcmpi(problem.ExecutionMode, 'native')
    if problem.DoParametersTuning
        igmnOptions = optimize(problem);
        save('igmnOptions', 'igmnOptions');
    else
        igmnOptions = load('igmnOptions.mat').igmnOptions;
    end
    
    tic;
    net = igmn(igmnOptions);
    net = train(net, trainData);
    toc;
   
    gridSize = 50;
    set(0, 'DefaultAxesFontSize', 12);
    traceNoisyTestData = noisyTestData{traceNumber};
    plotResults(net, predict, traceNoisyTestData, inputVars, outputVars, selectedOutVar, ...
        traceNumber, initDeth, testTraces, traceSizes, waveSize, noiseMultipliers, gridSize);
    
    exportgraphics(gcf, sprintf('%s.pdf', 'std_with_noisy_seismic'), 'Resolution', 300)
    
    stds_igmn = plotStds(net, predict, traceNoisyTestData, inputVars, outputVars, ...
        traceSizes, testTraces, initDeth, waveSize, traceNumber, noiseMultipliers, gridSize);

    stds_esmda = runSeReM(waveSize, theta, true, traceNoisyTestData);

    stds_fig = figure('units','normalized', 'outerposition', [0.3 0.15 0.5 0.8]);
    set(stds_fig, 'color', [254/255, 252/255, 246/255]);
    set(0, 'DefaultAxesFontSize', 22,  'defaultTextInterpreter', 'latex');
    layout = tiledlayout(2, 2, 'Padding', 'tight', 'TileSpacing', 'compact');
    N = length(noiseMultipliers);
    cmap = parula;
    for i = 1:N
        ax = nexttile;
        std_esmda = normalize(std(stds_esmda(:, (i-1) * waveSize+1:i*waveSize), [], 2) .^ 2);
        std_igmn = normalize(std(stds_igmn(:, (i-1) * waveSize+1:i*waveSize), [], 2) .^ 2);
        hg = histogram(ax, std_esmda);
        hg.FaceColor = [65/255, 144/255, 160/255];
        hold on;
        hg = histogram(ax, std_igmn);
        hg.FaceColor = [242/255, 187/255, 68/255];
        legend('ES-MDA', 'Bagging ANN', 'FontSize', 16);
        title(sprintf("%.1f x noise ratio", noiseMultipliers(i)), 'FontWeight', 'bold');
        if mod(i, 2) == 0
            yticks([]);
        else
            ylabel('Frequency')
        end

        if i >= 3
            xlabel('$\sigma^2$');
        end
    end

    exportgraphics(gcf, "esmda_x_ann_variance.pdf", 'Resolution', 300)

    labels = {'0.0', '0.1', '0.5', '1'};
end
