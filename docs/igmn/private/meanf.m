% meanf Compute the mean of an array, ignoring NaN values.
%
%   M = meanf(X) calculates the mean of the input array X, ignoring any
%   NaN values. If all elements in X are NaN, the function returns NaN.
%
%   Input:
%       X - Numeric array. Can contain NaN values.
%
%   Output:
%       M - Scalar value representing the mean of the non-NaN elements
%           in X. If X contains only NaN values, M is NaN.
%
%   Example:
%       x = [1, 2, NaN, 4];
%       m = meanf(x); % Returns 2.3333
%
%   Notes:
%       - This function prevents divide-by-zero warnings by explicitly
%         checking if the number of valid (non-NaN) elements is zero.
%       - The function uses "all" as the dimension argument for the sum
%         function to handle arrays of any size.
function m = meanf(x)
    tfValid = ~isnan(x) ;
    n = sum(tfValid, "all");
    if n == 0
        % prevent divideByZero warnings
        m = NaN;
    else
        % Sum up non-NaNs, and divide by the number of non-NaNs.
        m = sum(x(tfValid), "all") ./ n;
    end
end % 
