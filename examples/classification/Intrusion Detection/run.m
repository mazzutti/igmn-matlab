%% Cleanning up the workspace
%#ok<*UNRCH>
dbstop if error
clear all; %#ok<CLALL> 
close all;
clc;

%% Add some external dependencies
addpath('../../../igmn');

%% Options

genSynthData = false;
nSimTrain = 20000;
nSimTest = 10000;

% ignoredVars = {
%     'Protocol', 'Service', 'Connection_Flag', 'Urgent', ...
%     'Land', 'Wrong', 'SourceToDestPkts', 'DestToSourcePkts', ...
%     'CountSameService', 'Serror_rate', 'Diff_srv_rate', ...
%     'Diff_srv_rate', 'Same_src_port_rate', 'Srv_diff_host_rate', ...
%     'Srv_serror_rate' ...
% };

% ignoredVars = {
%     'Connection_Flag', 'Urgent',  'Land', 'Wrong', 'SourceToDestPkts', ...
%     'DestToSourcePkts',  'CountSameService', 'Serror_rate', ...
%     'Diff_srv_rate',  'Diff_srv_rate', 'Same_src_port_rate', ...
%     'Srv_diff_host_rate', 'Srv_serror_rate' ...
% };

ignoredVars = {
    'Land', 'Wrong'
};

lb = [
    1.0e-9, ...       % min tau
    1.0e-9, ...       % min delta
    3, ...            % min spMin
    4, ...            % min vMin
    0 ...             % min regValue
];
ub = [
    1.0 - lb(1), ...  % max tau
    1.0 - lb(2) ...   % max delta 
    4, ...            % max spMin
    10, ...           % max vMin
    1.0e-4, ...       % max regValue
];

algorithm = "particleswarm"; % "particleswarm" | "ga" | "patternsearch"

% Compile Options
useMex = true;
options = {};
options.isClassifyProblem = true;

% Model Options
normalize = true;
doOptimization = true;

% IGMN default hyperparameters
igmnParams = [
    0.05, ... % tau 
    0.66, ... % delta
    2, ...    % spMin
    14, ...   % vMin
    2e-6      % regValue            
]; 

if genSynthData 
    [data, opts] = loadData('data/tagged_data.csv');
    [trainData, testData, fullData] = ...
        genSyntheticData(data, opts, ignoredVars, nSimTrain, nSimTest);
    save('data/synthData.mat', 'trainData', 'testData', 'fullData');
else
    load('data/synthData.mat');
end

I = size(fullData, 2) - 2;
O = 2;

inputVars = 1:I;
outputVars = I+1:I+O;

if useMex && (~exist('train_mex', 'file') || ~exist('classify_mex', 'file'))
    compile(I + O, outputVars, options); 
end

if normalize
    [normalizedFullData, minMaxProportion] = normalizeData(fullData);
    range = [min(normalizedFullData); max(normalizedFullData)];
    trainData = normalizeData(trainData, minMaxProportion);
    testData = normalizeData(testData, minMaxProportion);
    dataCache = {trainData, testData, range, normalizedFullData};
else
    range = [min(fullData); max(fullData)];
    dataCache = {trainData, testData, range, fullData};
end


if doOptimization
        
    tic; 
    igmnParams(:) = optimize(...
        algorithm, dataCache, lb, ub, inputVars, outputVars, useMex);
    toc;

    % Plot otimization results
    
    legends = {{'normal', 'normal pred.'}, {'ataque', 'ataque pred.'}};
    plotOptimizationResults(...
        dataCache, igmnParams, inputVars, outputVars, legends, useMex);
end

trainData = dataCache{1};
testData = dataCache{4};
targets = testData(:, outputVars);
testData = testData(:, inputVars);
trainSize = int32(size(trainData, 1));

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
    outputs = classify_mex(net, testData, outputVars);
else
    net = train(net, trainData);
    outputs = classify(net, testData, outputVars);
end
toc;

%% Do some plots

classes = {legends{1}{1} legends{2}{1}};
targets = onehotdecode(double(targets), classes, 2);
outputs = onehotdecode(double(outputs), classes, 2);
legendNames = horzcat(legends{:});
figure('Name', sprintf('Confusion Matrix: s x %s | %s x %s', legendNames{:}));
plotconfusion(targets, outputs);
