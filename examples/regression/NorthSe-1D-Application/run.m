clear all; %#ok<CLALL> 
close all;
clc;
rng('default');
rng(42);


addpath('../../../igmn/');
addpath(genpath('../../../GeoStatRockPhysics/SeReM/'))

%% Do some configurations
nSim = 2 * [400 800 300];
discretizationSize = 25;
useFacies = true;
showPlots = true;
exportPlots = true;

%% Create synthetic well data

[modelData, wellData] = genPseudoWell(nSim, showPlots, useFacies, exportPlots);

variableNames = {'Vp', 'Vs', 'Rho', 'Phi', 'Clay', 'Sw'};
if useFacies
    variableNames = ['Facies' variableNames];
    testData = wellData(:, 2:end);
else
    testData = wellData(:, 3:end);
end
trainData = modelData;

trainData = trainData(randperm(size(trainData, 1)), :);

numberOfOutputVars = 3;
nvars = numel(variableNames);
inputVars = 1:(nvars - numberOfOutputVars);
outputVars = (numel(inputVars) + 1):nvars;

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
        'EnableRecompile', true, ...
        'EnableProfile', false, ...
        'NumberOfVariables', nvars, ...
        'NumberOfOutputVars', numberOfOutputVars, ...
        'IsOptimization', true) ...
    );

problem.OptimizeOptions.Algorithm = 'imode';
problem.OptimizeOptions.UseDefaultsFor = {'UseRankOne', 'MaxNc', 'SPMin', 'VMin', 'Tau', 'Delta'};
problem.OptimizeOptions.MaxFunEval = 300000;
problem.OptimizeOptions.MaxIter = 300000;
problem.OptimizeOptions.PopulationSize = 300;
problem.OptimizeOptions.StallIterLimit = 400;
problem.OptimizeOptions.UseParallel = true;
problem.OptimizeOptions.TolFunValue = 1e-18;

% problem.OptimizeOptions.hyperparameters{1}.ub = 0.99;
% problem.OptimizeOptions.hyperparameters{1}.lb = 1.0e-15;
% problem.OptimizeOptions.hyperparameters{2}.ub = 0.99;
% problem.OptimizeOptions.hyperparameters{2}.lb = 1.0e-15;
% problem.OptimizeOptions.hyperparameters{6}.ub = 50;
% problem.OptimizeOptions.hyperparameters{6}.lb = 8;
% problem.OptimizeOptions.hyperparameters{5}.ub = 12;
% problem.OptimizeOptions.hyperparameters{5}.lb = 5;
problem.OptimizeOptions.hyperparameters{7}.ub = 1.0e-3;

problem.DefaultIgmnOptions.UseRankOne = 1;
problem.DefaultIgmnOptions.MaxNc = 30;
problem.DefaultIgmnOptions.SPMin = 5;
% problem.DefaultIgmnOptions.RegValue = 0;

problem.DefaultIgmnOptions.VMin = 12;
problem.DefaultIgmnOptions.Tau = 0.099468344904515;
problem.DefaultIgmnOptions.Delta = 0.336502809203064;
% problem.DefaultIgmnOptions.Gamma = 0.5;
% problem.DefaultIgmnOptions.Phi = 0.01;

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
    % igmnOptions = problem.DefaultIgmnOptions;
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
            problem.ExecutionMode == 'mex', legendsTrain,  xlabels, 'figs/train_results');
    else
        igmnOptions = load('igmnOptions.mat').igmnOptions;
    end

    % Testing & do some plots

  
    net = igmn(igmnOptions);
    net = train(net, trainData); %#ok<*UNRCH>
       
    depth = wellData(:, 1);
    facies = wellData(:, 2);
    if useFacies
        testData = wellData(:, 2:end);
    else
        testData = wellData(:, 3:end);
    end
    targets = testData(:, outputVars);
    inputs = testData(:, inputVars);
    variableRanges = [0, 0, 0; 0.4, 0.8, 1];
    
    [outputs, gridProbabilities] = predict(net, inputs, outputVars, discretizationSize, variableRanges);

    gridDomainProbabilities = computeDomainProbabilities(gridProbabilities, outputVars, discretizationSize);
    probabilities = cell(1, numberOfOutputVars);
    for i = 1:numberOfOutputVars; probabilities{i} = squeeze(gridDomainProbabilities(i, :, :)); end
    
    outputsDomain = cell(1, numberOfOutputVars);
    for i = 1:numberOfOutputVars
        interval = variableRanges(:, i);
        outputsDomain{i} = linspace(interval(1), interval(2), discretizationSize);
    end
    variableNames = {'Facies', '\boldmath{$\alpha$} \boldmath{$(km/s)$}', ...
        '\boldmath{$\alpha$} \boldmath{$(km/s)$}', '\boldmath{$\rho$} \boldmath{$(g/cm^3$)}', ...
        '\boldmath{$\phi$} \boldmath{$(v/v)$}', '\boldmath{$V_c$} \boldmath{$(v/v)$}', ...
        '\boldmath{$S_w$} \boldmath{$(v/v)$}'};
    plotResults(net, targets, inputs, outputs, useFacies, depth, facies, legends, ...
        variableRanges, variableNames, outputsDomain, probabilities, 'IGMN Inversion', 'figs/predict_results_1D');

    phi_rmse = sqrt(mean((targets(:, 1) - outputs(:, 1)) .^ 2));
    clay_rmse = sqrt(mean((targets(:, 2) - outputs(:, 2)) .^ 2));
    Sw_rmse = sqrt(mean((targets(:, 3) - outputs(:, 3)) .^ 2));
    
    rmse = phi_rmse + clay_rmse + Sw_rmse;

    disp('************************* IGMN Inversion *************************');
    fprintf('RMSE: %2.4f\n', rmse);
    
    %% Compare with RockPhysicsKDEInversion
    % [outputs, probabilities, outputsDomain] = kdeInversion(modelData, wellData(:, 2:end));
    % plotResults(targets, outputs, xlabels, depth, facies, legends, ...
    %         outputVars, variableRanges, variableNames, outputsDomain, probabilities, 'KDE Inversion');
end

