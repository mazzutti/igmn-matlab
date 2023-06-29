% Compute the log probability density of the multivariate normal 
% distribution evaluated for each IGMN component.
function net = computeLikelihood(net, x) %#codegen
    for i = 1:net.nc
        net = logmvnpdf(net, x, i);
    end
end