dbstop if error
clear all; %#ok<CLALL> 
close all;
clc;

addpath('../../../igmn/');
addpath(genpath('../../../Seislab 3.02'));

load('cmaps.mat');

totalTraces = 2720;
numberOfTraces = 15;
numberOfTestTraces = 1;
step = ceil(totalTraces / numberOfTraces);

section = 85:700;

Vp = read_segy_file('data/Vp.segy').traces(section , 2:end);
seismic = read_segy_file('data/SYNTHETIC.segy').traces(section , 2:end);

indexes = randperm(totalTraces);

Vp = Vp(:, indexes(1:step:totalTraces));
seismic = seismic(:, indexes(1:step:totalTraces));

data = mapminmax([seismic Vp]', 0.5, 1.0)';

indexes = 1:int32(size(data, 2) / 2);
combinations = nchoosek(indexes, length(indexes) - numberOfTestTraces);

ws = 28;
dataCache = prepareData(data, combinations, ws, ws);
dataWs = dataCache(ws);
k = keys(dataWs);

options = {}; 
options.tau = 5.2169e-05; 
options.delta = 0.2088;
options.spMin = 2;
options.vMin = 200;

seismic = data(:, 1:numberOfTraces);
T = size(seismic, 1);
vs = T - ws + 1;
time = 1:T;
regressions = cell(3*length(k),1);
tracesFig = figure('NumberTitle', 'off', 'Name', 'Seismic x Vp x Pred. Vp', 'WindowState','maximized');
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
    numberOfTestTraces = int32(size(vpPredicted, 1) / vs);
    vpPredicted = reshape(vpPredicted, [vs, ws, numberOfTestTraces]);
    std_trace = zeros(T, numberOfTestTraces);
    outputs = zeros(T, numberOfTestTraces);
    for i = 1:numberOfTestTraces
        ptrace = fliplr(vpPredicted(:, :, i));
        outputs(:, i) = arrayfun(@(k) mean(diag(ptrace, k)), ws-1:-1:-vs+1)';
        std_trace(:, i) = arrayfun(@(k) std(diag(ptrace, k)), ws-1:-1:-vs+1)';
    end
    index = str2double(key{:});
    seismicTestData = seismic(:, index);
    regressions(((index - 1) * 3 + 1):(index*3)) = ...
        {targets, outputs, sprintf('Mean Vp. Prev. Regression (trace: %s)', key{:})};
    subplot(1, double(numberOfTraces), index, 'Parent', tracesFig);
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
