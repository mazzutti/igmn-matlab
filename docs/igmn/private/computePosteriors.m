% computePosteriors Compute the posterior probabilities for each IGMN component.
%
%   net = computePosteriors(net)
%
%   This function calculates the posterior probabilities for each component
%   in the Incremental Gaussian Mixture Network (IGMN). The computation
%   method depends on whether the `useRankOne` flag in the `net` structure
%   is set to true or false.
%
%   Input:
%       net - A structure containing the IGMN parameters, including:
%             - logLikes: Log-likelihood values for each component.
%             - priors: Prior probabilities for each component.
%             - useRankOne: A flag indicating the computation method.
%
%   Output:
%       net - The updated structure with the computed posterior probabilities
%             stored in the `posteriors` field.
%
%   Details:
%       - If `useRankOne` is true:
%           The posterior probabilities are computed as the element-wise
%           product of `logLikes` and `priors`, normalized by their sum.
%           Missing values are replaced with zeros.
%
%       - If `useRankOne` is false:
%           The posterior probabilities are computed using a log-density
%           approach to avoid numerical underflow. The log-likelihoods are
%           adjusted by subtracting the maximum log-likelihood value, then
%           exponentiated and normalized.
function net = computePosteriors(net) %#codegen
    if net.useRankOne
        net.posteriors = net.logLikes .* net.priors;
        net.posteriors = net.posteriors / sum(net.posteriors);
    	net.posteriors = fillmissing(net.posteriors, 'constant', 0);
    else
        logDensity = bsxfun(@plus, net.logLikes, log(net.priors));
        % minus maxll to avoid underflow
        logDensity = exp(bsxfun(@minus, logDensity, max(logDensity, [], 2)));
        % normalize
        net.posteriors = bsxfun(@rdivide, logDensity, sum(logDensity, 2));
    end
end
