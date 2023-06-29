function  net = train(net, X) %#codegen
    % TRAIN Train the IGMN with the dataset X.
    % 
    % Inputs:
    %   X : an NXD data set with the train examples.
    arguments
        net (1,1) igmn;
        X (:, :) { ...
            mustBeNumeric, ...
            mustBeNonempty ...
        };
    end
    for i = 1:size(X, 1)
        net = learn(net, X(i, :));
    end
end