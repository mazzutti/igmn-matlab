% Cleanning up the workspace
dbstop if error
clear all; %#ok<CLALL> 
close all;
clc;

%% Add some external dependencies
addpath('../../../igmn/');
addpath(genpath('../../../Seislab 3.02'));
addpath(genpath('../../../SeReM/'))

%% Do some configurations

% Synthetic data configs
wellFilePath = 'data/pseudowell_2856667402688.las';
inputsStdMultiplyier = 1;
stdVp = 100 * inputsStdMultiplyier;
stdVs = 50 * inputsStdMultiplyier;
stdRho = 0.05 * inputsStdMultiplyier;

inputStds = {stdVp, stdVs, stdRho};

outputsStdMultiplyier = 0;

stdPhi = 0.01 * outputsStdMultiplyier;
stdClay = 0.01 * outputsStdMultiplyier;
stdSw = 0.01 * outputsStdMultiplyier;

outputStds = {stdPhi, stdClay, stdSw};

nSim = 100;
discretizationSize = 15;
showPlots = false;
useFacies = true;

%% Create synthetic well data
[modelData, wellData] = genPseudoWell(wellFilePath, nSim, inputStds{:}, outputStds{:}, useFacies, showPlots);
% modelData = modelData(randperm(size(modelData, 1)), :);
depth = wellData(:, 1);
facies = wellData(:, 2);
wellData = wellData(:, 2:end);

% compile options
useMex = true;

% Optimization Options

doOptimization = false;
lb =  [
    1.0e-8, ...       % min tau
    1.0e-8, ...       % min delta
    2, ...            % min spMin
    4, ...            % min vMin
    0 ...             % min regValue
];
ub = [
    1.0 - 1.0e-8, ... % max tau
    1.0 - 1.0e-8 ...  % max delta 
    4, ...            % max spMin
    20, ...           % max vMin
    1.0e-2, ...       % max regValue
];

algorithm = "particleswarm"; % "particleswarm" | "ga" | "patternsearch"


% Model Options
normalize = true;
if useFacies
    inputVars = [1, 2, 3, 4];
    outputVars = [5, 6, 7];
else
    inputVars = [1, 2, 3];
    outputVars = [4, 5, 6];
end

% IGMN default hyperparameters
igmnParams = [
    0.05, ... % tau 
    0.66, ... % delta
    2, ...    % spMin
    14, ...   % vMin
    2e-6      % regValue            
]; 

variableNames = {'Facies', 'Vp', 'Vs', 'Rho', 'Porosity', 'Clay Volume', 'Water Saturation'};
variableRanges = horzcat([min(wellData(:, inputVars)); max(wellData(:, inputVars))], [0 0.4; 0, 0.8; 0, 1]');

C = size(modelData, 2);
O = length(outputVars);
I = length(inputVars);

if useMex && (~exist('train_mex', 'file') || ~exist('predict_mex', 'file'))
    compile(I + O, outputVars); 
end

%% Prepare data cache
targets = wellData(:, outputVars);
if normalize
    [normalizedWellData, minMaxProportion] = normalizeData(vertcat(wellData, variableRanges));
    ranges = normalizedWellData(end-1:end, :);
    normalizedWellData = normalizedWellData(1:end-2, :);
    normalizedModelData = normalizeData(modelData, minMaxProportion);
else
    normalizedWellData = wellData(:, :);
    normalizedModelData = modelData(:, :);
    ranges = variableRanges;
end
dataCache = {normalizedModelData, normalizedWellData, ranges, targets};

%% Do IGMN optinmization (find good hyperparameters)

if doOptimization

    tic; 
    igmnParams(:) = optimize(algorithm, dataCache, lb, ub, inputVars, outputVars, useMex);
    toc;

    % Plot otimization results
    
    legends = cell(1, O);
    for i = 1:O
        variablenName = variableNames{outputVars(i)};
        legends{i} = {variablenName,  sprintf('%s Pred.', variablenName)};
    end
    if normalize
        plotOptimizationResults(dataCache, igmnParams, inputVars, outputVars, depth, legends, useMex, minMaxProportion);
    else
        plotOptimizationResults(dataCache, igmnParams, inputVars, outputVars, depth, legends, useMex);
    end
end

trainData = normalizedModelData;
testData = normalizedWellData(:, inputVars);

options = {}; 
options.tau = igmnParams(1); 
options.delta = igmnParams(2);
options.spMin = int32(igmnParams(3));
options.vMin = int32(igmnParams(4));
options.regValue = igmnParams(5);

range = dataCache{3};

net = igmn(range, options);

tic;
if useMex
    net = train_mex(net, trainData);
    [outputs, gridProbabilities] = predict_mex(net, testData, outputVars, discretizationSize);
else
    net = train(net, trainData); %#ok<*UNRCH>
    [outputs, gridProbabilities] = predict(net, testData, outputVars, discretizationSize);
end
toc;

if normalize
    outputs = denormalizeData(outputs, minMaxProportion, outputVars);
end

gridDomainProbabilities = computeDomainProbabilities(gridProbabilities, outputVars, discretizationSize);

% Do some plots

probabilities = cell(1, O);
for i = 1:O; probabilities{i} = squeeze(gridDomainProbabilities(i, :, :)); end

outputsDomain = cell(1, O);
for i = 1:O
    interval = variableRanges(:, outputVars(i));
    outputsDomain{i} = linspace(interval(1), interval(2), discretizationSize);
end

legends = cell(1, O);
for i = 1:O
    variablenName = variableNames{outputVars(i)};
    legends{i} = {
        '', ... % Confidence Interval?
        variablenName, ...
        sprintf('%s Pred.', variablenName) ...
    };
end

xlabels = cell(1, O);
for i = 1:O; xlabels{i} = sprintf('%s (v/v)', legends{i}{2}); end

plotResults(targets, outputs, xlabels, depth, facies, legends, ...
    outputVars, variableRanges, variableNames, outputsDomain, probabilities, 'IGMN Inversion');

%% Compare with RockPhysicsKDEInversion
[outputs, probabilities, outputsDomain] = kdeInversion(modelData, wellData);
plotResults(targets, outputs, xlabels, depth, facies, legends, ...
        outputVars, variableRanges, variableNames, outputsDomain, probabilities, 'KDE Inversion');

