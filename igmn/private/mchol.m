function [L, G] = mchol(G) %#codegen
    %  MCHOL Given a symmetric matrix G, find a matrix E of "small" norm 
    %        such that  G+E is Positive Definite, and 
    %
    %        G+E = L*D*L'
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
        cols = 1:i-1;
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