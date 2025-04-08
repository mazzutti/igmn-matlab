% extractRockTypeAndFluid - Extracts rock type and fluid data based on input data.

% Syntax:
%   rockTypeAndFluid = extractRockTypeAndFluid(rockTypeAndFluidData, data)

% Inputs:
%   rockTypeAndFluidData - A table containing reference data for rock types
%                          and fluid properties. The first two columns
%                          represent rock type and fluid identifiers, while
%                          the remaining columns represent numerical
%                          attributes for comparison.
%   data                 - A 3D matrix of numerical data (R x C x N) where
%                          R and C are spatial dimensions and N is the
%                          number of attributes.

% Outputs:
%   rockTypeAndFluid     - A 3D matrix (R x C x 2) where the first layer
%                          contains rock type identifiers and the second
%                          layer contains fluid identifiers for each
%                          spatial location.

% Description:
%   This function computes the rock type and fluid identifiers for each
%   spatial location in the input data matrix by finding the closest match
%   in the reference data (rockTypeAndFluidData). The Euclidean distance
%   is used to determine the closest match. A progress bar is displayed
%   during the computation.

% Notes:
%   - The function uses the `coder.extrinsic` directive to call the
%     `ProgressBar` function, which is assumed to be an external utility
%     for displaying progress.
%   - NaN values in the input data are ignored during computation.
%   - A small random pause is introduced in the loop to simulate
%     variability in execution time.

% Example:
%   rockTypeAndFluidData = readtable('rockTypeAndFluidData.csv');
%   data = rand(100, 100, 3); % Example 3D data
%   rockTypeAndFluid = extractRockTypeAndFluid(rockTypeAndFluidData, data);

% See also:
%   table2array, ProgressBar
function rockTypeAndFluid = extractRockTypeAndFluid(rockTypeAndFluidData, data) %#codegen
    rows = table2array(rockTypeAndFluidData(:, 3:end));
    [R, C, ~] = size(data);
    rockTypeAndFluid = nan(R, C, 2);
    rockTypeAndFluidArray = table2array(rockTypeAndFluidData(:, 1:2));
    coder.extrinsic('ProgressBar');
    PB = ProgressBar(R, 'Generating Rock Type and Fluid Data', 'cli');
    for i = 1:R
        for j = 1:C
            if ~any(isnan(data(i, j, :)))
                [~, index] = min(sqrt(sum(((rows - squeeze(data(i, j, :))') .^ 2), 2)), [], 'all');
                rockTypeAndFluid(i, j, :) = rockTypeAndFluidArray(index, :);
            end
        end
        pause(0.001*rand);
        count(PB);
    end
end
