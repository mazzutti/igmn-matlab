% bhattDistance - Computes the Bhattacharyya distance between two distributions.
%
% Syntax:
%   bhattDist = bhattDistance(meanX, meanY, covX, covY, useRankOne, logDetX, logDetY)
%
% Inputs:
%   meanX      - Mean vector of the first distribution.
%   meanY      - Mean vector of the second distribution.
%   covX       - Covariance matrix of the first distribution.
%   covY       - Covariance matrix of the second distribution.
%   useRankOne - Logical flag indicating whether to use a rank-one update
%                for the covariance matrix inversion.
%   logDetX    - Logarithm of the determinant of the covariance matrix of
%                the first distribution.
%   logDetY    - Logarithm of the determinant of the covariance matrix of
%                the second distribution.
%
% Outputs:
%   bhattDist  - The Bhattacharyya distance between the two distributions.
%
% Description:
%   This function calculates the Bhattacharyya distance, which is a measure
%   of similarity between two probability distributions. It takes into
%   account the means and covariance matrices of the distributions. The
%   computation can optionally use a rank-one update for efficiency.
%
% Notes:
%   - The function assumes that the input covariance matrices are positive
%     definite.
%   - The `useRankOne` flag determines the method used for covariance
%     matrix inversion and affects the computation of the distance.
%
% Example:
%   meanX = [1; 2];
%   meanY = [2; 3];
%   covX = [1, 0.5; 0.5, 1];
%   covY = [1, 0.2; 0.2, 1];
%   useRankOne = false;
%   logDetX = log(det(covX));
%   logDetY = log(det(covY));
%   bhattDist = bhattDistance(meanX, meanY, covX, covY, useRankOne, logDetX, logDetY);
function bhattDist = bhattDistance( ...
    meanX, meanY, covX, covY, useRankOne, logDetX, logDetY) %# codegen
    dmu =  bsxfun(@minus, meanX, meanY);
    factor = 0.125;
    if useRankOne
        numerator = covX * dmu';
        denominator = 1 + dmu * numerator;
        invCov = covX - (numerator * numerator') / denominator;
        firstTerm = dot(invCov * dmu', dmu);
        logdet = logDetX * denominator;
        secondTerm = logdet / sqrt(logDetX * logDetY);
    else
        factor = factor / 2;
        C = bsxfun(@rdivide, bsxfun(@plus, covX, covY), 2);
        dmu = dmu / computeChol(C);
        firstTerm = (dmu * dmu');
        secondTerm = det(bsxfun( ...
            @mrdivide, C, computeChol(bsxfun(@mtimes, covX, covY))));
    end
    if secondTerm > 0; secondTerm = log(secondTerm); end
    bhattDist = factor * firstTerm + 0.5 * secondTerm;
end
