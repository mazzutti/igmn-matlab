%{
% denormalizeData - Denormalizes data using specified min-max proportions.
%
% Syntax:
%   data = denormalizeData(data, minMaxProportion, vars)
%
% Inputs:
%   data - A 3D matrix of normalized data with dimensions [R x C x S], where:
%          R is the number of rows (data points),
%          C is the number of columns (features),
%          S is the number of slices (time steps or samples).
%   minMaxProportion - A structure containing the min and max values used for normalization.
%                      It should have the following fields:
%                      - xrange: The range of values for each feature.
%   vars - A vector specifying the indices of the variables (columns) to be denormalized.
%
% Outputs:
%   data - A 3D matrix of denormalized data with the same dimensions as the input.
%
% Description:
%   This function reverses the normalization process applied to the input data.
%   It uses the 'mapminmax' function in reverse mode to restore the original
%   scale of the specified variables (columns) in the data matrix.
%
% Example:
%   % Assuming 'normalizedData' is a 3D matrix of normalized values,
%   % 'minMaxProportion' contains the normalization parameters,
%   % and 'vars' specifies the columns to denormalize:
%   denormalizedData = denormalizeData(normalizedData, minMaxProportion, vars);
%
% See also:
%   mapminmax
%}
function data = denormalizeData(data, minMaxProportion, vars)
    [R, ~, S] = size(data);
    for i = 1:S
        denormalizedData = zeros(R, length(minMaxProportion.xrange));
        denormalizedData(:, vars) = data(:, :, i);
        denormalizedData = mapminmax('reverse', denormalizedData', minMaxProportion)';
        data(:, :, i) = denormalizedData(:, vars);
    end
end

