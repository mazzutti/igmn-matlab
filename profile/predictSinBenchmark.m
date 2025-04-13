%{
predictSinBenchmark - Trains an Incremental Gaussian Mixture Network (IGMN) 
and predicts outputs for a given test dataset.

Syntax:
    [Y, nc] = predictSinBenchmark(trainData, testData)

Inputs:
    trainData - A matrix containing the training data. Each row represents 
                a data point, and each column represents a feature.
    testData  - A matrix containing the test data. Each row represents 
                a data point, and each column represents a feature. The 
                first column is used for prediction.

Outputs:
    Y  - A column vector containing the predicted outputs for the test data.
    nc - The number of components in the trained IGMN model.

Description:
    This function combines the training and test datasets to calculate the 
    data range, initializes an IGMN model with specified options, trains 
    the model using the training data, and predicts the outputs for the 
    test data. The function also returns the number of components in the 
    trained IGMN model.

Options:
    - tau: A threshold parameter for the IGMN model.
    - delta: A learning rate parameter for the IGMN model.
    - vMin: Minimum degrees of freedom for the IGMN model.
    - spMin: Minimum number of samples per component for the IGMN model.
    - compSize: The size of the training dataset.

Dependencies:
    This function requires the `igmn` class or function to be implemented 
    and available in the MATLAB path. The `igmn` class should support 
    methods for initialization (`igmn`), training (`train`), and prediction 
    (`predict`).

Example:
    trainData = [1, 2; 3, 4; 5, 6];
    testData = [7, 8; 9, 10];
    [Y, nc] = predictSinBenchmark(trainData, testData);
%}
function [Y, nc] = predictSinBenchmark(trainData, testData) 
    data = [trainData ; testData];
    range = max(data) - min(data);
    
    options = {};
    options.tau = 0.1;
    options.delta = 0.001;
    options.vMin = int32(4);
    options.spMin = int32(3);
    options.compSize = int32(size(trainData, 1));
    
    net = igmn(range, options); 
    net.train(trainData);
    Y = net.predict(testData(:, 1));
    nc = net.nc;
end