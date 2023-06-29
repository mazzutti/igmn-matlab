dbstop if error

clear all;
close all;
clc;

addpath('../../../igmn');

[x, y] = iris_dataset;
iris = [x' y'];
range = [min(iris); max(iris)]; 


iris = iris(randperm(size(iris, 1)), :);

trainDataIndices = randperm(size(iris, 1), 100);
trainData = iris(trainDataIndices, :);
testData = iris(:, :);
testData(trainDataIndices, :) = [];

options = {};
options.tau = 0.01;
options.delta = 0.2;

model = igmn(range, options);

model = train(model, trainData);

resultData = classify(model, testData(:, 1:4), [5, 6, 7], false);

expectedOut = testData(:, end-2:end);

out = zeros(size(expectedOut));
out(expectedOut == max(expectedOut, [], 2)) = 1;

plotconfusion(expectedOut', out');
