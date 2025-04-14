% learn - Learns a single training sample and updates the network.
%
% This function processes a single training sample `x` and updates the 
% Incremental Gaussian Mixture Network (IGMN) `net`. It computes the 
% probability densities, adds new components if necessary, and updates 
% the network's components and parameters.
%
% Inputs:
%   net : An instance of the `igmn` class representing the network.
%   x   : A 1xD numeric array representing a single training sample.
%         - Must be numeric.
%         - Must be non-empty.
%         - Must have dimensions compatible with the network.
%
% Outputs:
%   net : The updated `igmn` network after processing the training sample.
%
% Internal Functions:
%   - computeProbDensities: Computes the probability densities for the 
%     given sample.
%   - addComponent: Adds a new component to the network if the sample 
%     is sufficiently distant from existing components.
%   - update: Updates the network by computing posteriors, updating 
%     components, pruning components, and incrementing the sample count.
%
% See also: computeProbDensities, addComponent, update
function net = learn(net, x) %#codegen
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
