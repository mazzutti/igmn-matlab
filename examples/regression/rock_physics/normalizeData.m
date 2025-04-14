% normalizeData - Normalizes the input data to a specified range [0, 1].
% 
% Syntax:
%     [normalizedData, minMaxProportion] = normalizeData(data)
%     [normalizedData, minMaxProportion] = normalizeData(data, minMaxProportion)
% 
% Description:
%     This function normalizes the input data to the range [0, 1] using the
%     `mapminmax` function. If the `minMaxProportion` parameter is not provided,
%     it calculates the normalization parameters based on the input data. The
%     normalization is applied independently for each slice along the third
%     dimension of the input data.
% 
% Inputs:
%     data - A 3D array of size (R, C, S) where R is the number of rows, C is
%            the number of columns, and S is the number of slices along the
%            third dimension.
%     minMaxProportion (optional) - A structure containing the normalization
%                                   parameters, as returned by the `mapminmax`
%                                   function. If not provided, the function
%                                   computes these parameters from the input
%                                   data.
% 
% Outputs:
%     normalizedData - A 3D array of the same size as the input `data`, where
%                      each element is normalized to the range [0, 1].
%     minMaxProportion - A structure containing the normalization parameters
%                        used for the transformation, as returned by the
%                        `mapminmax` function.
% 
% Example:
%     % Normalize a 3D dataset
%     data = rand(5, 4, 3); % Example data
%     [normalizedData, minMaxProportion] = normalizeData(data);
% 
%     % Normalize another dataset using the same parameters
%     newData = rand(5, 4, 3);
%     [normalizedNewData, ~] = normalizeData(newData, minMaxProportion);
% 
% See also:
%     mapminmax
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

