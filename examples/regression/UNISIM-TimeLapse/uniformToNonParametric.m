% uniformToNonParametric - Transforms uniform data into non-parametric data
% based on conditional distributions.
%
% Syntax:
%   [nonParametricData] = uniformToNonParametric(conditioningData, sortedData, ...
%       dataFiltered, grid_size, nonParametricData, outputVars, infinitesimal)
%
% Inputs:
%   conditioningData - Matrix containing the conditioning data points.
%   sortedData       - Matrix of sorted data used for marginal distributions.
%   dataFiltered     - Cell array containing filtered data for each grid point.
%   grid_size        - Scalar defining the grid size for filtering.
%   nonParametricData - Pre-allocated matrix to store the resulting non-parametric data.
%   outputVars       - Array of indices specifying the output variables to process.
%   infinitesimal    - Vector of infinitesimal values to avoid interpolation issues.
%
% Outputs:
%   nonParametricData - Matrix containing the transformed non-parametric data.
%
% Description:
%   This function performs a transformation of uniform data into non-parametric
%   data using conditional distributions. For each point in the grid, it computes
%   the inverse cumulative distribution for the specified output variables. The
%   function uses parallel processing (parfor) to improve performance. It also
%   filters the data around the sampled value based on the grid size.
%
% Notes:
%   - The function uses global variable `numCores` to determine the number of
%     cores available for parallel processing.
%   - The 'spline' interpolation method is used for smooth interpolation, and
%     extrapolation is enabled.
%
% See also:
%   interp1, parfor
function [ nonParametricData ] = ...
    uniformToNonParametric(conditioningData, sortedData, ...
        dataFiltered, grid_size, nonParametricData, outputVars, infinitesimal) %#codegen

    global numCores; %#ok<GVMIS>

    parfor (i = 1:length(dataFiltered), numCores - 2) % for each point of the grid, repeat
        filtered = dataFiltered{i};
        for j = outputVars % for each conditional variable, repeat
            % Inverse cumulative from the conditional
            cumHist = sort(filtered(:, j)); 
            if size(cumHist, 1) > 1
                % Sum an infinitesinal line to avoid intep problems
                indexes = 1:length(cumHist);
                cumHist = cumHist + infinitesimal(indexes'); %#ok<*PFBNS>
            else
                % Inverse cumulative from the marginal
                cumHist = sortedData(:, j);  
            end
            step = 1/length(cumHist);
            nonParametricData(i, j) = interp1(step:step:1, cumHist, conditioningData(i, j), 'spline', 'extrap');
            % Filtra apenas valores em torno do valor amostrado
            index = abs(filtered(:, j) - nonParametricData(i,  j)) < grid_size;
            filtered = filtered(index, :);
        end
    end
end