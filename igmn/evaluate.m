%{
EVALUATE Evaluates the performance of an IGMN (Incremental Gaussian Mixture Network) model.

This function computes the fitness of a trained IGMN model based on the provided
problem data and hyperparameters. It supports both classification and regression
problems.

Inputs:
    - params: A vector of hyperparameter values to be used for the IGMN model.
    - problem: A structure containing the problem data and configuration, including:
        - trainData: Training dataset.
        - testData: Testing dataset.
        - InputVarIndexes: Indexes of input variables in the dataset.
        - OutputVarIndexes: Indexes of output variables in the dataset.
        - CompileOptions.IsClassification: Boolean indicating if the problem is a classification task.
        - DefaultIgmnOptions: Default options for the IGMN model.
    - hpNames: Cell array of hyperparameter names corresponding to the values in `params`.
    - maxPenalty: Maximum penalty value for exceeding the maximum number of components.

Outputs:
    - fit: A scalar value representing the fitness of the model. Lower values indicate better performance.

Details:
    - For classification problems, the fitness is computed as the number of misclassified
      samples divided by 2.
    - For regression problems, the fitness is computed as the root mean squared error (RMSE)
      between the predicted and target outputs.
    - If the model does not converge during training, the fitness is set to infinity.
    - A penalty is applied to the fitness if the number of components in the model exceeds
      the maximum allowed number of components (`net.maxNc`).

Dependencies:
    - igmnoptions.from: Creates IGMN options from default options and hyperparameters.
    - igmn: Initializes an IGMN model.
    - train: Trains the IGMN model on the training dataset.
    - classify: Classifies test data using the trained IGMN model (for classification tasks).
    - predict: Predicts outputs for test data using the trained IGMN model (for regression tasks).
    - barrierPenalty: Computes a penalty for exceeding the maximum number of components.

%}
function fit = evaluate(params, problem, hpNames, maxPenalty) %#codegen
    
    trainData = problem.trainData;
    testData = problem.testData;
    inputVarIndexes = problem.InputVarIndexes;
    outpuVarIndexes = problem.OutputVarIndexes;
    isClassification = problem.CompileOptions.IsClassification;
    targets = testData(:, outpuVarIndexes);
    testData = testData(:, inputVarIndexes);

    options = igmnoptions.from(problem.DefaultIgmnOptions, hpNames, num2cell(params));
    
    net = igmn(options);
    net = train(net, trainData);

    if ~net.converged
        fit = inf;
        return;
    end

    if isClassification
        outputs = classify(net, testData, outpuVarIndexes);
        fit = sum(targets ~= outputs, "all") / 2;
    else
        outputs = predict(net, testData, outpuVarIndexes);
        fit = sum(sqrt(mean((targets - outputs) .^ 2)), 'all');
    end

    if net.nc > net.maxNc
        fit = fit + barrierPenalty( ...
            net.nc, 0,  net.maxNc, maxPenalty, 0.5 * maxPenalty);
    end
end
