clear all; %#ok<CLALL> 
close all;
clc;
rng('default');
rng(42);

addpath('../../../igmn/');
addpath(genpath('../../../GeoStatRockPhysics/SeReM/'))

%% Do some configurations
nSim = 10*[400 800 300];
discretizationSize = 20;
showPlots = false;
useFacies = false;
exportPlots = false;
normalize = false;

%% Create synthetic well data
[modelData, wellData] = genPseudoWell(nSim, showPlots, exportPlots);

variableNames = {'Vp', 'Vs', 'Rho', 'lowVp', 'lowVs', 'lowRho', 'Phi', 'Clay', 'Sw'};


if useFacies
    variableNames = ['Facies', variableNames];
    testData = wellData(:, 2:end);
    trainData = modelData;
else
    testData = wellData(:, 3:end);
    trainData = modelData(:, 2:end);
end
numberOfOutputVars = 3;
nvars = numel(variableNames);
inputVars = 1:(nvars - numberOfOutputVars);
outputVars = (numel(inputVars) + 1):nvars;

depth = wellData(:, 1);
facies = wellData(:, 2);

targets = testData(:, outputVars);

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
        'IsOptimization', true) ...
    );

problem.OptimizeOptions.Algorithm = 'psogsa';
% problem.OptimizeOptions.UseDefaultsFor = {'Gamma', 'Phi' };
problem.OptimizeOptions.MaxFunEval = 30000;
problem.OptimizeOptions.PopulationSize = 300;
problem.OptimizeOptions.StallIterLimit = 40;
problem.OptimizeOptions.UseParallel = true;
problem.OptimizeOptions.TolFunValue = 1e-18;

% problem.OptimizeOptions.hyperparameters{7}.lb = 3;
problem.OptimizeOptions.hyperparameters{1}.ub = 0.1;
problem.OptimizeOptions.hyperparameters{1}.lb = 1.0e-15;
problem.OptimizeOptions.hyperparameters{2}.ub = 0.9;
% problem.OptimizeOptions.hyperparameters{2}.lb = 1.0e-8;
% problem.OptimizeOptions.hyperparameters{3}.lb = 1;
% problem.OptimizeOptions.hyperparameters{4}.lb = 1;
problem.OptimizeOptions.hyperparameters{6}.ub = 30;
problem.OptimizeOptions.hyperparameters{5}.ub = 5;
problem.OptimizeOptions.hyperparameters{5}.lb = 2;
% problem.OptimizeOptions.hyperparameters{8}.ub = 1.0e-2;

% problem.DefaultIgmnOptions.MaxNc = 30;
% problem.DefaultIgmnOptions.SPMin = 2;
% problem.DefaultIgmnOptions.RegValue = 0;
% problem.DefaultIgmnOptions.VMin = 14;
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
            problem.ExecutionMode == 'mex', legendsTrain, xlabels, minMaxProportion, 'figs/train_results');
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
        outputVars, variableRanges, variableNames, outputsDomain, probabilities, 'IGMN Inversion', 'figs/predict_results');
    
    %% Compare with RockPhysicsKDEInversion
    % [outputs, probabilities, outputsDomain] = kdeInversion(modelData, wellData(:, 2:end));
    % plotResults(targets, outputs, xlabels, depth, facies, legends, ...
    %         outputVars, variableRanges, variableNames, outputsDomain, probabilities, 'KDE Inversion');
end

