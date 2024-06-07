function data = denormalizeData(data, minMaxProportion, vars)
    [R, ~, S] = size(data);
    for i = 1:S
        denormalizedData = zeros(R, length(minMaxProportion.xrange));
        denormalizedData(:, vars) = data(:, :, i);
        denormalizedData = mapminmax('reverse', denormalizedData', minMaxProportion)';
        data(:, :, i) = denormalizedData(:, vars);
    end
end

