% crusterize - Computes the index of the component with the largest likelihood
%
% This function calculates the cluster assignments for the data points in
% the input array `X` based on the given `igmn` network. For each data point,
% the function computes the likelihood and posterior probabilities for the
% components in the network and assigns the data point to the cluster with
% the highest posterior probability.
%
% Inputs:
%   net : An instance of the `igmn` class representing the Incremental
%         Gaussian Mixture Network.
%   X   : An NxD numeric array where N is the number of data points and D
%         is the number of attributes. The array must be non-empty and
%         conform to the dimensionality requirements of the `igmn` network.
%
% Outputs:
%   idx : An Nx1 array of cluster indexes, where each element corresponds
%         to the index of the cluster assigned to the respective data point
%         in `X`.
%
% Notes:
%   - The function uses the `computeLikelihood` and `computePosterior`
%     methods of the `igmn` class to calculate the likelihoods and posterior
%     probabilities for each data point.
%   - The cluster index is determined by finding the component with the
%     maximum posterior probability.
function idx = clusterize(net, X) %#codegen
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
