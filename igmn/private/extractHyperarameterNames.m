function [hpNames, hpIndexes] = extractHyperarameterNames(optOptions)
    hyperparameters = optOptions.hyperparameters;
    nhps = length(optOptions.hyperparameters);
    useDefaultsFor = optOptions.UseDefaultsFor;
    N = nhps - length(useDefaultsFor);
    hpNames = repmat({''}, 1, N);
    hpIndexes = zeros(1, N);
    index = 1;
    for i = 1:nhps
        hpName  = hyperparameters{i}.name;
        if ~any(strcmp(useDefaultsFor, hpName))
            hpIndexes(index) = i;
            hpNames{index} = hpName;
            index = index + 1;
        end
    end
end
