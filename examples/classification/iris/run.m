% This script demonstrates the classification of the Iris dataset using the 
% Incremental Gaussian Mixture Network (IGMN) algorithm. The script performs 
% the following steps:
% 
% 1. Sets up the MATLAB environment by enabling debugging, clearing variables, 
%     closing figures, and clearing the command window.
% 2. Adds the IGMN library to the MATLAB path.
% 3. Loads the Iris dataset and prepares it for training and testing.
% 4. Configures the IGMN model with specified options, including the range of 
%     input data, Tau, and Delta parameters.
% 5. Randomly shuffles the dataset and splits it into training and testing sets.
% 6. Initializes and trains the IGMN model using the training data.
% 7. Classifies the test data using the trained model and extracts the 
%     classification results.
% 8. Compares the classification results with the expected output and generates 
%     a confusion matrix plot to evaluate the model's performance.
% 
% Dependencies:
% - The script requires the IGMN library located in the relative path 
%   '../../../igmn'.
% - The Iris dataset is loaded using the `iris_dataset` function.
% 
% Inputs:
% - The Iris dataset, which consists of 4 input features and 3 output classes.
% 
% Outputs:
% - A confusion matrix plot showing the performance of the IGMN model on the 
%   test data.
% 
% Note:
% - Ensure that the IGMN library is correctly installed and accessible at the 
%   specified path.
% - The script uses random shuffling and splitting of the dataset, which may 
%   lead to different results on each run.
dbstop if error
clear all; %#ok<CLALL>
close all;
clc;

addpath('../../../igmn');

[x, y] = iris_dataset;
iris = [x' y'];
range = [min(iris); max(iris)]; 

options = igmnoptions(range, 'Tau', 0.01, 'Delta', 0.2);

iris = iris(randperm(size(iris, 1)), :);

trainDataIndices = randperm(size(iris, 1), 100);
trainData = iris(trainDataIndices, :);
testData = iris(:, :);
testData(trainDataIndices, :) = [];

model = igmn(options);

model = train(model, trainData);

resultData = classify(model, testData(:, 1:4), [5, 6, 7]);

expectedOut = testData(:, end-2:end);

out = zeros(size(expectedOut));
out(expectedOut == max(expectedOut, [], 2)) = 1;

plotconfusion(expectedOut', out');
