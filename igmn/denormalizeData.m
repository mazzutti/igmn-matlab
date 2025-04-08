% denormalizeData - Denormalizes data using specified min-max proportions.
%
% Syntax:
%   data = denormalizeData(data, minMaxProportion, vars)
%
% Inputs:
%   data - A 3D matrix of normalized data to be denormalized. The dimensions
%          are [R x C x S], where R is the number of rows, C is the number
%          of columns, and S is the number of slices.
%   minMaxProportion - A structure containing the min and max values used
%                      for normalization. It should include the field
%                      'xrange', which specifies the range of the data.
%   vars - A vector specifying the indices of the variables (columns) to
%          be denormalized.
%
% Outputs:
%   data - A 3D matrix of denormalized data with the same dimensions as the
%          input data.
%
% Description:
%   This function denormalizes the input data using the provided min-max
%   proportions. It processes each slice of the 3D data matrix individually,
%   applying the reverse mapping of the 'mapminmax' function to the specified
%   variables (columns). The denormalized data is then updated in the input
%   matrix.
%
% Example:
%   % Assuming 'normalizedData' is a 3D matrix, 'minMaxProportion' is a
%   % structure with normalization parameters, and 'vars' specifies the
%   % columns to denormalize:
%   denormalizedData = denormalizeData(normalizedData, minMaxProportion, vars);
%
% See also:
%   mapminmax
function data = denormalizeData(data, minMaxProportion, vars)
    [R, ~, S] = size(data);
    for i = 1:S
        denormalizedData = zeros(R, length(minMaxProportion.xrange));
        denormalizedData(:, vars) = data(:, :, i);
        denormalizedData = mapminmax('reverse', denormalizedData', minMaxProportion)';
        data(:, :, i) = denormalizedData(:, vars);
    end
end

