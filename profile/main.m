% This script benchmarks the performance of the Incremental Gaussian Mixture 
% Network (IGMN) for predicting the sine function. It generates training and 
% testing data based on the sine function, measures the execution time of the 
% prediction process, and outputs the benchmark results.
% 
% Key Components:
% - `dbstop if error`: Enables debugging by stopping execution when an error occurs.
% - `clear all`, `close all`, `clc`: Clears workspace, closes figures, and clears the command window.
% - `addpath('../igmn/')`: Adds the IGMN implementation directory to the MATLAB path.
% - `trainData` and `testData`: Generated datasets for training and testing, respectively, based on the sine function.
% - `global nc`: A global variable to track the number of components in the IGMN model.
% - `timeit`: Measures the execution time of the `predictSin` function.
% - `predictSin`: Wrapper function that calls `predictSinBenchmark` and updates the global variable `nc`.
% 
% Output:
% - Prints the benchmark results, including the number of training samples, 
%     testing samples, the number of components in the IGMN model (`nc`), and 
%     the mean execution time.
% 
% Dependencies:
% - Requires the `predictSinBenchmark` function, which is expected to perform 
%     the actual prediction and return the updated number of components (`nc`).
% 
% Usage:
% - Run this script to evaluate the performance of the IGMN model on the sine 
%     function dataset.
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