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