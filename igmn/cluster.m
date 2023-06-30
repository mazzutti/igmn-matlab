function idx = cluster(net, X) %#codegen
    % CLUSTER Computes the index of component with the largest 
    %         likelihood
    % Calculate the indexes assignments for the data points in X 
    % for cluster analysis.
    % 
    % Inputs:
    %   X   : an NxD attributes array.
    % Output:
    %   idx : an array of cluster indexes.
    arguments
        net (1, 1) igmn;
        X (:, :) { ...
            mustBeNumeric, ...
            mustBeNonempty, ...
            mustBeNDimensional(net, X) ...
        };
    end
    N = size(X,1);
    idx = zeros(N,1);
    for i=1:N
        x = X(i,:);
        net = computeLikelihood(net, x);
        net = computePosterior(net);
        [~, idx(i)] = max(net.posteriors);
    end
end
