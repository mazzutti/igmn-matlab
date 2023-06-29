clear all; %#ok<CLALL> 
close all;
clc;

addpath('../../../igmn/');

trainData = 0:0.01:(2 * pi);
trainData = [trainData; sin(trainData)]';
testData = linspace(0, 2 * pi, 1000);
testData = [testData; sin(testData)]';

data = [trainData ; testData];
range = [min(data); max(data)];

options = {};
options.tau = 0.1;
options.delta = 0.05;
options.vMin = int32(4);
options.spMin = int32(3);
options.compSize = int32(size(trainData, 1));

net = igmn(range, options);

net = train(net, trainData);

inputVars = 1;
outPutVars = 2;
tic;
[Y, probs] = predict(net, testData(:, inputVars), outPutVars, 0);
toc;

plotregression(testData(:, outPutVars), Y);
% figure; plotNet(net, 'sd', 4.5);
