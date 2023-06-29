function net = learn(net, x) %#codegen
    % LEARN Learns a single train sample.
    %
    % Inputs:
    %   x : an 1XD data set with 1 train sample.
    arguments
        net (1,1) igmn;
        x (1, :) { ...
            mustBeNumeric,... 
            mustBeNonempty, ...
            mustBeNDimensional(net, x) ...
        };
    end
    net = computeLikelihood(net, x);
    if sum(net.distances(1:net.nc) <= net.maxDistance)
        net = update(net, x);
    else
        net = createComponent(net, x); 
        net = update(net, x);
    end
end

function net = update(net, x) %#codegen
    net = computePosterior(net);
    net = updateComponents(net, x);
    net = removeSpurious(net);
    net.sampleSize = net.sampleSize + int32(1);
end