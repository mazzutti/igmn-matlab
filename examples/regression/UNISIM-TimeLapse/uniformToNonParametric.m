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

% (conditioningData, data, grid_size, inputs, outputVars) %#codegen
% 
%     numInputs = size(inputs, 2);
% 
%     [R, C] = size(conditioningData);
%     nonParametricData = zeros(R, C);
%     infinitesimal = cumsum(zeros(length(data), 1) + 1e-10);
%     sortedData = sort(data);
%     nonParametricData(:, 1:numInputs) = inputs(:, 1:numInputs);
%     parfor i = 1:R % for each point of the grid, repeat
%         dataFiltered = data;
%         index = all(abs(dataFiltered(:, 1:numInputs) - inputs(i, :)) < grid_size, 2);
%         dataFiltered = dataFiltered(index, :);
%         for j = outputVars % for each conditional variable, repeat
%             % Inverse cumulative from the conditional
%             cumHist = sort(dataFiltered(:, j)); 
%             if size(cumHist, 1) > 1
%                 % Sum an infinitesinal line to avoid intep problems
%                 cumHist = cumHist + infinitesimal(1:length(cumHist)); %#ok<*PFBNS>
%             else
%                 % Inverse cumulative from the marginal
%                 cumHist = sortedData(:, j);  
%             end
%             step = 1/length(cumHist);
%             nonParametricData(i, j) = interp1(step:step:1, cumHist, conditioningData(i, j), 'linear', 'extrap');
%             % Filtra apenas valores em torno do valor amostrado
%             index = abs(dataFiltered(:, j) - nonParametricData(i,  j)) < grid_size;
%             dataFiltered = dataFiltered(index, :);
%         end
%     end
% end