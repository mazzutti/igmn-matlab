% computeChol - Computes the Cholesky decomposition of a covariance matrix.
%
% Syntax:
%   [L, diagL, cov] = computeChol(cov)
%
% Inputs:
%   cov - A symmetric positive-definite covariance matrix.
%
% Outputs:
%   L      - Lower triangular matrix from the Cholesky decomposition.
%   diagL  - Diagonal elements of the lower triangular matrix L.
%   cov    - The input covariance matrix, potentially modified if the
%            initial Cholesky decomposition fails.
%
% Description:
%   This function computes the Cholesky decomposition of the input
%   covariance matrix `cov`. If the decomposition fails (indicated by
%   a non-zero flag `f`), it attempts to recompute the decomposition
%   using the `mchol` function. The diagonal elements of the resulting
%   lower triangular matrix `L` are also returned.
%
% Notes:
%   - This function is intended for use with symmetric positive-definite
%     matrices. If the input matrix does not meet these criteria, the
%     behavior is undefined.
%   - The `coder.inline('always')` directive is used to suggest inlining
%     for code generation purposes.
%
% See also:
%   chol, diag, mchol
function [L, diagL, cov] = computeChol(cov) %#codegen
    coder.inline('always');
    [L, f] = chol(cov,  'lower');
    if f ; [L, cov] = mchol(cov); end
    diagL = diag(L);
end
