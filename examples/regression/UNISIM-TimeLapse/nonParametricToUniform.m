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