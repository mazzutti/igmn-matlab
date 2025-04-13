% nonParametricToUniform - Transforms data into a uniform distribution using non-parametric methods.
%
% Syntax:
%   [uniformeData] = nonParametricToUniform(conditioningData, data, grid_size)
%
% Inputs:
%   conditioningData - A matrix (R x C) containing the conditioning data 
%                      for each simulation (R: number of simulations, C: number of variables).
%   data             - A matrix containing the data used to compute the cumulative histogram.
%   grid_size        - A scalar defining the range around the sampled value to filter the data.
%
% Outputs:
%   uniformeData     - A matrix (R x C) where each element is the transformed value 
%                      in the uniform distribution [0, 1].
%
% Description:
%   This function transforms the input data into a uniform distribution using a non-parametric 
%   approach. For each simulation (row in conditioningData), it computes a cumulative histogram 
%   for each variable (column in conditioningData) and interpolates the conditioning data 
%   into the uniform space. The function uses parallel processing to speed up computations.
%
% Notes:
%   - The function uses a global variable `numCores` to determine the number of cores for parallel processing.
%   - An infinitesimal value is added to the cumulative histogram to avoid interpolation issues.
%   - If the cumulative histogram has only one value, the output is set to 0.5 for that variable.
%   - Data is filtered based on the `grid_size` parameter to focus on values around the sampled value.
%   - NaN values and boundary values (0 and 1) in the output are replaced with small offsets (1e-5).
%
% Example:
%   conditioningData = [0.5, 0.7; 0.2, 0.9];
%   data = rand(100, 2);
%   grid_size = 0.1;
%   uniformeData = nonParametricToUniform(conditioningData, data, grid_size);
%
% See also:
%   interp1, parfor
function [uniformeData] = nonParametricToUniform(conditioningData, data, grid_size)

    global numCores %#ok<GVMIS>
 
    [R, C] = size(conditioningData);
    uniformeData = zeros(R, C);
    infinitesimal = cumsum(zeros(length(data), 1) + 1e-10);
    parfor (i = 1:R, numCores - 2) % para cada simulacao repete;
        dataFiltered = data;
        for j = 1:C % para cada variavel repete  
            cumHist = sort(dataFiltered(:, j));  %gera cumulativa
            if size(cumHist,1) > 1
                % Sum an infinitesinal line to avoid intep problems
                cumHist = cumHist + infinitesimal(1:length(cumHist)); %#ok<PFBNS>
                step = 1/length(cumHist);
                uniformeData(i, j) = interp1(cumHist, step:step:1, conditioningData(i, j), 'spline', 'extrap');
            else
                uniformeData(i, j) = 0.5;
            end
            % Filtra apenas valores em torno do valor amostrado
            index = abs(dataFiltered(:,j) - conditioningData(i, j)) < grid_size; 
            dataFiltered(~index,:) = [];
        end
    end
    
    uniformeData(isnan(uniformeData)) = 1e-5;
    uniformeData(uniformeData == 0) = 1e-5;
    uniformeData(uniformeData == 1) = 1-1e-5;
end