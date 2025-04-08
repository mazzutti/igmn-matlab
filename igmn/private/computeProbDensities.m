% COMPUTEPROBDENSITIES Compute log probability densities for IGMN components.
%
%   net = computeProbDensities(net, x) computes the log probability density
%   of the multivariate normal distribution for each component of the 
%   Incremental Gaussian Mixture Network (IGMN). The function iterates over 
%   all components in the network and updates the network structure with 
%   the computed densities.
%
%   Inputs:
%       net - A structure representing the IGMN network, which contains 
%             information about the components and their parameters.
%       x   - A vector representing the input data point for which the 
%             probability densities are evaluated.
%
%   Outputs:
%       net - The updated IGMN network structure with computed log 
%             probability densities for each component.
%
%   Note:
%       This function relies on the helper function computeProbDensity to 
%       calculate the density for each individual component.
function net = computeProbDensities(net, x) %#codegen
    for i = 1:net.nc
        net = computeProbDensity(net, x, i);
    end
end
