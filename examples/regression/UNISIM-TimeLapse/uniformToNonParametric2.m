function [ nonParametricData ] = ...
    uniformToNonParametric2(conditioningData, sortedData, ...
        dataFiltered, grid_size, nonParametricData, outputVars, infinitesimal) %#codegen

    for i = 1:length(dataFiltered) % for each point of the grid, repeat
        filtered = dataFiltered{i};
        for j = outputVars % for each conditional variable, repeat
            % Inverse cumulative from the conditional
            cumHist = sort(filtered(:, j)); 
            if size(cumHist, 1) > 1
                % Sum an infinitesinal line to avoid intep problems
                cumHist = cumHist + infinitesimal(1:length(cumHist)); %#ok<*PFBNS>
            else
                % Inverse cumulative from the marginal
                cumHist = sortedData(:, j);  
            end
            step = 1/length(cumHist);
            nonParametricData(i, j) = interp1(step:step:1, cumHist, conditioningData(i, j), 'linear', 'extrap');
            % Filtra apenas valores em torno do valor amostrado
            index = abs(filtered(:, j) - nonParametricData(i,  j)) < grid_size;
            filtered = filtered(index, :);
        end
    end
