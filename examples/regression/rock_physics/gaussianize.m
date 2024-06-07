
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

% function Xn = gaussianize(X)
%     addpath('Rcall-master');
%     Rclear;
%     Rinit({'bestNormalize'});
%     Rpush('X', X);
%     % Rrun('nCores <- detectCores()');
%     % Rrun('cluster <- snow::makeCluster(nCores, type = "SOCK")');
%     Rrun('BN_obj <- bestNormalize(X, allow_lambert_s = TRUE, allow_lambert_h = TRUE)');
%     Rrun('gx <- predict(BN_obj)');
%     % Rrun('stopCluster(cluster)');
%     % Rrun('plot(BN_obj, leg_loc = "bottomright")');
%     Xn = Rpull('gx');
%     disp(fileread('Rrun.Rout'));
%     Rclear;
% end
