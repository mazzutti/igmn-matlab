% gaussianize - Transforms data to follow a standard normal distribution.
%
%   Xn = gaussianize(X) takes an input matrix X of size (n, p), where n is
%   the number of observations and p is the number of variables, and
%   transforms each column of X to approximately follow a standard normal
%   distribution (mean 0, variance 1). The transformation is performed
%   using the inverse Rosenblatt transformation.
%
%   Input:
%       X - A numeric matrix of size (n, p). Each column represents a
%           variable, and each row represents an observation. Missing
%           values (NaN) are handled and ignored during the transformation.
%
%   Output:
%       Xn - A numeric matrix of size (n, p), where each column has been
%            transformed to follow a standard normal distribution. Missing
%            values (NaN) in the input are preserved in the output.
%
%   Method:
%       1. For each column of X:
%          a. Sort the data in ascending order and compute ranks, handling
%             ties appropriately.
%          b. Compute the empirical cumulative distribution function (CDF)
%             for the non-missing values.
%          c. Apply the inverse error function (erfinv) to the CDF to
%             transform the data to a standard normal distribution.
%
%   Example:
%       % Example usage of gaussianize function
%       X = [1, 2; 3, NaN; 5, 6];
%       Xn = gaussianize(X);
%
%   Note:
%       This function assumes that the input data is continuous and does
%       not handle discrete data explicitly.
function Xn = gaussianize(X)
    [n, p] = size(X);
    Xn = NaN(n,p);
    for i = 1:p
        % Sort the data in ascending order and retain permutation indices
        Z = X(:, i); nz = ~isnan(Z); N = sum(nz);
        rank = tiedrank(Z);
        % [~, index] = sort(Z(nz));
        % % Make 'rank' the rank number of each observation
        % [~, rank] = sort(index);
        % Obtain the cumulative distribution function
        CDF = rank ./ N - 1/(2*N);
        % Apply the inverse Rosenblatt transformation
        Xn(nz, i) = sqrt(2)*erfinv(2*CDF - 1);  % Xn is now normally distributed
    end
end

