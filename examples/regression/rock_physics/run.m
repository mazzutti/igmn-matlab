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

colormap('jet');

%% Do some configurations
nSim = 100;
discretizationSize = 20;
showPlots = false;
useFacies = true;

%% Create synthetic well data
[modelData, wellData] = genPseudoWell(nSim, useFacies, showPlots, false);
depth = wellData(:, 1);
facies = wellData(:, 2);

trainData = modelData;
% trainData = trainData(randperm(size(trainData, 1)), :);
testData = wellData(:, 2:end);

%% Problem Configs

normalize = false;
nvars = 6; %#ok<NASGU>
numberOfOutputVars = 3;
if useFacies; nvars = 7; end
inputVars = 1:nvars - numberOfOutputVars;
outputVars = nvars - numberOfOutputVars + 1:nvars;

targets = testData(:, outputVars);

variableNames = {3};
if useFacies; variableNames = ['Facies', variableNames]; end

trainData(:, 2:3) = trainData(:, 2:3) ./ 1000;
testData(:, 2:3) = testData(:, 2:3) ./ 1000;


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
    'DoParametersTuning', true, ...
    'CompileOptions', compileoptions(...
        'EnableRecompile', true, ...
        'NumberOfVariables', nvars, ...
        'NumberOfOutputVars', numberOfOutputVars, ...
        'IsOptimization', true));

problem.OptimizeOptions.Algorithm = 'pso';
problem.OptimizeOptions.UseDefaultsFor = {'UseRankOne'};
problem.OptimizeOptions.MaxFunEval = 30000;
problem.OptimizeOptions.PopulationSize = 300;
problem.OptimizeOptions.StallIterLimit = 40;
problem.OptimizeOptions.UseParallel = true;
problem.OptimizeOptions.TolFunValue = 1e-18;

problem.DefaultIgmnOptions.UseRankOne = 1;

% problem.OptimizeOptions.hyperparameters{7}.lb = 3;
% problem.OptimizeOptions.hyperparameters{1}.ub = 0.2;
% problem.OptimizeOptions.hyperparameters{1}.lb = 1.0e-18;
% problem.OptimizeOptions.hyperparameters{2}.ub = 0.3;
% problem.OptimizeOptions.hyperparameters{2}.lb = 1.0e-8;
% problem.OptimizeOptions.hyperparameters{3}.lb = 1;
% problem.OptimizeOptions.hyperparameters{4}.lb = 1;
% problem.OptimizeOptions.hyperparameters{6}.ub = 10;
% problem.OptimizeOptions.hyperparameters{6}.lb = 5;
% problem.OptimizeOptions.hyperparameters{5}.ub = 4;
% problem.OptimizeOptions.hyperparameters{5}.lb = 2;
% problem.OptimizeOptions.hyperparameters{8}.ub = 1.0e-2;

% problem.DefaultIgmnOptions.MaxNc = 30;
% problem.DefaultIgmnOptions.SPMin = 3;
% problem.DefaultIgmnOptions.RegValue = 0;
% problem.DefaultIgmnOptions.VMin = 6;
% problem.DefaultIgmnOptions.RegValue = 2e-6;
% problem.DefaultIgmnOptions.Tau = 0.05;
% problem.DefaultIgmnOptions.Delta = 0.66;
% problem.DefaultIgmnOptions.Gamma = 1;
% problem.DefaultIgmnOptions.Phi = 1;

if strcmpi(problem.ExecutionMode, 'mex') || strcmpi(problem.ExecutionMode, 'native') 
    compile(problem);
    if strcmpi(problem.ExecutionMode, 'mex')
        optimize = @optimize_mex;
        igmn = @igmnBuilder_mex;
        train = @train_mex;
        predict = @predict_mex;
    end
end

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
igmnOptions = problem.DefaultIgmnOptions;
if problem.DoParametersTuning
    tic;
    igmnOptions = optimize(problem);
    toc;
    igmnOptions.MaxNc = size(trainData, 1) + 1;
    % Plot otimization results
    legendsTrain = cell(1, numberOfOutputVars);
    for i = 1:numberOfOutputVars
        variablenName = variableNames{outputVars(i)};
        legendsTrain{i} = {variablenName,  sprintf('%s Pred.', variablenName)};
    end
    plotOptimizationResults(trainData, inputVars, outputVars, igmnOptions, ...
        problem.UseMex, legendsTrain, xlabels, minMaxProportion, 'toy_train_results');
end

% Testing & do some plots
net = igmn(igmnOptions);
tic;
net = train(net, trainData); %#ok<*UNRCH>
toc;
tic;
[outputs, gridProbabilities] = predict(net, inputs, outputVars, discretizationSize);
toc;

if normalize; outputs = denormalizeData(outputs, minMaxProportion, outputVars); end
gridDomainProbabilities = computeDomainProbabilities(gridProbabilities, outputVars, discretizationSize);
probabilities = cell(1, numberOfOutputVars);
for i = 1:numberOfOutputVars; probabilities{i} = squeeze(gridDomainProbabilities(i, :, :)); end

% variableRanges = horzcat([min(wellData(:, inputVars)); max(wellData(:, inputVars))], [0 0.4; 0, 0.8; 0, 1]');
variableRanges = horzcat([min([modelData; wellData(:, 2:end)]); max([modelData; wellData(:, 2:end)])]);
outputsDomain = cell(1, numberOfOutputVars);
for i = 1:numberOfOutputVars
    interval = variableRanges(:, outputVars(i));
    outputsDomain{i} = linspace(interval(1), interval(2), discretizationSize);
end

plotResults(targets, outputs, xlabels, depth, facies, legends, ...
    outputVars, variableRanges, variableNames, outputsDomain, probabilities, 'IGMN Inversion', 'toy_predict_results');

%% Compare with RockPhysicsKDEInversion
% [outputs, probabilities, outputsDomain] = kdeInversion(modelData, wellData(:, 2:end));
% plotResults(targets, outputs, xlabels, depth, facies, legends, ...
%         outputVars, variableRanges, variableNames, outputsDomain, probabilities, 'KDE Inversion');

