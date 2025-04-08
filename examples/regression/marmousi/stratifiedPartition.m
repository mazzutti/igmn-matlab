% stratifiedPartition - Partitions data into stratified training, testing, and validation sets.
%
% Syntax:
%   [trainData, testData, valTrainData] = stratifiedPartition(allData, blockSize, traceSize, nBlockSamples)
%
% Inputs:
%   allData       - A structure containing the dataset with fields representing variables.
%   blockSize     - Size of the blocks to partition the data into.
%   traceSize     - Total size of the data in the trace dimension.
%   nBlockSamples - Number of samples to generate per block.
%
% Outputs:
%   trainData     - Stratified training data generated from Gaussian Mixture Models (GMMs).
%   testData      - Stratified testing data generated from GMMs.
%   valTrainData  - Validation data extracted from the original dataset.
%
% Description:
%   This function partitions the input data into stratified training, testing, and validation
%   datasets. It divides the data into blocks of size `blockSize` and fits Gaussian Mixture
%   Models (GMMs) to each block. The GMMs are used to generate synthetic training and testing
%   data. The function also saves the GMMs and validation data to a file for reuse.
%
%   If the file 'data/stratifiedData.mat' exists, the function loads the GMMs and validation
%   data from the file instead of recomputing them.
%
% Notes:
%   - The function uses parallel processing (parfor) to speed up GMM fitting.
%   - If a GMM fails to converge for a block, the function reduces the number of components
%     until convergence is achieved or throws an error if no convergence is possible.
%   - The training and testing data are shuffled before being returned.
%
% Example:
%   % Define input parameters
%   allData = struct('Vp', rand(100, 100), 'Vs', rand(100, 100), 'Density', rand(100, 100));
%   blockSize = 10;
%   traceSize = 100;
%   nBlockSamples = 50;
%
%   % Call the function
%   [trainData, testData, valTrainData] = stratifiedPartition(allData, blockSize, traceSize, nBlockSamples);
%
% See also:
%   fitgmdist, random, ProgressBar
function [trainData, testData, valTrainData] = stratifiedPartition(allData, blockSize, traceSize, nBlockSamples) %#codegen
    numVars = numel(fieldnames(allData));
    if ~isfile('data/stratifiedData.mat')
        T = size(allData.Vp, 2);
        rows = 1:blockSize:(floor(traceSize/blockSize) * blockSize);
        columns = 1:blockSize:(floor(T/blockSize) * blockSize);
        numRowElements = numel(rows);
        numColumnElements = numel(columns);
        gridSize = numRowElements * numColumnElements;
        gms = [];
        valTrainData = [];
        
        PB = ProgressBar(gridSize, 'Generating Gaussian Mixture Grid', 'cli');
        options = statset('Display', 'off', 'MaxIter', 800, 'TolFun', 1e-12);
        warning('off', 'stats:gmdistribution:FailedToConverge');
        parfor i = 1:numRowElements
            r = rows(i)
            for j = 1:numColumnElements
                c = columns(j); %#ok<PFBNS>
                data = getDataBlock(allData, r, c, blockSize);
                valTrainData = [valTrainData; data];
                k = blockSize;
                while k >= 1
                    gm = fitgmdist(data(:, 1:end-2), k, ...
                        'CovarianceType', 'Full', 'RegularizationValue',  0.0001, 'Options', options);
                    if gm.Converged; gms = [gms, gm]; else; k = k - 1; end
                end
                if k < 1; error('Failed to converge: (%d, %d)', r, c); end
                pause(0.001 * rand);
                count(PB);
            end
        end
        save('data/stratifiedData.mat', 'gms' , 'valTrainData');
    else
        [gms, valTrainData] = load('data/stratifiedData.mat');
    end

    numGms = numel(gms);
    nBlockTrainSamples = round(nBlockSamples * 0.8);
    nBlockTestSamples = nBlockSamples - nBlockTrainSamples;
    trainData = zeros(numGms * nBlockTrainSamples, numVars);
    testData = zeros(numGms * nBlockTestSamples, numVars);
    for i = 1:numGms
        trainData((i - 1) * nBlockTrainSamples + 1, :) = random(gms{i}, nBlockTrainSamples);
        testData((i - 1) * nBlockTestSamples + 1, :) = random(gms{i}, nBlockTestSamples);
    end
    trainData = trainData(randperm(size(trainData, 1)), :);
end

function data = getDataBlock(allData, r, c, blockSize) %#codegen
    varNames = fieldnames(allData);
    T = numel(varNames);
    data = zeros(blockSize * blockSize, T);
    for i = 1:T
        varName = varNames{i};
        block = allData.(varName)(r:(r + blockSize - 1), c:(c + blockSize - 1));
        data(:, i) = block(:);
    end
end
