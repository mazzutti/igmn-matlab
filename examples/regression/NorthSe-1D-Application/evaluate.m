% evaluate - Evaluates the performance of an IGMN model on a given problem.
%
%   fit = evaluate(params, problem, hpNames, maxPenalty) computes the fitness
%   value (fit) of an Incremental Gaussian Mixture Network (IGMN) model based
%   on the provided parameters (params), problem definition (problem), hyperparameter
%   names (hpNames), and a maximum penalty value (maxPenalty).
%
%   Inputs:
%       params      - A vector of hyperparameter values to configure the IGMN model.
%       problem     - A structure containing the problem definition, including:
%                     - trainData: Training dataset.
%                     - testData: Testing dataset.
%                     - InputVarIndexes: Indexes of input variables.
%                     - OutputVarIndexes: Indexes of output variables.
%                     - DefaultIgmnOptions: Default options for the IGMN model.
%       hpNames     - A cell array of hyperparameter names corresponding to params.
%       maxPenalty  - A scalar value representing the maximum penalty for exceeding
%                     the maximum number of components in the IGMN model.
%
%   Outputs:
%       fit         - A scalar value representing the fitness of the model. It is
%                     computed as a weighted root mean squared error (RMSE) between
%                     the predicted and target outputs, with an additional penalty
%                     if the number of components in the model exceeds the allowed
%                     maximum.
%
%   Notes:
%       - The function uses the IGMN model to train on the training data and predict
%         outputs for the testing data.
%       - A weighted RMSE is calculated using predefined weights for each output
%         variable.
%       - If the number of components in the trained IGMN model exceeds the maximum
%         allowed, a penalty is added to the fitness value.
%
%   Example:
%       fit = evaluate(params, problem, hpNames, maxPenalty);
%
%   See also IGMN, igmnoptions, train, predict, barrierpenality.
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
    % fit = sqrt(mean((targets(:, end) - outputs(:, end)) .^ 2));
    % fit = 0.25 * sum(sqrt(mean((targets(:, 1:2) - outputs(:, 1:2)) .^ 2))) + fit;
    weight = [1, 7, 16];
    weight = weight/sum(weight);
    fit = sqrt(mean(sum(((outputs-targets) .^ 2) .* weight, 2)));

    if net.nc > net.maxNc
        fit = fit + barrierPenalty( ...
            net.nc, 0,  net.maxNc, maxPenalty, 0.5 * maxPenalty);
    end    
end
