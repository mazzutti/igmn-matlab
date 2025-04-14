% run.m - Script for performing regression analysis using IGMN and Kriging
% 
% This script performs regression analysis on UNISIM Time-Lapse data using 
% Incremental Gaussian Mixture Networks (IGMN) and Kriging for spatial 
% conditioning. It includes data preprocessing, model training, prediction, 
% and evaluation of results.
% 
% Dependencies:
% - IGMN library (addpath('../../../igmn/'))
% - GeoStatRockPhysics library (addpath(genpath('../../../GeoStatRockPhysics/'))
% 
% Global Variables:
% - iterationCount: Tracks the number of iterations.
% - inKrigingMode: Indicates whether Kriging is being used.
% - numCores: Number of CPU cores to use for parallel processing.
% - useKriging: Flag to enable or disable Kriging.
% - krigingStartIteration: Iteration number to start Kriging.
% 
% Key Parameters:
% - nSim: Number of simulations to load.
% - discretizationSize: Size of discretization for predictions.
% - showPlots: Flag to enable or disable plot visualization.
% - exportPlots: Flag to enable or disable exporting plots.
% - variableNames: Names of the variables used in the analysis.
% - nanIndexes: Indexes of variables to check for NaN values.
% 
% Main Steps:
% 1. Load and preprocess UNISIM data:
%     - Load model and well data.
%     - Normalize data if Kriging is enabled.
%     - Extract input and output variable indexes.
% 
% 2. Kriging setup (if enabled):
%     - Prepare conditioning data from well information.
%     - Normalize conditioning data.
%     - Perform Kriging to compute means and variances for predictions.
% 
% 3. Problem setup:
%     - Define the regression problem using the Problem class.
%     - Configure optimization options and hyperparameters.
% 
% 4. Optimization and training:
%     - Perform hyperparameter tuning if enabled.
%     - Train the IGMN model using the training data.
% 
% 5. Prediction and evaluation:
%     - Predict outputs for test data.
%     - Compute unconditioned and conditioned outputs.
%     - Evaluate results using RMSE metrics.
%     - Generate plots for visualization of results.
% 
% 6. Comparison with DMS inversion:
%     - Load DMS inversion results and compare RMSE values.
% 
% Outputs:
% - RMSE values for unconditioned and conditioned predictions.
% - Plots comparing real vs predicted values and regression analysis.
% 
% Note:
% - Ensure all dependencies are correctly added to the MATLAB path.
% - Modify parameters and flags as needed for specific use cases.
clear all; %#ok<CLALL>
clear mex; %#ok<CLMEX>
close all;
clc;
rng('default');
rng(42);

addpath('../../../igmn/');
addpath('../../');
addpath(genpath('../../../GeoStatRockPhysics/'))

global iterationCount %#ok<*GVMIS>
global inKrigingMode
global numCores
global useKriging
global krigingStartIteration

inKrigingMode = false;
iterationCount = 0;
numCores = 8; % maxNumCompThreads;
useKriging = true;
krigingStartIteration = 2000;

nSim = 18000;
discretizationSize = 20;
showPlots = true;
exportPlots = true;

variableNames = {'Ip13', 'Ip24', 'VPVS13', 'VPVS24', 'Phi', 'Sw13', 'Sw24'};
nanIndexes = 1:size(variableNames, 2);

%% read UNISIM data and apply optional crops for testing

[modelData, wellData, WELLS, I, J, refFig] = loadData(nSim, showPlots, exportPlots);

targetsIndexes = ~all(isnan(wellData(:, nanIndexes)), 2);

testData = wellData(targetsIndexes, :);
trainData = modelData;

% trainData = trainData(randperm(size(trainData, 1)), :);
numberOfOutputVars = 3;
nvars = numel(variableNames);
inputVars = 1:(nvars - numberOfOutputVars);
outputVars = (numel(inputVars) + 1):nvars;

if useKriging
    cond_pos = zeros(length(WELLS), 2);
    conditioningData = zeros(length(WELLS), nvars);
    for well = 1:length(WELLS)
        cond_pos(well, :) = [WELLS(well).i, WELLS(well).j];
        conditioningData(well, :) = [WELLS(well).Ip13 WELLS(well).VPVS13 ...
            WELLS(well).Ip24 WELLS(well).VPVS24 WELLS(well).Phi WELLS(well).Sw13 WELLS(well).Sw24];
    end

    data = [trainData; testData; conditioningData];

    % min2norm = min(data);
    % max2norm = max(data - min2norm);

    % trainData = trainData - min2norm;
    % trainData = double(trainData ./ max2norm);
    % testData = testData - min2norm;
    % testData = double(testData ./ max2norm);
    % conditioningData = conditioningData - min2norm;
    % conditioningData = double(conditioningData ./ max2norm);

    [~, minMaxProportion] = normalizeData(data);
    trainData = normalizeData(trainData, minMaxProportion);
    testData = normalizeData(testData, minMaxProportion);
    conditioningData = normalizeData(conditioningData, minMaxProportion);

    cell_size = 0.1;
    range = double(intmax);
    type = 'sph';
    angles = [0 0 0];
    numPoints = size(testData, 1);
  
    [X, Y] = meshgrid(1:J, 1:I);
    xcoords = [Y(:) X(:)];

    conditioningDataUniform = nonParametricToUniform(conditioningData, trainData, cell_size);
    conditioningDataGaussian_2krig = norminv(conditioningDataUniform);
    conditioningDataGaussian_2krig(isnan(conditioningDataGaussian_2krig)) = 0;

    numInputVars = numel(inputVars);
    numOutputVars = length(outputVars);
    krigmeans = zeros(numPoints, numOutputVars);
    krigvars = zeros(numPoints, numOutputVars);
    for i = 1:numOutputVars
        [krigmean, krigvar] = Kriging_options(xcoords, cond_pos, ...
            conditioningDataGaussian_2krig(:, i + numInputVars), 1, range, type, 1, angles);
        krigvar(krigvar < 0) = 0;
        krigmeans(:, i) = krigmean(targetsIndexes);
        krigvars(:, i) = sqrt(krigvar(targetsIndexes));
    end

    inputs = double(testData(:, inputVars));
    numInputs = length(inputVars);
    inputRows = permute(reshape(inputs, 1, [], numInputs), [1 3 2]);
    indexes = squeeze(all(abs(trainData(:, 1:numInputs) - inputRows) < cell_size, 2));
    dataFiltered = arrayfun(@(i) trainData(indexes(:, i), :), 1:size(testData, 1), 'UniformOutput', false);
    infinitesimal = cumsum(zeros(length(trainData), 1) + 1e-10);
    nonParametricData = zeros(size(testData, 1), size(trainData, 2));
    nonParametricData(:, inputVars) = testData(:, inputVars);
    sortedTrainData = sort(trainData);
end

problem = Problem( ...
    trainData, ...
    testData, ...
    'InputVarIndexes', inputVars, ...
    'OutputVarIndexes', outputVars, ...
    'AllData', [trainData; testData], ...
    'ExecutionMode', 'mex', ...
    'DoParametersTuning', false, ...
    'CompileOptions', compileoptions(...
        'EnableRecompile', false, ...
        'NumberOfVariables', nvars, ...
        'NumberOfOutputVars', numberOfOutputVars, ...   
        'IsOptimization', true) ...
    );
problem.OptimizeOptions.Algorithm = 'imode';
problem.OptimizeOptions.UseDefaultsFor = {'UseRankOne', 'MaxNc'};
problem.OptimizeOptions.MaxFunEval = 3000000;
problem.OptimizeOptions.PopulationSize = 30;
problem.OptimizeOptions.StallIterLimit = 8000;
problem.OptimizeOptions.UseParallel = true;
problem.OptimizeOptions.TolFunValue = 1e-18;

if useKriging
    problem.OptimizeOptions.ExtraEvalArgs = {
        nonParametricData, krigmeans, krigvars, infinitesimal, sortedTrainData
    }; 
    problem.OptimizeOptions.ExtraEvalCellArgs = { dataFiltered };
end

problem.OptimizeOptions.hyperparameters{1}.ub = 0.99;
problem.OptimizeOptions.hyperparameters{1}.lb = 1.0e-15;
problem.OptimizeOptions.hyperparameters{2}.ub = 0.99;
problem.OptimizeOptions.hyperparameters{2}.lb = 1.0e-15;
problem.OptimizeOptions.hyperparameters{6}.ub = 50;
problem.OptimizeOptions.hyperparameters{6}.lb = 4;
problem.OptimizeOptions.hyperparameters{5}.ub = 3;
problem.OptimizeOptions.hyperparameters{5}.lb = 2; 
problem.OptimizeOptions.hyperparameters{7}.ub = 1.0e-3;

problem.DefaultIgmnOptions.UseRankOne = 1;
problem.DefaultIgmnOptions.MaxNc = 60;
% problem.DefaultIgmnOptions.SPMin = 2;
% problem.DefaultIgmnOptions.RegValue = 0;
% problem.DefaultIgmnOptions.VMin = 8;
% problem.DefaultIgmnOptions.RegValue = 2e-3;
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
    % igmnOptions = problem.DefaultIgmnOptions;
    if problem.DoParametersTuning
        tic;
        igmnOptions = optimize(problem);
        save('igmnOptions', 'igmnOptions');
        toc;
    else
        igmnOptions = load('igmnOptions.mat').igmnOptions;
    end

    % Testing & do some plots
    
    net = igmn(igmnOptions);
    tic;
    net = train(net, trainData); %#ok<*UNRCH>
    toc;

    variableRanges = [0, 0, 0; 0.4, 0.8, 0.8];
    inputs = double(testData(:, inputVars));
    [outputs, gridProbabilities]  = predict(net, inputs, outputVars, discretizationSize, variableRanges);
    
    gridDomainProbabilities = computeDomainProbabilities(gridProbabilities, outputVars, discretizationSize);
    probabilities = cell(1, numOutputVars);
    for i = 1:numOutputVars; probabilities{i} = squeeze(gridDomainProbabilities(i, :, :)); end

    % uncond_outputs = outputs .* max2norm(outputVars) + min2norm(outputVars);  
    uncond_outputs = denormalizeData(outputs, minMaxProportion, outputVars);
    
    if useKriging
        conditionedOutputs = zeros(size(testData));
        conditionedOutputs(:, outputVars) = outputs .* krigvars + krigmeans;
        conditionedOutputs = normcdf(conditionedOutputs);
        tic;
        T = size(dataFiltered, 2);
        steps = [1:10000:T, T];
        for i = 2:size(steps, 2)
            indexes = steps(i-1):steps(i);
            nonParametricData(indexes, :) = uniformToNonParametric(conditionedOutputs(indexes, :), ...
                sortedTrainData,  dataFiltered(:, indexes), cell_size, nonParametricData(indexes, :), outputVars, infinitesimal);
        end
        toc;
        % outputs = nonParametricData(:, outputVars) .* max2norm(outputVars) + min2norm(outputVars);
        outputs = denormalizeData(nonParametricData(:, outputVars), minMaxProportion, outputVars);
    end

    Phi = reshape(wellData(:, end-2), I, J);
    Sw13 = reshape(wellData(:, end-1), I, J);
    Sw24 = reshape(wellData(:, end), I, J);
    plotResults(net, WELLS, {Phi, Sw13, Sw24}, outputs, uncond_outputs, ...
        targetsIndexes, I, J, probabilities, minMaxProportion, ...
        'Real vs Pred. Model vs Pred. Model (unconditioned)', 'figs/comparation_results_reference', refFig);

    targets = wellData(targetsIndexes, end-2:end);

    Phi_uncond_rmse = sqrt(mean((targets(:, 1) - uncond_outputs(:, 1 )) .^ 2));
    Sw13_uncond_rmse = sqrt(mean((targets(:, 2) - uncond_outputs(:, 2)) .^ 2));
    Sw24_uncond_rmse = sqrt(mean((targets(:, 3) - uncond_outputs(:, 3)) .^ 2));
    
    uncond_rmse = Phi_uncond_rmse + Sw13_uncond_rmse + Sw24_uncond_rmse;
    
    Phi_rmse = sqrt(mean((targets(:, 1) - outputs(:, 1)) .^ 2));
    Sw13_rmse = sqrt(mean((targets(:, 2) - outputs(:, 2)) .^ 2));
    Sw24_rmse = sqrt(mean((targets(:, 3) - outputs(:, 3)) .^ 2));
    
    cond_rmse = Phi_rmse + Sw13_rmse + Sw24_rmse;

    disp('************************* IGMN Inversion *************************');
    fprintf('Unconditioned RMSE: %2.4f\n' , uncond_rmse);
    fprintf('Conditioned RMSE: %2.4f\n\n' , cond_rmse);
    disp('************************* DMS Inversion **************************')
    dms_rmse = load('dms_rmse.mat');
    fprintf('Unconditioned RMSE: %2.4f\n' , dms_rmse.uncond_rmse);
    fprintf('Conditioned RMSE: %2.4f\n\n' , dms_rmse.cond_rmse);


    regressionEntries = cell(1, 3 * numberOfOutputVars);
    for i = 1:numberOfOutputVars
        index = (i - 1) * numberOfOutputVars + 1; 
        regressionEntries{index} = targets(:, i);
        regressionEntries{index + 1} = uncond_outputs(:, i);
        regressionEntries{index + 2} = sprintf('%s Prediction', legends{i}{1});
    end
    legendNames = horzcat(legends{:});
    f = figure('Name', sprintf('%Regressions: s x %s | %s x %s | %s x %s', legendNames{:}));
    plotregression(regressionEntries{:});
    f.Children(3).Children(1).Marker = '.';
    f.Children(5).Children(1).Marker = '.';
    f.Children(7).Children(1).Marker = '.';
end
