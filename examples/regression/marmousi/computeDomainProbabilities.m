function domainProbabilities = computeDomainProbabilities(gridPredictions, features, discretizationSize)
    N = size(gridPredictions, 1);
    F = length(features);
    domainProbabilities = zeros(F, N, discretizationSize);
    for i = 1:N
        gridPostJoint = reshape(gridPredictions(i, :), discretizationSize, discretizationSize, discretizationSize);
        index = 1;
        for r = F:-1:2
            for c = (r - 1):-1:1
                domainProbabilities(index, i, :) = sum(squeeze(sum(squeeze(gridPostJoint), r)), c);
                domainProbabilities(index, i, :) = ...
                    domainProbabilities(index, i, :) ./ sum(domainProbabilities(index, i, :));
                index  = index + 1;
            end
        end
    end
end
