
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
