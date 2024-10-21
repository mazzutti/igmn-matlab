%#ok<*UNRCH>
%#ok<*CLALL> 

dbstop if error
clear all;
close all;
clc;

global traceSizes %#ok<*GVMIS>
global testTraces
global targets

rng('default');
rng(23);

addpath('../../../igmn/');
addpath(genpath('../../../GeoStatRockPhysics/SeReM/'));
addpath(genpath('../../../Seislab 3.02/Seislab 3.02/')); presets;
load('cmaps.mat');

theta = 15:15:45;
genSynthData = false;
discretizationSize = 10;
initDeth = 396;
noiseMultipliers = [0, 0.1, 0.5, 1];

trainTraces = [680, 2040, 3400, 4760, 6120, 7481, 8841, 10201, 11561, 12921];
testTraces = [2334, 6941, 8277, 11238];
waveSize = 5;
% selectedOutVar = 'Rho';
% variableNames = [arrayfun(@num2str, 15:3:45, ...
%     'UniformOutput', 0), {'lowVp'}, {'lowVs'}, {'lowRho'}, {'Vp'}, {'Vs'}, {'Rho'}];

selectedOutVar = 'AI';
variableNames = [arrayfun(@num2str, 15:15:45, 'UniformOutput', 0), {'lowAI'}, {'AI'}];

[trainData, testData, allData, traceSizes, targets, noisyTestData] = ...
    prepareData(genSynthData, trainTraces, testTraces, initDeth, waveSize, noiseMultipliers, false);

traceNumber = 3;
% plotAIForPaper(squeeze(allData(:, :, end)), trainTraces, testTraces(traceNumber), initDeth, 'AI_data');

numberOfOutputVars = waveSize;
nvars = (numel(theta) + 1) * waveSize + numberOfOutputVars;
inputVars = 1:(nvars - numberOfOutputVars);
outputVars = (numel(inputVars) + 1):nvars;

% logIndexes = [inputVars(end-waveSize)+1:inputVars(end), outputVars];
logIndexes = outputVars;
% 
% trainData(:, logIndexes) = log(trainData(:, logIndexes));
% testData(:, logIndexes) = log(testData(:, logIndexes));

% trainData = trainData(:, [inputVars, outputVars]);
% testData = testData(:,  [inputVars, outputVars]);
% outputVars = outputVars-waveSize;

valTrainData = [trainData ; testData];

problem = Problem( ...
    trainData, ...
    testData, ...
    'InputVarIndexes', inputVars, ...
    'OutputVarIndexes', outputVars, ...
    'AllData', valTrainData, ...
    'ExecutionMode', 'mex', ...
    'DoParametersTuning', false, ...
    'CompileOptions', compileoptions(...
        'EnableRecompile', false, ...
        'NumberOfVariables', nvars, ...
        'NumberOfOutputVars', numberOfOutputVars, ...
        'IsOptimization', true));

problem.OptimizeOptions.Algorithm = 'imode';
problem.OptimizeOptions.UseDefaultsFor = {'MaxNc', 'UseRankOne'};
problem.OptimizeOptions.MaxFunEval = 3000000;
problem.OptimizeOptions.PopulationSize = 120;
problem.OptimizeOptions.StallIterLimit = 400;
problem.OptimizeOptions.UseParallel = true;
problem.OptimizeOptions.TolFunValue = 1e-18;

problem.OptimizeOptions.hyperparameters{6}.ub = 50;
problem.OptimizeOptions.hyperparameters{6}.lb = 9;
problem.OptimizeOptions.hyperparameters{5}.ub = 8;
problem.OptimizeOptions.hyperparameters{5}.lb = 2;
problem.OptimizeOptions.hyperparameters{2}.ub = 0.99;
problem.OptimizeOptions.hyperparameters{2}.lb = 1e-18;
problem.OptimizeOptions.hyperparameters{1}.ub = 0.99;
problem.OptimizeOptions.hyperparameters{1}.lb = 1e-18;
problem.OptimizeOptions.hyperparameters{7}.ub = 1e-2;

