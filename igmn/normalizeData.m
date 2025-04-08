% normalizeData - Normalizes the input data to a specified range [0, 1].
%
% Syntax:
%   [normalizedData, minMaxProportion] = normalizeData(data)
%   [normalizedData, minMaxProportion] = normalizeData(data, minMaxProportion)
%
% Description:
%   This function normalizes the input data to the range [0, 1] using the
%   `mapminmax` function. If the `minMaxProportion` parameter is not provided,
%   it is computed from the input data. The normalization is applied to each
%   slice of the 3D input data independently.
%
% Inputs:
%   data - A 3D array of size (R, C, S) where:
%          R - Number of rows.
%          C - Number of columns.
%          S - Number of slices.
%   minMaxProportion (optional) - A structure containing the minimum and
%          maximum values used for normalization, as returned by `mapminmax`.
%
% Outputs:
%   normalizedData - A 3D array of the same size as `data`, containing the
%          normalized values in the range [0, 1].
%   minMaxProportion - A structure containing the minimum and maximum values
%          used for normalization, as returned by `mapminmax`. This can be
%          reused for consistent normalization of other datasets.
%
% Example:
%   % Normalize data and retrieve normalization parameters
%   [normalizedData, minMaxProportion] = normalizeData(data);
%
%   % Normalize another dataset using the same parameters
%   [normalizedData2, ~] = normalizeData(data2, minMaxProportion);
%
% Notes:
%   - The function uses `mapminmax` for normalization, which is part of the
%     Neural Network Toolbox in MATLAB.
%   - The normalization is applied independently to each slice along the
%     third dimension of the input data.
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

