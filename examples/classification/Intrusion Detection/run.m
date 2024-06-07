%% Cleanning up the workspace
%#ok<*UNRCH>
dbstop if error
clear all; %#ok<CLALL> 
close all;
clc;

rng('default');
rng(42);

%% Add some external dependencies
addpath('../../../igmn');

% vars = {
%     'Duration', 'Protocol', 'Service', 'Connection_Flag', 'SourceToDest', ...
%     'DestToSource', 'STTL', 'DTTL', 'SourceToDestPkts', ...
%     'DestToSourcePkts', 'CountSameHost', 'CountSameService', 'Serror_rate', ...
%     'Srv_serror_rate', 'Same_srv_rate', 'Diff_srv_rate', 'Srv_diff_host_rate', ... 
%     'Count', 'Srv_count', 'Same_srv_rate1', 'Diff_srv_rate1', 'Same_src_port_rate', ....
%     'Srv_diff_host_rate1', 'Serror_rate1', 'Srv_serror_rate1', 'Class'
% };

vars = {
    'Count', 'CountSameHost', 'DestToSource', 'SourceToDest', 'DestToSourcePkts', ...
    'CountSameService', 'SourceToDestPkts', 'Srv_diff_host_rate1', 'Srv_count',	...
    'Diff_srv_rate1', 'DTTL', 'Same_srv_rate', 'Service', 'Protocol', 'Duration', 'Class'
};

genSynthData = true;
normalize = true;
N = 4075951;
nSimTrain = round(N * 0.8);
nSimTest = N - nSimTrain; 

% nSimTrain = 2000;
% nSimTest = 1000;
maxNc = 20;

if genSynthData 
    [data, opts] = loadData('data/tagged_data.csv');
    [trainData, testData, allData] = ...
        genSyntheticData(data, opts, vars, nSimTrain, nSimTest);
    save('data/synthData.mat', 'trainData', 'testData', 'allData');
else
    load('data/synthData.mat');
end

if normalize
    [allData, minMaxProportion] = normalizeData(allData);
    trainData = normalizeData(trainData, minMaxProportion);
    testData = normalizeData(testData, minMaxProportion);
end

% testData = allData;

nvars = length(vars) + 1;
numberOfOutputVars = 2;
problem = Problem( ...
    trainData, ...
    testData, ...
    'InputVarIndexes', 1:nvars - numberOfOutputVars, ...
    'OutputVarIndexes', nvars - 1:nvars, ...
    'AllData', allData, ...
    'UseMex', true, ...
    'DoParametersTuning', true, ...
    'CompileOptions', compileoptions(...
        size(trainData, 1), size(testData, 1), size(allData, 1), ...
        'MaxNc', maxNc, ...
        'EnableRecompile', true, ...
        'IsOptimization', true, ...
        'IsClassification', true, ...
        'NumberOfVariables', nvars, ...
        'NumberOfOutputVars', numberOfOutputVars));

problem.OptimizeOptions.UseDefaultsFor = {'MaxNc'}; %, 'VMin', }; % 'Delta', 'Gamma', 'Phi', 'VMin', 'RegValue'};
% problem.OptimizeOptions.hyperparameters{6}.ub = 1000;
% problem.OptimizeOptions.hyperparameters{5}.lb = 2;
% problem.OptimizeOptions.hyperparameters{3}.lb = 0.3;
% problem.OptimizeOptions.hyperparameters{2}.lb = 0.3;
% problem.OptimizeOptions.hyperparameters{1}.ub = 0.99;
% problem.OptimizeOptions.hyperparameters{1}.lb = 0.2;
problem.OptimizeOptions.hyperparameters{5}.ub = 5;
problem.OptimizeOptions.hyperparameters{5}.lb = 2;
% problem.OptimizeOptions.hyperparameters{7}.ub = 1e-5;

problem.OptimizeOptions.Algorithm = 'pso';
problem.OptimizeOptions.PopulationSize = 100;
problem.OptimizeOptions.StallIterLimit = 100;
problem.OptimizeOptions.MaxFunEval = 10000;
problem.OptimizeOptions.UseParallel = true;
% problem.OptimizeOptions.PopulationArquiveRate = 8.6;
% problem.OptimizeOptions.ObjectiveLimit = 0;
% problem.OptimizeOptions.TolFunValue = 1e-18;
% problem.DefaultIgmnOptions.SPMin = 2;
problem.DefaultIgmnOptions.MaxNc = maxNc;
% problem.DefaultIgmnOptions.Tau = 0.2;
% problem.DefaultIgmnOptions.Delta = 0.2; 
% problem.DefaultIgmnOptions.RegValue = 4e-7;
% problem.DefaultIgmnOptions.Tau = 1e-14;
% problem.DefaultIgmnOptions.Gamma = 0.9997;
% problem.DefaultIgmnOptions.VMin = 0;

if problem.UseMex
    compile(problem.CompileOptions);
    if problem.DoParametersTuning
        optimize = @optimize_mex;
    end
end

legends = {{'normal', 'normal pred.'}, {'ataque', 'ataque pred.'}};

if problem.DoParametersTuning
    igmnOptions = optimize(problem);
    runAndPlotResults(problem, igmnOptions, legends, true);
else
    runAndPlotResults(problem, problem.DefaultIgmnOptions, legends, true);
end
