% denormalizeData - Denormalizes data using specified min-max proportions.
%
% Syntax:
%   data = denormalizeData(data, minMaxProportion, vars)
%
% Description:
%   This function takes normalized data and denormalizes it using the 
%   provided min-max proportion structure. The denormalization is applied 
%   to specific variables (columns) indicated by the 'vars' parameter.
%
% Inputs:
%   data - A 3D matrix of normalized data with dimensions [R, C, S], where:
%          R - Number of rows (data points).
%          C - Number of columns (variables).
%          S - Number of slices (data sets).
%   minMaxProportion - A structure containing the min-max normalization 
%                      parameters, including:
%                      - xrange: The range of the original data before 
%                                normalization.
%   vars - A vector specifying the indices of the variables (columns) to 
%          be denormalized.
%
% Outputs:
%   data - A 3D matrix of denormalized data with the same dimensions as 
%          the input data.
%
% Notes:
%   - The function uses the 'mapminmax' function with the 'reverse' option 
%     to perform the denormalization.
%   - Only the specified variables (columns) in 'vars' are denormalized.
%
% Example:
%   % Assuming 'normalizedData' is a 3D matrix of normalized data,
%   % 'minMaxProportion' contains the normalization parameters, and
%   % 'vars' specifies the columns to denormalize:
%   denormalizedData = denormalizeData(normalizedData, minMaxProportion, vars);
function data = denormalizeData(data, minMaxProportion, vars)
    [R, ~, S] = size(data);
    for i = 1:S
        denormalizedData = zeros(R, length(minMaxProportion.xrange));
        denormalizedData(:, vars) = data(:, :, i);
        denormalizedData = mapminmax('reverse', denormalizedData', minMaxProportion)';
        data(:, :, i) = denormalizedData(:, vars);
    end
end

