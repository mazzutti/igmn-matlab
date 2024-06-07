%% Cleanning up the workspace
dbstop if error
clear all; %#ok<CLALL> 
close all;
clc;

%% Add some external dependencies
addpath('../../../igmn/');
addpath(genpath('../../../Seislab 3.02'));
addpath(genpath('../../../SeReM/'))
addpath(genpath('../../../4DStatisticalRockPhysics/'))


%% Configs
useMex = true;
nSubSamp = 20000;
slice = 5;
discretizationSize = 25;
include5Years = true;
useFacies = false;
normalize = true;

% Model Options

if include5Years
    inputVars = [1, 2, 3, 4];
    outputVars = [5, 6, 7];
else
    inputVars = [1, 2]; %#ok<UNRCH>
    outputVars = [3, 4];
end

if useFacies
    inputVars = [inputVars length(inputVars) + 1]; %#ok<UNRCH>
    outputVars = outputVars + 1;
end

[origTrainData, origTestData, cubeSize] = prepareData(nSubSamp, useFacies, slice, include5Years);

allData = [origTrainData; origTestData];
trainData = origTrainData;
testData = origTestData;
targets = testData(:, outputVars);

if normalize
    [allData, minMaxProportion] = normalizeData(allData);
    testData = normalizeData(testData, minMaxProportion);
    trainData = normalizeData(trainData, minMaxProportion);
end

O = length(outputVars);
I = length(inputVars);

problem = Problem( ...
    trainData, ...
    testData, ...
    'InputVarIndexes', inputVars, ...
    'OutputVarIndexes', outputVars, ...
    'AllData', allData, ...
    'UseMex', true, ...
    'DoParametersTuning', true, ...
    'CompileOptions', compileoptions(...
        'EnableRecompile', false, ...
        'NumberOfVariables', I + O, ...
        'NumberOfOutputVars', O, ...
        'IsOptimization', true));

problem.OptimizeOptions.Algorithm = 'pso';
% problem.OptimizeOptions.UseDefaultsFor = {'SPMin'};
problem.OptimizeOptions.MaxFunEval = 30000;
problem.OptimizeOptions.PopulationSize = 300;
problem.OptimizeOptions.StallIterLimit = 40;
problem.OptimizeOptions.UseParallel = true;
problem.OptimizeOptions.TolFunValue = 1e-18;

problem.OptimizeOptions.hyperparameters{8}.lb = 3;
% problem.OptimizeOptions.hyperparameters{1}.ub = 1.0 - 1.0e-8;
% problem.OptimizeOptions.hyperparameters{1}.lb = 1.0e-8;
% problem.OptimizeOptions.hyperparameters{2}.ub = 1.0 - 1.0e-8;
% problem.OptimizeOptions.hyperparameters{2}.lb = 1.0e-8;
problem.OptimizeOptions.hyperparameters{3}.lb = 0.1;
problem.OptimizeOptions.hyperparameters{6}.ub = 80;
problem.OptimizeOptions.hyperparameters{6}.lb = 10;
problem.OptimizeOptions.hyperparameters{5}.ub = 4;
problem.OptimizeOptions.hyperparameters{5}.lb = 2;
problem.OptimizeOptions.hyperparameters{7}.ub = 1.0e-2;

% problem.DefaultIgmnOptions.MaxNc = 30;
problem.DefaultIgmnOptions.SPMin = 3;
problem.DefaultIgmnOptions.RegValue = 0;
problem.DefaultIgmnOptions.VMin = 40;
problem.DefaultIgmnOptions.RegValue = 1.2e-08;
problem.DefaultIgmnOptions.Tau = 0.14;
problem.DefaultIgmnOptions.Delta = 0.66;
problem.DefaultIgmnOptions.Gamma = 1;
problem.DefaultIgmnOptions.Phi = 1;

if problem.UseMex
    compile(problem.CompileOptions);
    optimize = @optimize_mex;
    igmn = @igmnBuilder_mex;
    train = @train_mex;
    predict = @predict_mex;
end

igmnOptions = problem.DefaultIgmnOptions;
if problem.DoParametersTuning
    tic;
    igmnOptions = optimize(problem);
    toc;
    % igmnOptions.MaxNc = size(trainData, 1) + 1;
    % % Plot otimization results
    % legendsTrain = cell(1, numberOfOutputVars);
    % for i = 1:numberOfOutputVars
    %     variablenName = variableNames{outputVars(i)};
    %     legendsTrain{i} = {variablenName,  sprintf('%s Pred.', variablenName)};
    % end
    % plotOptimizationResults(trainData, inputs, targets, igmnOptions, ...
    %     problem.UseMex, outputVars, depth, legendsTrain, xlabels, minMaxProportion, 'toy_train_results');
end

%% IGMN petrophysical 4D inversion

net = igmn(igmnOptions);
net = train(net, trainData);
outputs = predict(net, testData, outputVars, 0);

if normalize
    outputs = denormalizeData(outputs, minMaxProportion, outputVars);
end

f = figure;
plotregression(targets, outputs);
f.Children(3).Children(1).Marker = '.';

if include5Years
    climits = {[0.05, 0.3], [0 1], [0 1]};
    titles = {'Porosity', 'Water Sat. 5 years', 'Water Sat. 10 years'};
else
    climits = {[0.05, 0.3], [0 1]}; %#ok<UNRCH>
    titles = {'Porosity', 'Water Sat.'};
end
plotResults(targets, outputs, cubeSize, titles, climits, 'IGMN Inversion');

%% KDE-DMS petrophysical 4D inversion
% mtrain = origTrainData(:, outputVars);
% if useFacies
%     dtrain = origTrainData(:, inputVars(2:end)); %#ok<UNRCH>
%     dataCond = origTestData(:, inputVars(2:end));
% else
%     dtrain = origTrainData(:, inputVars);
%     dataCond = origTestData(:, inputVars);
% end
% 
% tic;
% inverted_properties = RockPhysicsKDEInversion_DMS(mtrain, dtrain, dataCond, discretizationSize);
% toc;
% 
% plotResults(targets, inverted_properties, cubeSize, titles, climits, 'KDE-DMS Inversion');
% figure;
% plotregression(targets, outputs, 'IGMN Inversion', targets, inverted_properties, 'KDE-DMS Inversion');


