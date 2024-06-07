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
    N = size(X, 1);

    for i = 1:N
        net = learn(net, X(i, :));
        if ~net.converged; return; end
    end
end