problem.DefaultIgmnOptions.UseRankOne = 1;
problem.DefaultIgmnOptions.MaxNc = 100;
% problem.DefaultIgmnOptions.SPMin = 3;
% problem.DefaultIgmnOptions.VMin = 24;
% problem.DefaultIgmnOptions.RegValue = 8.318713393298100e-05;
% problem.DefaultIgmnOptions.Tau = 0.533771951767000;
% problem.DefaultIgmnOptions.Delta = 0.315811438338866;
% problem.DefaultIgmnOptions.Gamma = 0.591804495912762;
% problem.DefaultIgmnOptions.Phi = 0.620279050234828;

if strcmpi(problem.ExecutionMode, 'mex') || strcmpi(problem.ExecutionMode, 'native') 
    compile(problem);
    if strcmpi(problem.ExecutionMode, 'mex')
        optimize = @optimize_mex;
        igmn = @igmnBuilder_mex;
        train = @train_mex;
        predict = @predict_mex;
    end
% else
%     predict = @predict;
end

if ~strcmpi(problem.ExecutionMode, 'native')
    if problem.DoParametersTuning
        igmnOptions = optimize(problem);
        save('igmnOptions', 'igmnOptions');
    else
        igmnOptions = load('igmnOptions.mat').igmnOptions;
    end
    
    tic;
    net = igmn(igmnOptions);
    net = train(net, trainData);
    toc;
   
    gridSize = 50;
    set(0, 'DefaultAxesFontSize', 12);
    traceNoisyTestData = noisyTestData{traceNumber};
    plotResults(net, predict, traceNoisyTestData, inputVars, outputVars, selectedOutVar, ...
        traceNumber, initDeth, testTraces, traceSizes, waveSize, noiseMultipliers, gridSize);
    
    exportgraphics(gcf, sprintf('%s.pdf', 'std_with_noisy_seismic'), 'Resolution', 300)
    
    stds_igmn = plotStds(net, predict, traceNoisyTestData, inputVars, outputVars, ...
        traceSizes, testTraces, initDeth, waveSize, traceNumber, noiseMultipliers, gridSize);

    stds_esmda = runSeReM(waveSize, theta, true, traceNoisyTestData);
    
    % N = length(noiseMultipliers);
    % R = zeros(N, N);
    % for i = 1:N
    %     for j = 1:N
    %         disp([i, j]);
    %         R(i, j) = vartestn([stds_esmda(:, (j-1)*waveSize+1:j*waveSize), stds_igmn(:, (i-1)*waveSize+1:i*waveSize)]);
    %     end
    % end

    stds_fig = figure('units','normalized', 'outerposition', [0.3 0.15 0.5 0.8]);
    set(stds_fig, 'color', [254/255, 252/255, 246/255]);
    set(0, 'DefaultAxesFontSize', 22,  'defaultTextInterpreter', 'latex');
    layout = tiledlayout(2, 2, 'Padding', 'tight', 'TileSpacing', 'compact');
    N = length(noiseMultipliers);
    cmap = parula;
    for i = 1:N
        ax = nexttile;
        std_esmda = normalize(std(stds_esmda(:, (i-1) * waveSize+1:i*waveSize), [], 2) .^ 2);
        std_igmn = normalize(std(stds_igmn(:, (i-1) * waveSize+1:i*waveSize), [], 2) .^ 2);
        hg = histogram(ax, std_esmda);
        hg.FaceColor = [65/255, 144/255, 160/255];
        hold on;
        hg = histogram(ax, std_igmn);
        hg.FaceColor = [242/255, 187/255, 68/255];
        legend('ES-MDA', 'Bagging ANN', 'FontSize', 16);
        title(sprintf("%.1f x noise ratio", noiseMultipliers(i)), 'FontWeight', 'bold');
        if mod(i, 2) == 0
            yticks([]);
        else
            ylabel('Frequency')
        end

        if i >= 3
            xlabel('$\sigma^2$');
        end
    end

    exportgraphics(gcf, "esmda_x_ann_variance.pdf", 'Resolution', 300)

    labels = {'0.0', '0.1', '0.5', '1'};
    % fancyCorrPlot(R, labels);
    % corrplot([stds_igmn, stds_esmda]);
    
    % ends = cumsum(traceSizes(testTraces) - waveSize + 1);
    % starts = ends - (traceSizes(testTraces) - waveSize + 1) + 1;
    % noiseMultipliers = [0, 0.1, 1, 2, 4];
    % indexes = (waveSize-1):-1:(-traceSize + waveSize);
    % traceSize = traceSizes(testTraces(traceNumber));
    % figure;
    % for m = 1:numel(noiseMultipliers)
    %     indexes = (waveSize-1):-1:(-traceSize + waveSize);
    %     noiseData = addSeismicNoise(testData, theta, waveSize, noise, testTraces, traceSizes, starts, noiseMultipliers(m));
    %     inputData = noiseData(starts(traceNumber):ends(traceNumber), inputVars);
    %     outputValues = fliplr(predict(net, inputData, outputVars, 0));
    %     outputs = arrayfun(@(k) mean(diag(outputValues, k)), indexes)';
    %     stds = arrayfun(@(k) sqrt(std(diag(outputValues, k))), indexes)';
    % 
    %     time = initDeth:(initDeth + numel(outputs) - 1);
    % 
    %     minValues = min(outputs - stds);
    %     maxValues = max(outputs + stds);
    %     domain = linspace(floor(minValues), ceil(maxValues), gridSize);
    %     grid = zeros(numel(time), gridSize);
    %     for k = 1:numel(time)
    %         grid(k, :) = gaussmf(domain, [stds(k)+eps outputs(k)]);
    %     end
    %     plot(max(grid, [], 2));
    %     hold on;
    % end
    
    % traceSize = traceSizes(testTraces(traceNumber));
    % inputData = testData(starts(traceNumber):ends(traceNumber), inputVars);
    % predictValues = fliplr(predict(net, inputData, outputVars, 0));
    % targetValues = fliplr(testData(starts(traceNumber):ends(traceNumber), outputVars));
    % seismicValues = fliplr(testData(starts(traceNumber):ends(traceNumber), inputVars(waveSize+1:2*waveSize)));
    % indexes = (waveSize-1):-1:(-traceSize + waveSize);
    % outputs = arrayfun(@(k) mean(diag(predictValues, k)), indexes)';
    % targets = arrayfun(@(k) mean(diag(targetValues, k)), indexes)';
    % seismic = arrayfun(@(k) mean(diag(seismicValues, k)), indexes)';
    % stds = arrayfun(@(k) sqrt(std(diag(predictValues, k))), indexes)';
    % 
    % time = initDeth:(initDeth + numel(outputs) - 1);
    % 
    % ax = nexttile(layout);
    % hold(ax, 'on');
    % 
    % gridSize = 50;
    % minValues = min(outputs - stds);
    % maxValues = max(outputs + stds);
    % domain = linspace(floor(minValues), ceil(maxValues), gridSize);
    % grid = zeros(numel(time), gridSize);
    % for k = 1:numel(time)
    %     grid(k, :) = gaussmf(domain, [stds(k)+eps outputs(k)]);
    % end
    % 
    % pcolor(domain, time, grid);
    % shading interp;
    % 
    % plot(ax, rescale(seismic, domain(1), domain(end)), time, 'm', 'LineWidth', 1);
    % plot(ax, targets, time, 'k', 'LineWidth', 1);
    % plot(ax, outputs, time, 'r', 'LineWidth', 1.5);
    % 
    % ylim(time([1, end]));
    % legend(ax, '', 'Seismic', 'Vp', 'Pred. Vp');
    % title(ax, sprintf('Trace: %d (without seismic noise)', testTraces(traceNumber)))
    % ylabel(ax, 'Depth (ms)');
    % set(ax, 'YDir','reverse');
    % pbaspect(ax,[0.5, 2, 1])
    % hold(ax, 'off');
    % 
    % inputData = noiseTestData(starts(traceNumber):ends(traceNumber), inputVars);
    % predictValues = fliplr(predict(net, inputData, outputVars, 0));
    % targetValues = fliplr(noiseTestData(starts(traceNumber):ends(traceNumber), outputVars));
    % seismicValues = fliplr(noiseTestData(starts(traceNumber):ends(traceNumber), inputVars(waveSize+1:2*waveSize)));
    % indexes = (waveSize-1):-1:(-traceSize + waveSize);
    % outputsWithNoise = arrayfun(@(k) mean(diag(predictValues, k)), indexes)';
    % targets = arrayfun(@(k) mean(diag(targetValues, k)), indexes)';
    % seismicWithNoise = arrayfun(@(k) mean(diag(seismicValues, k)), indexes)';
    % stdsWithNoise = arrayfun(@(k) sqrt(std(diag(predictValues, k))), indexes)';
    % time = initDeth:(initDeth + numel(outputsWithNoise) - 1);
    % ax = nexttile(layout);
    % hold(ax, 'on');
    % 
    % gridSize = 50;
    % minValues = min(outputsWithNoise - stdsWithNoise);
    % maxValues = max(outputsWithNoise + stdsWithNoise);
    % domain = linspace(floor(minValues), ceil(maxValues), gridSize);
    % gridWithNoise = zeros(numel(time), gridSize);
    % for k = 1:numel(time)
    %     gridWithNoise(k, :) = gaussmf(domain, [stdsWithNoise(k)+eps outputsWithNoise(k)]);
    % end
    % 
    % pcolor(domain, time, gridWithNoise);
    % shading interp;
    % 
    % plot(ax, rescale(seismicWithNoise, domain(1), domain(end)), time, 'm', 'LineWidth', 1);
    % plot(ax, targets, time, 'k', 'LineWidth', 1);
    % plot(ax, outputsWithNoise, time, 'r', 'LineWidth', 1.5);
    % 
    % ylim(time([1, end]));
    % legend(ax, '', 'Seismic', 'Vp', 'Pred. Vp');
    % title(ax, sprintf('Trace: %d (with seismic noise)', testTraces(traceNumber)))
    % set(ax, 'YDir','reverse');
    % set(ax, 'yticklabel', [])
    % pbaspect(ax,[0.5, 2, 1])
    % hold(ax, 'off');
    % 
    % 
    % ax = nexttile(layout);
    % hold(ax, 'on');
    % diff = gridWithNoise - grid;
    % gridDiff = nan(size(grid));
    % gridDiff(:) = eps;
    % gridDiff(diff>1e-20) = diff(diff>1e-20);
    % 
    % pcolor(domain, time, gridDiff);
    % shading interp;
    % h = colorbar;
    % 
    % plot(ax, rescale(seismic, domain(1), domain(end)), time, 'm', 'LineWidth', 1);
    % plot(ax, rescale(seismicWithNoise, domain(1), domain(end)), time, 'g', 'LineWidth', 1);
    % plot(ax, outputs, time, 'r', 'LineWidth', 1);
    % plot(ax, outputsWithNoise, time, 'k', 'LineWidth', 1);
    % 
    % ylim(time([1, end]));
    % legend(ax, '', 'Seismic', 'Seismic (noise)', 'Pred. Vp', 'Pred. Vp (noise)');
    % title(ax, sprintf('Trace: %d (uncertainty diff)', testTraces(traceNumber)))
    % set(ax, 'YDir','reverse');
    % set(ax, 'yticklabel', [])
    % ylabel(h, 'Probability (addition off uncertainty)', 'FontSize', 10);
    % hold(ax, 'off');
end
