% mchol Perform modified Cholesky decomposition on a symmetric matrix.
%
%   [L, G] = mchol(G) computes a lower triangular matrix L and a modified
%   symmetric matrix G such that G + E is positive definite, where E is a
%   matrix of small norm. The decomposition satisfies:
%
%       G + E = L * D * L'
%
%   where D is a diagonal matrix.
%
%   Input:
%       G - A symmetric matrix (NxN) to be decomposed.
%
%   Output:
%       L - A lower triangular matrix (NxN) with unit diagonal elements.
%       G - The modified symmetric matrix (NxN) after adding the matrix E.
%
%   Notes:
%       - The function ensures that the modified matrix G + E is positive
%         definite by adjusting the diagonal elements of G.
%       - The algorithm uses a threshold beta to control the adjustment
%         and ensure numerical stability.
%
%   Example:
%       G = [4, 2; 2, 3];
%       [L, G_mod] = mchol(G);
%
%   See also: CHOL
function [L, G] = mchol(G) %#codegen
    N = size(G, 1);
    beta = max([ ...
        max(diag(G)), ...
        max(max(G - diag(diag(G)))) / max([1, sqrt(N ^ 2 - 1)]), ...
        1.0E-15 ...
    ]);
    C = diag(diag(G));
    L = zeros(N);
    D = zeros(N);
    E = zeros(N);
    for i = 1:N
        cols = int32(1:i-1);
        rows = i+1:N; 
        if i > 1; L(i, cols) = C(i, cols) ./ diag(D(cols, cols))'; end
        if i >= 2
            if i < N
                C(rows, i) = G(rows, i) - (L(i, cols) * C(rows, cols)')';
            end
        else
            C(rows, i) = G(rows, i);
        end
        if i == N; theta = 0; else; theta = max(abs(C(rows, i))); end
        D(i, i) = max([eps, abs(C(i, i)), theta ^ 2 / beta]);
        E(i, i) = D(i, i) - C(i, i);
        indexes = ((i*(N + 1) + 1):(N + 1):(N * N))';
        C(indexes) = C(indexes) - (1 / D(i, i)) * C(rows, i) .^ 2;
    end
    L = bsxfun(@times, L, sqrt(D));
    L(logical(eye(size(L)))) = 1;
    G = bsxfun(@plus, G, E);
end
