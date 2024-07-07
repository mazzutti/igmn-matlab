function [normalizedData, minMaxProportion] = normalizeData(data, minMaxProportion)
    [R, C, S] = size(data);
    normalizedData = zeros(R, C, S);
    if nargin == 1
        [~, minMaxProportion] = mapminmax(reshape(permute(data, [2 1 3]), C, []), 0, 1);
    end
    for i = 1:S
        normalizedData(:, :, i) = mapminmax('apply', data(:, :, i)', minMaxProportion)';
    end    
end

