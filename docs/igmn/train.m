% train - Train the IGMN (Incremental Gaussian Mixture Network) with the dataset X.
%
% This function updates the IGMN model by iteratively learning from each 
% example in the provided dataset X. The training process stops early if 
% the network does not converge during the learning phase.
%
% Inputs:
%   net : An instance of the IGMN model (of type `igmn`) to be trained.
%   X   : A numeric, non-empty matrix of size N x D, where N is the number 
%         of training examples and D is the dimensionality of each example.
%
% Outputs:
%   net : The updated IGMN model after training with the dataset X.
function  net = train(net, X) %#codegen
    arguments
        net (1,1) igmn;
        X (:, :) { ...
            mustBeNumeric, ...
            mustBeNonempty ...
        };
    end
    N = size(X, 1);

    for i = 1:N
        net = learn(net, X(i, :));
        if ~net.converged; return; end
    end
end
