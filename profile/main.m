dbstop if error
clear all; %#ok<CLALL> 
close all;
clc;

addpath('../igmn/');

trainData = linspace(0, 2 * pi, 8000);
trainData = [trainData ; sin(trainData)]';
testData = linspace(0, 2 * pi, 8000);
testData = [testData ; sin(testData)]';

global nc; %#ok<GVMIS>
nc = 0;

t = timeit(@() predictSin(trainData, testData));
fprintf(['IGMN sin benchmark mean time ' ...
    '(num_train_samples: %u, ' ...
    'num_test_samples: %u, ' ...
    'nc: %u): %fs\n'], size(trainData, 1), size(testData, 1), nc, t);


function predictSin(trainData, testData)
    global nc %#ok<GVMIS>
    [~, nc] = predictSinBenchmark(trainData, testData);
end