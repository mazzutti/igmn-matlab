% PREDICT Classifies a given input and computes posterior probabilities.
% 
%   [Y, probabilities] = PREDICT(net, X, features, discretizationSize, featureRanges)
%   classifies the input data and returns the predicted labels along with
%   the computed posterior probabilities.
%
% Inputs:
%   net                 : An instance of the igmn class representing the trained model.
%   X                   : An NxM numeric array of input attributes, where N is the number
%                         of samples and M is the number of features.
%   features            : (Optional) An array of integers or feature names specifying the
%                         features to be used for prediction. Defaults to the remaining
%                         dimensions of the model not covered by X.
%   discretizationSize  : (Optional) A scalar integer specifying the size of the grid
%                         used for discretizing feature ranges. Defaults to 0 (no discretization).
%   featureRanges       : (Optional) A numeric array specifying the range intervals for
%                         each feature to create the grid for computing probabilities.
%                         Defaults to the ranges defined in the model for the specified features.
%
% Outputs:
%   Y                   : An NxF numeric array containing the predicted data, where F is
%                         the number of features specified in the `features` input.
%   probabilities       : An Nx(discretizationSize^F) numeric array containing the computed
%                         posterior probabilities for each input sample.
%
% Notes:
%   - The function uses a step size to process the input data in chunks, ensuring
%     efficient computation for large datasets.
%   - If `discretizationSize` is specified, the function creates a grid of feature
%     values based on the provided or default feature ranges.
%   - The `recall` function is used internally to compute predictions and probabilities
%     for each chunk of data.
function [Y, probabilities] = predict(net, X, ...
        features, discretizationSize, featureRanges) %#codegen
    arguments
        net (1, 1) igmn;
        X (:, :) { ...
            mustBeNumeric, ...
            mustBeNonempty ...
        };
        features { ...
            mustBeNumeric, ...
            mustBeNonempty, ...
            mustBeInteger, ...
            mustBeNDimensional(net, X, features) ...
        } = [(size(X, 2) + 1):net.dimension],...
        discretizationSize (1, 1) { ...
            mustBeNumeric, ...
            mustBeInteger ...
        } = 0,
        featureRanges { ...
            mustBeNumeric, ...
            mustBeNonempty, ...
            mustBeNDimensional(net, X, featureRanges) ...
        } = net.range(:, features);
    end
    F = length(features);
    N = int64(size(X, 1));
    step = int64(intmax("int32")/(net.nc  ^ 2));
    Y = zeros(N, F);
    probabilities = zeros(N, discretizationSize ^ F);
    featureGrid = zeros(discretizationSize ^ F, F);
    if discretizationSize
        domain = discretizeFeaturesRange(featureRanges, discretizationSize);
        cellGrid = cell(1, F);
        [cellGrid{:}] = ndgrid(domain{:});
        featureGrid = zeros(discretizationSize ^ F, F);
        for i = 1:F; featureGrid(:, i) = cellGrid{i}(:); end
    end
    for i = 1:step:N
        slice = i:min(i+step-1, N);
        [Y(slice, :), probabilities(slice, :)] = recall(net, X(slice, :), features, featureGrid);
    end
end

