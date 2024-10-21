% Cleanning up the workspace
dbstop if error
clear all; %#ok<CLALL> 
close all;
clc;

rng('default');
rng(42);

%% Add some external dependencies
addpath('../../../igmn/');
addpath(genpath('../../../Seislab 3.02'));
addpath(genpath('../../../GeoStatRockPhysics/SeReM/'))

% colors = distinguishableColors(6);
% colororder(colors);

colormap(parula);

%% Do some configurations
nSim = 100;
discretizationSize = 25;
showPlots = true;
useFacies = true;

%% Create synthetic well data
[modelData, wellData] = genPseudoWell(nSim, useFacies, showPlots, true);
% trainData = trainData(randperm(size(trainData, 1)), :);
depth = wellData(:, 1);
facies = wellData(:, 2);

trainData = modelData;
% trainData = trainData(randperm(size(trainData, 1)), :);
if useFacies
    testData = wellData(:, 2:end);
else
    testData = wellData(:, 3:end);
end

%% Problem Configs

normalize = false;
nvars = 6; %#ok<NASGU>
numberOfOutputVars = 3;
if useFacies; nvars = 7; end
inputVars = 1:nvars - numberOfOutputVars;
outputVars = nvars - numberOfOutputVars + 1:nvars;

targets = testData(:, outputVars);

variableNames = {'Vp', 'Vs', 'Rho', 'Porosity (v/v)', 'Clay Vol. (v/v)', 'Water Sat. (v/v)'};
if useFacies; variableNames = ['Facies', variableNames]; end


minMaxProportion = [];
if normalize
    [testData, minMaxProportion] = normalizeData(testData);
    trainData = normalizeData(trainData, minMaxProportion);
end
inputs = testData(:, inputVars);
allData = [trainData; testData];

problem = Problem( ...
    trainData, ...
    testData, ...
    'InputVarIndexes', inputVars, ...
    'OutputVarIndexes', outputVars, ...
    'AllData', allData, ...
    'ExecutionMode', 'mex', ...
    'DoParametersTuning', false, ...
    'CompileOptions', compileoptions(...
        'EnableRecompile', false, ...
        'NumberOfVariables', nvars, ...
        'NumberOfOutputVars', numberOfOutputVars, ...
        'IsOptimization', true));

problem.OptimizeOptions.Algorithm = 'imode';
problem.OptimizeOptions.UseDefaultsFor = {'UseRankOne', 'MaxNc'};
problem.OptimizeOptions.MaxFunEval = 30000;
problem.OptimizeOptions.PopulationSize = 10;
problem.OptimizeOptions.StallIterLimit = 400;
problem.OptimizeOptions.UseParallel = true;
problem.OptimizeOptions.TolFunValue = 1e-18;

problem.OptimizeOptions.hyperparameters{1}.ub = 0.5;
problem.OptimizeOptions.hyperparameters{1}.lb = 1.0e-3;
problem.OptimizeOptions.hyperparameters{2}.ub = 0.4;
problem.OptimizeOptions.hyperparameters{2}.lb = 1.0e-15;
problem.OptimizeOptions.hyperparameters{6}.ub = 50;
problem.OptimizeOptions.hyperparameters{6}.lb = 8;
problem.OptimizeOptions.hyperparameters{5}.ub = 6;
problem.OptimizeOptions.hyperparameters{5}.lb = 3;
problem.OptimizeOptions.hyperparameters{7}.ub = 1.0e-2;

problem.DefaultIgmnOptions.UseRankOne = 1;
problem.DefaultIgmnOptions.MaxNc = 50;

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
    legends = cell(1, numberOfOutputVars);
    for i = 1:numberOfOutputVars
        variablenName = variableNames{outputVars(i)};
        legends{i} = {
            '', ... % Confidence Interval?
            variablenName, ...
            sprintf('%s Pred.', variablenName) ...
        };
    end
    
    xlabels = cell(1, numberOfOutputVars);
    for i = 1:numberOfOutputVars; xlabels{i} = legends{i}{2}; end
    
    %% Do IGMN optinmization (find good hyperparameters)
    if problem.DoParametersTuning
        tic;
        igmnOptions = optimize(problem);
        save('igmnOptions', 'igmnOptions');
        toc;
        % igmnOptions.MaxNc = size(trainData, 1) + 1;
        % Plot otimization results
        legendsTrain = cell(1, numberOfOutputVars);
        for i = 1:numberOfOutputVars
            variablenName = variableNames{outputVars(i)};
            legendsTrain{i} = {variablenName,  sprintf('%s Pred.', variablenName)};
        end
        plotOptimizationResults(trainData, inputVars, outputVars, igmnOptions, ...
            problem.ExecutionMode == 'mex', legendsTrain, xlabels, minMaxProportion, [0 0.4; 0, 0.8; 0, 1]', 'toy_train_results');
    else
        igmnOptions = load('igmnOptions.mat').igmnOptions;
    end
    
    % Testing & do some plots
    net = igmn(igmnOptions);
    tic;
    net = train(net, trainData); %#ok<*UNRCH>
    toc;
    % tic;
    % [outputs, ~] = predict(net, inputs, outputVars, 0);
    % toc;
    tic;
    [outputs, gridProbabilities] = predict(net, inputs, outputVars, discretizationSize, [0 0.4; 0, 0.8; 0, 1]');
    toc;
    
    if normalize; outputs = denormalizeData(outputs, minMaxProportion, outputVars); end
    gridDomainProbabilities = computeDomainProbabilities(gridProbabilities, outputVars, discretizationSize);
    probabilities = cell(1, numberOfOutputVars);
    for i = 1:numberOfOutputVars; probabilities{i} = squeeze(gridDomainProbabilities(i, :, :)); end
    
    variableRanges = horzcat([min(wellData(:, inputVars)); max(wellData(:, inputVars))], [0 0.4; 0, 0.8; 0, 1]');
    %variableRanges = horzcat([min([modelData; wellData(:, 2:end)]); max([modelData; wellData(:, 2:end)])]);
    outputsDomain = cell(1, numberOfOutputVars);
    for i = 1:numberOfOutputVars
        interval = variableRanges(:, outputVars(i));
        outputsDomain{i} = linspace(interval(1), interval(2), discretizationSize);
    end
    initDeth = 1; endDepth = length(depth);
    % initDeth = 3939; endDepth = 5252;
    plotResults(targets, outputs, xlabels, depth, facies, legends, ...
        outputVars, variableRanges, variableNames, outputsDomain, ...
        probabilities, initDeth, endDepth, 'IGMN Inversion', 'toy_predict_results');
    
    %% Compare with RockPhysicsKDEInversion
    % [outputs, probabilities, outputsDomain] = kdeInversion(modelData, wellData(:, 2:end));
    % plotResults(targets, outputs, xlabels, depth, facies, legends, ...
    %         outputVars, variableRanges, variableNames, outputsDomain, probabilities, 'KDE Inversion');
end

