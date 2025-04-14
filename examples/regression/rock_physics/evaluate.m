% evaluate - Evaluates the performance of an IGMN (Incremental Gaussian Mixture Network) model 
%            on a given regression problem.
% 
% Syntax:
%     fit = evaluate(params, problem, hpNames, maxPenalty)
% 
% Inputs:
%     params      - A vector of hyperparameter values to be used for the IGMN model.
%     problem     - A structure containing the regression problem data and configuration:
%                   - trainData: Training dataset.
%                   - testData: Testing dataset.
%                   - InputVarIndexes: Indexes of input variables in the dataset.
%                   - OutputVarIndexes: Indexes of output variables in the dataset.
%                   - DefaultIgmnOptions: Default options for the IGMN model.
%     hpNames     - A cell array of hyperparameter names corresponding to the values in 'params'.
%     maxPenalty  - A scalar value representing the maximum penalty to be applied if the 
%                   number of clusters exceeds the maximum allowed.
% 
% Outputs:
%     fit         - A scalar value representing the fitness of the model. It is computed as the 
%                   root mean squared error (RMSE) of the model's predictions on the test data, 
%                   with an additional penalty if the number of clusters exceeds the maximum allowed.
% 
% Description:
%     This function trains an IGMN model using the provided training data and hyperparameters, 
%     then evaluates its performance on the test data. The fitness is calculated as the RMSE 
%     of the model's predictions, weighted by a predefined weight vector. If the number of 
%     clusters in the trained model exceeds the maximum allowed, a penalty is added to the 
%     fitness value.
% 
%     The function uses the following steps:
%     1. Extracts training and testing data, input and output variable indexes, and target values.
%     2. Configures the IGMN model using the provided hyperparameters.
%     3. Trains the IGMN model on the training data.
%     4. Predicts the output values for the test data using the trained model.
%     5. Computes the RMSE of the predictions, weighted by a predefined weight vector.
%     6. Adds a penalty to the fitness value if the number of clusters exceeds the maximum allowed.
% 
% Notes:
%     - The function assumes that the 'igmnoptions', 'igmn', 'train', 'predict', and 
%       'barrierPenalty' functions are available in the MATLAB path.
%     - The weight vector used for RMSE computation is hardcoded as [1, 1, 1] and normalized.
function fit = evaluate(params, problem, hpNames, maxPenalty) %#codegen

    trainData = problem.trainData;
    testData = problem.testData;
    inputVarIndexes = problem.InputVarIndexes;
    outpuVarIndexes = problem.OutputVarIndexes;
    targets = testData(:, outpuVarIndexes);
    testData = testData(:, inputVarIndexes);

    options = igmnoptions.from(problem.DefaultIgmnOptions, hpNames, num2cell(params));
    
    net = igmn(options);
    net = train(net, trainData);

    outputs = predict(net, testData, outpuVarIndexes);

    weight = [1, 1, 1];
    weight = weight/sum(weight);
    fit = sqrt(mean(sum(((outputs-targets) .^ 2) .* weight, 2)));

    if net.nc > net.maxNc
        fit = fit + barrierPenalty( ...
            net.nc, 0,  net.maxNc, maxPenalty, 0.5 * maxPenalty);
    end    
end
