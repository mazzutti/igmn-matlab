function [Y, probabilities] = predict(net, X, features, discretizationSize) %#codegen
    % PREDICT Classifies a given input.
    %   It returns a label-binarized vector where the predict class 
    %   have value.
    % Inputs:
    %   X : an NxM attributes array.
    % Output:
    %   Y : an array containing the predicted data.
    F = length(features);
    
    if discretizationSize
        domain = discretizeFeaturesRange(net.range(:, features), discretizationSize);
        cellGrid = cell(1, F);
        [cellGrid{:}] = ndgrid(domain{:});
        featureGrid = zeros(discretizationSize ^ F, F);
        for i = 1:F; featureGrid(:, i) = cellGrid{i}(:); end
        
        [Y, probabilities] = recall(net, X, features, featureGrid);
    else
        [Y, probabilities] = recall(net, X, features, []);
    end 
    
end

