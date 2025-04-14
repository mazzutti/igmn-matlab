% nonOverlappingInitialCov - Computes the initial covariance matrix for a new component
% in the Incremental Gaussian Mixture Network (IGMN) model, ensuring it does not overlap
% significantly with existing components.
%
% Syntax:
%   initialCov = nonOverlappingInitialCov(net, x)
%
% Inputs:
%   net - A structure representing the IGMN model. It contains the following fields:
%       useRankOne     - A boolean indicating whether rank-one updates are used.
%       initialCov     - The initial covariance matrix.
%       initialInvCov  - The initial inverse covariance matrix (used if useRankOne is true).
%       initialLogDet  - The log determinant of the initial covariance matrix (used if useRankOne is true).
%       nc             - The number of components in the model.
%       means          - A matrix where each row represents the mean of a component.
%       covs           - A 3D array where each slice represents the covariance matrix of a component.
%       invCovs        - A 3D array where each slice represents the inverse covariance matrix of a component.
%       logDets        - A vector containing the log determinants of the covariance matrices of the components.
%       phi            - A threshold parameter for determining overlap.
%
%   x - A 1xD vector representing the data point for which the initial covariance
%       matrix is being computed.
%
% Outputs:
%   initialCov - The computed initial covariance matrix for the new component.
%
% Description:
%   This function calculates the initial covariance matrix for a new component in the IGMN model.
%   If the model has more than one component, it computes the Bhattacharyya distances between
%   the new component and existing components to ensure minimal overlap. If the overlap exceeds
%   a threshold (phi), the initial covariance matrix is adjusted to reduce the overlap.
%
% Notes:
%   - The function supports both standard covariance updates and rank-one updates.
%   - Parallel computation (parfor) is used when rank-one updates are not enabled.
%
% See also:
%   bhattDistance
function initialCov = nonOverlappingInitialCov(net, x) %# codegen
    isRankOne = net.useRankOne;
    initialCov = net.initialCov;
    if isRankOne; initialCov = net.initialInvCov; end
    if net.nc > 1
        if isRankOne
            logDetX = net.initialLogDet;
            bhattDists = arrayfun(@(i) ...
                bhattDistance(x, net.means(i, :), initialCov, ...
                net.invCovs(:, :, i), true, logDetX, net.logDets(i)), 1:net.nc);
        else
            means = net.means;
            covs = net.covs;
            bhattDists = zeros(1, net.nc);
            parfor i = 1:net.nc
                bhattDists(i) = bhattDistance(x, ...
                    means(i, :), initialCov, covs(:, :, i), false, [], []);
            end
        end

        distsCoefs = 1 ./ max(exp(bhattDists), igmn.minimum);
        bhattCoef = max(distsCoefs);

        if bhattCoef > net.phi
            initialCov = initialCov * (1 - min(1 - igmn.minimum, bhattCoef));
        end
    end
end