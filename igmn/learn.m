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
    coder.inline('always');
    net = computeProbDensities(net, x);
    if isempty(net.distances) || all(net.distances > net.maxDistance, 'all')
        net = addComponent(net, x); 
    end
    net = update(net, x);
end
	

function net = update(net, x) %#codegen
    coder.inline('always');
    net = computePosteriors(net);
    net = updateComponents(net, x);
    net = pruneComponents(net);
    net.numSamples = net.numSamples + 1;
end
