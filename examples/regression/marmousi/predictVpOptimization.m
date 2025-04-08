%{

This script performs optimization and regression analysis for seismic data 
and Vp (P-wave velocity) prediction using the IGMN (Incremental Gaussian Mixture Network) model. 
The script includes data preprocessing, parameter optimization, and visualization of results.

Main Steps:
1. Initialization:
    - Sets up debugging, clears workspace, and adds necessary paths.
    - Loads colormap data for visualization.

2. Data Preparation:
    - Reads seismic and Vp data from SEG-Y files.
    - Randomly selects a subset of traces for training and testing.
    - Normalizes the data using `mapminmax`.

3. Parameter Optimization:
    - Defines lower and upper bounds for optimization parameters.
    - Calls the `optimize` function to find the best parameters for the IGMN model.

4. Regression and Prediction:
    - Configures the IGMN model with optimized parameters.
    - Trains the model on training data and predicts Vp on test data.
    - Computes mean and standard deviation of predictions for visualization.

5. Visualization:
    - Plots seismic data, true Vp, predicted Vp, and prediction variance for each trace.
    - Displays regression analysis results using `plotregression`.

Key Variables:
- `totalTraces`: Total number of traces in the dataset.
- `numberOfTraces`: Number of traces used for training and testing.
- `section`: Range of data samples to be used.
- `lb`, `ub`: Lower and upper bounds for optimization parameters.
- `bestParams`: Optimized parameters for the IGMN model.
- `ws`: Window size for the IGMN model.
- `options`: Configuration options for the IGMN model.
- `regressions`: Cell array storing regression data for visualization.

Dependencies:
- `read_segy_file`: Function to read SEG-Y files.
- `mapminmax`: Function for data normalization.
- `optimize`: Function to perform parameter optimization.
- `igmn`: Class implementing the Incremental Gaussian Mixture Network.
- `plotregression`: Function to visualize regression results.

Outputs:
- Figures showing seismic data, true Vp, predicted Vp, and prediction variance.
- Regression analysis plot comparing true and predicted Vp values.

Note:
- Ensure that the required SEG-Y files (`Vp.segy` and `SYNTHETIC.segy`) and 
  supporting functions are available in the specified paths.
- Adjust the `section` and `numberOfTraces` variables as needed for different datasets.
%}
dbstop if error
clear all; %#ok<CLALL> 
close all;
clc;

addpath('../../../igmn/');
addpath(genpath('../../../Seislab 3.02'));

load('cmaps.mat');

totalTraces = 2720;
numberOfTraces = 5;
numberOfTestTraces = 1;
step = ceil(totalTraces / numberOfTraces);

section = 85:700;
Vp = read_segy_file('data/Vp.segy').traces(section , 2:end);
seismic = read_segy_file('data/SYNTHETIC.segy').traces(section , 2:end);

indexes = randperm(totalTraces);

Vp = Vp(:, indexes(1:step:totalTraces));
seismic = seismic(:, indexes(1:step:totalTraces));

data = mapminmax([seismic Vp]', 0.5, 1.0)';

seismic = data(:, 1:numberOfTraces);
Vp = data(:, numberOfTraces+1:end);

lb =  [
    1.0e-5, ...             % min tau
    1.0e-5, ...             % min delta
    2, ...                  % min spMin
    10, ...                 % min vMin
    3 ...                   % min ws (window size)
];
ub = [
    1.0 - (2 * 1.0e-5), ... % max tau
    1.0 - 1.0e-5 ...        % max delta 
    5, ...                  % max spMin
    80, ...                 % max vMin
    31, ...                 % max ws
];

[
    bestParams, ...
    dataCache, ...
    combinations ...
] = optimize(data, lb, ub, numberOfTestTraces);

ws = int32(bestParams(end));
dataWs = dataCache(ws);
k = keys(dataWs);

options = {}; 
options.tau = bestParams(1); 
options.delta = bestParams(2);
options.spMin = int32(bestParams(3));
options.vMin = int32(bestParams(4));

T = size(seismic, 1);
vs = T - ws + 1;
time = 1:T;
regressions = cell(3*length(k),1);
tracesFig = figure('NumberTitle', 'off', 'Name', 'Seismic x Vp x Pred. Vp', 'WindowState', 'maximized');
axes('Units', 'normalized', 'Position', [0 0 1 1]);
pos = get(tracesFig, 'Position');
width = pos(3) / length(k);
height = pos(4);
for key = k
    curData = dataWs(key{:});
    [trainData, testData, targets, range] = curData{:};
    net = igmn(range, options);
    net.train(trainData);
    vpPredicted = net.predict(testData(:, 1:ws));
    numberOfTraces = int32(size(vpPredicted, 1) / vs);
    vpPredicted = reshape(vpPredicted, [vs, ws, numberOfTraces]);
    std_trace = zeros(T, numberOfTraces);
    outputs = zeros(T, numberOfTraces);
    for i = 1:numberOfTraces
        ptrace = fliplr(vpPredicted(:, :, i));
        outputs(:, i) = arrayfun(@(k) mean(diag(ptrace, k)), ws-1:-1:-vs+1)';
        std_trace(:, i) = arrayfun(@(k) std(diag(ptrace, k)), ws-1:-1:-vs+1)';
    end
    index = str2double(key{:});
    seismicTestData = seismic(:, index);
    regressions(((index - 1) * 3 + 1):(index*3)) = ...
        {targets, outputs, sprintf('Mean Vp. Prev. Regression (trace: %s)', key{:})};
    subplot(1, 10, index, 'Parent', tracesFig);
    gca.Position(3) = width;
    gca.Position(4) = height;
    hold on;
    plot(targets, time, 'LineWidth', 1);
    plot(outputs, time, 'LineWidth', 1);
    yu = outputs + std_trace;
    yl = outputs - std_trace;
    fill([yu'  fliplr(yl')], [time  fliplr(time)], ...
        'r', 'FaceAlpha', 0.1, 'LineStyle',':', 'EdgeColor', 'r', 'LineWidth', 0.01);
    plot(outputs, time, 'LineWidth', 1);
    plot(seismicTestData, time, 'LineWidth', 0.5);
    legend('Vp', 'Prev. Mean Vp', 'Var.', 'Prev. Net Vp', 'Sísmica');
    title(sprintf('Trace: %s', key{:}))
    hold off;
end
figure('NumberTitle', 'off', 'Name', 'Regressions', 'WindowState','maximized');
axes('Units', 'normalized', 'Position', [0 0 1 1]);
plotregression(regressions{:});
