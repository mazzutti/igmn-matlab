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
nSim = 10000;
showPlots = true;
doOptimization = true;
lb =  [
    1.0e-15, ...       % min tau
    1.0e-15, ...       % min delta
    3, ...            % min spMin
    4, ...            % min vMin
    0 ...             % min regValue
];
ub = [
    1 - lb(1), ...    % max tau
    1 - lb(2), ...    % max delta 
    4, ...            % max spMin
    40, ...           % max vMin
    1.0e-2, ...       % max regValue
];

algorithm = "particleswarm"; % "particleswarm" | "ga" | "patternsearch"

% Model Options
normalize = true;
inputVars = [1, 2, 3, 4];
outputVars = [5, 6, 7];

% IGMN default hyperparameters
igmnParams = [
    1e-08, ...  % tau 
    0.1481, ... % delta
    3, ...      % spMin
    13, ...     % vMin
    0           % regValue            
];

% compile options
useMex = true;
O = length(outputVars);
I = length(inputVars);

if useMex && (~exist('train_mex', 'file') || ~exist('predict_mex', 'file'))
    compile(I + O, outputVars); 
end

[trainData, testData, cubeSize] = prepareData(nSim, showPlots);

dcond = testData(:, :); 
outOfInterestIndexes = all(isnan(testData), 2);
testData(outOfInterestIndexes, :) = [];

variableRanges = horzcat([min(testData(:, inputVars)); max(testData(:, inputVars))], [0 0.35; 0, 1; 0, 1]');

%% Prepare data cache
targets = testData(:, outputVars);
if normalize
    [normalizedTestData, minMaxProportion] = normalizeData(vertcat(testData, variableRanges));
    ranges = normalizedTestData(end-1:end, :);
    normalizedTestData = normalizedTestData(1:end-2, :);
    normalizedTrainData = normalizeData(trainData, minMaxProportion);
else
    normalizedWellData = testData(:, :); %#ok<*UNRCH>
    normalizedModelData = modelData(:, :);
    ranges = variableRanges;
end
dataCache = {normalizedTrainData, normalizedTestData, ranges, targets};

if doOptimization
    tic; 
    igmnParams(:) = optimize(algorithm, dataCache, lb, ub, inputVars, outputVars, useMex);
    toc;
end

%% IGMN INVERSION

options = {}; 
options.tau = igmnParams(1); 
options.delta = igmnParams(2);
options.spMin = int32(igmnParams(3));
options.vMin = int32(igmnParams(4));
options.regValue = igmnParams(5);

range = dataCache{3};

net = igmn(range, options);

igmnTrainData = normalizedTrainData;
igmnTestData = normalizedTestData(:, inputVars);


if useMex
    tic;
    net = train_mex(net, igmnTrainData);
    toc;
    tic;
    outputs = predict_mex(net, igmnTestData, outputVars, 0);
    toc;
else
    net = train(net, igmnTrainData); %#ok<*UNRCH>
    outputs = predict(net, igmnTestData, outputVars, 0);
end


if normalize
    outputs = denormalizeData(outputs, minMaxProportion, outputVars);
end

targets = testData(:, outputVars);
plotregression(targets, outputs);

results = nan(size(outOfInterestIndexes, 1), O);
results(~outOfInterestIndexes, :) = outputs; 
plotResults(dcond, results, cubeSize);

%% RockPhysicsKDEInversion_DMS INVERSION 

mtrain = trainData(:, 5:end);
dtrain = trainData(:, 1:4);

tic;
inverted_properties = RockPhysicsKDEInversion_DMS(mtrain, dtrain, dcond(:, 1:4), 25);
toc;

plotregression(targets, inverted_properties(~outOfInterestIndexes, :))
plotResults(dcond, inverted_properties, cubeSize);



