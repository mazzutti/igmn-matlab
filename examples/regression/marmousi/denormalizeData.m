% denormalizeData - Denormalizes data using specified min-max proportions.
%
% Syntax:
%   data = denormalizeData(data, minMaxProportion, vars)
%
% Inputs:
%   data - A 3D matrix of size [R, C, S], where R is the number of rows,
%          C is the number of columns, and S is the number of slices.
%   minMaxProportion - A structure containing the min and max values for
%                      normalization, with the following field:
%                      - xrange: A vector specifying the range of values
%                                used for normalization.
%   vars - A vector specifying the indices of the variables to be
%          denormalized.
%
% Outputs:
%   data - The input data matrix with the specified variables denormalized
%          across all slices.
%
% Description:
%   This function denormalizes the specified variables in a 3D data matrix
%   using the provided min-max proportions. It iterates over each slice of
%   the data matrix, applies the reverse mapping using the `mapminmax`
%   function, and updates the corresponding variables in the data matrix.
%
% Example:
%   % Example usage of denormalizeData
%   data = rand(10, 5, 3); % Random 3D data matrix
%   minMaxProportion.xrange = [0, 1]; % Normalization range
%   vars = [1, 3]; % Variables to denormalize
%   denormalizedData = denormalizeData(data, minMaxProportion, vars);
function data = denormalizeData(data, minMaxProportion, vars)
    [R, ~, S] = size(data);
    for i = 1:S
        denormalizedData = zeros(R, length(minMaxProportion.xrange));
        denormalizedData(:, vars) = data(:, :, i);
        denormalizedData = mapminmax('reverse', denormalizedData', minMaxProportion)';
        data(:, :, i) = denormalizedData(:, vars);
    end
end

