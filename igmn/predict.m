function [Y, probabilities] = predict(net, X, features, discretizationSize) %#codegen
    % PREDICT Classifies a given input.
    %   It returns a label-binarized vector where the predict class 
    %   have value.
    % Inputs:
    %   X : an NxM attributes array.
    %   features : an optional array of ints or names.
    %   featureGrid : an optional integer with the size to be used 
    %                 for the grid to compute probabilities.
    % Output:
    %   Y : an array containing the predicted data.
    %   probabilities: the computed posterior probabilities.
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
        } = 0;
    end
    F = length(features);
    if discretizationSize
        domain = discretizeFeaturesRange(net.range(:, features), discretizationSize);
        cellGrid = cell(1, F);
        [cellGrid{:}] = ndgrid(domain{:});
        featureGrid = zeros(discretizationSize ^ F, F);
        for i = 1:F; featureGrid(:, i) = cellGrid{i}(:); end
        
        [Y, probabilities] = recall(net, X, features, featureGrid);
    else
        [Y, probabilities] = recall(net, X, features);
    end 
    
end

