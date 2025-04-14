% classify - Classifies a given input using the IGMN model.
% 
%   This function takes an input array and classifies it using the 
%   Incremental Gaussian Mixture Network (IGMN). It returns a label-binarized 
%   vector where the predicted class is represented with a value of 1, and 
%   all other classes are represented with a value of 0.
%
% Inputs:
%   net      - An instance of the IGMN model (of type `igmn`).
%   X        - An NxM numeric array representing the input attributes, 
%              where N is the number of samples and M is the number of features.
%              This input must be non-empty.
%   features - (Optional) A numeric vector specifying the indices of the 
%              features to be used for classification. By default, this is 
%              set to the range [(size(X, 2) + 1):net.dimension]. The vector 
%              must be non-empty, consist of integers, and satisfy the 
%              dimensionality constraints of the `net` and `X`.
%
% Outputs:
%   Y - A binary matrix where each row corresponds to a sample in `X`, and 
%       each column corresponds to a class. The predicted class for each 
%       sample is marked with a 1, while all other entries are 0.
function Y = classify(net, X, features)
    arguments
        net (1, 1) igmn;
        X (:, :) { ...
            mustBeNumeric, ...
            mustBeNonempty ...
        };
        features (1, :) { ...
            mustBeNumeric, ...
            mustBeNonempty, ...
            mustBeInteger, ...
            mustBeNDimensional(net, X, features) ...
        } = [(size(X, 2) + 1):net.dimension];
    end
    Y = predict(net, X, features, 0);
    Y = Y == max(Y, [], 2);
end
