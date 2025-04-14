% normalizeData - Normalizes the input data to a specified range [0, 1].
%
% Syntax:
%   [normalizedData, minMaxProportion] = normalizeData(data)
%   [normalizedData, minMaxProportion] = normalizeData(data, minMaxProportion)
%
% Inputs:
%   data - A 3D matrix (R x C x S) containing the data to be normalized.
%          R: Number of rows, C: Number of columns, S: Number of slices.
%   minMaxProportion - (Optional) A structure containing the minimum and
%                      maximum values for normalization, as returned by
%                      the mapminmax function. If not provided, it will
%                      be computed from the input data.
%
% Outputs:
%   normalizedData - A 3D matrix (R x C x S) containing the normalized data.
%   minMaxProportion - A structure containing the minimum and maximum
%                      values used for normalization, as returned by the
%                      mapminmax function.
%
% Description:
%   This function normalizes the input data to the range [0, 1] using the
%   mapminmax function. If the minMaxProportion parameter is not provided,
%   it computes the normalization parameters based on the input data. The
%   normalization is applied slice by slice along the third dimension (S).
%
% Example:
%   % Normalize a 3D matrix
%   data = rand(5, 4, 3); % Example data
%   [normalizedData, minMaxProportion] = normalizeData(data);
%
%   % Normalize another dataset using the same parameters
%   newData = rand(5, 4, 3);
%   [normalizedNewData, ~] = normalizeData(newData, minMaxProportion);
%
% See also:
%   mapminmax
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

