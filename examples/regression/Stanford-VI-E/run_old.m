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
nDiscr = 25;
include5Years = true;
useFacies = false;
doOptimization = true;
lb =  [
    1.0e-15, ...   % min tau
    1.0e-15, ...   % min delta
    3, ...         % min spMin
    4, ...         % min vMin
    0 ...          % min regValue
];
ub = [
    1 - lb(1), ... % max tau
    1 - lb(2), ... % max delta 
    4, ...         % max spMin
    80, ...        % max vMin
    1.0e-2, ...    % max regValue
];

algorithm = "particleswarm"; % "particleswarm" | "ga" | "patternsearch"

% Model Options
normalize = true;
if include5Years
    inputVars = [1, 2, 3, 4];
    outputVars = [5, 6, 7];
else
    inputVars = [1, 2];
    outputVars = [3, 4];
end

if useFacies
    inputVars = inputVars + 1;
    inputVars = [1, inputVars];
    outputVars = outputVars + 1;
end

% IGMN default hyperparameters
igmnParams = [
    0.14, ... % tau 
    0.66, ... % delta
    3, ...    % spMin
    40, ...   % vMin
    1.2e-08   % regValue            
];

O = length(outputVars);
I = length(inputVars);

if useMex && (~exist('train_mex', 'file') || ~exist('predict_mex', 'file'))
    compile(I + O, outputVars); 
end

[trainData, testData, cubeSize] = prepareData(nSubSamp, useFacies, slice, include5Years);

dcond = testData(:, :); 

if include5Years
    climits = {[0.05, 0.3], [0 1], [0 1]};
    titles = {'Porosity', 'Sw 5 years', 'Sw 10 years'};
else
    climits = {[0.05, 0.3], [0 1]};
    titles = {'Porosity', 'Sw'};
end

variableRanges = horzcat([min(testData(:, inputVars)); max(testData(:, inputVars))], vertcat(climits{:})');

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
    try
        tic; 
         igmnParams(:) = optimize(algorithm, dataCache, lb, ub, inputVars, outputVars, useMex);
        toc;
    catch ME
       if (strcmp(ME.identifier,'EMLRT:runTime:MATLABExprIsNotCorrectSize'))
           compile(I + O, outputVars);
           tic; 
           igmnParams(:) = optimize(algorithm, dataCache, lb, ub, inputVars, outputVars, useMex);
           toc;
       else
           rethrow(ME)
       end
    end
end

%% IGMN petrophysical 4D inversion

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
    try
        tic;
        net = train_mex(net, igmnTrainData);
        outputs = predict_mex(net, igmnTestData, outputVars, 0);
        toc;
    catch ME
       if (strcmp(ME.identifier,'EMLRT:runTime:MATLABExprIsNotCorrectSize'))
          compile(I + O, outputVars);
           tic;
           net = train_mex(net, igmnTrainData);
           outputs = predict_mex(net, igmnTestData, outputVars, 0);
           toc;
       else
           rethrow(ME)
       end
    end
else
    net = train(net, igmnTrainData); %#ok<*UNRCH>
    outputs = predict(net, igmnTestData, outputVars, 0);
end

if normalize
    outputs = denormalizeData(outputs, minMaxProportion, outputVars);
end

plotResults(targets, outputs, cubeSize, titles, climits, 'IGMN Inversion');

%% KDE-DMS petrophysical 4D inversion

mtrain = trainData(:, outputVars);
if useFacies
    dtrain = trainData(:, inputVars(2:end));
    dataCond = dcond(:, inputVars(2:end));
else
    dtrain = trainData(:, inputVars);
    dataCond = dcond(:, inputVars);
end

tic;
inverted_properties = RockPhysicsKDEInversion_DMS(mtrain, dtrain, dataCond, nDiscr);
toc;
    
plotResults(targets, inverted_properties, cubeSize, titles, climits, 'KDE-DMS Inversion');
figure;
plotregression(targets, outputs, 'IGMN Inversion', targets, inverted_properties, 'KDE-DMS Inversion');


