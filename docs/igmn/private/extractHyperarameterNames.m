% extractHyperarameterNames - Extracts the names and indexes of hyperparameters
%                             that are not set to use default values.
%
% Syntax:
%   [hpNames, hpIndexes] = extractHyperarameterNames(optOptions)
%
% Inputs:
%   optOptions - A structure containing the following fields:
%       hyperparameters - A cell array of structures, where each structure
%                         represents a hyperparameter and contains a 'name' field.
%       UseDefaultsFor  - A cell array of strings specifying the names of
%                         hyperparameters for which default values should be used.
%
% Outputs:
%   hpNames   - A cell array of strings containing the names of hyperparameters
%               that are not set to use default values.
%   hpIndexes - A numeric array containing the indexes of hyperparameters
%               that are not set to use default values in the original
%               hyperparameters array.
%
% Example:
%   optOptions.hyperparameters = {struct('name', 'alpha'), struct('name', 'beta')};
%   optOptions.UseDefaultsFor = {'alpha'};
%   [hpNames, hpIndexes] = extractHyperarameterNames(optOptions);
%   % hpNames = {'beta'}
%   % hpIndexes = [2]
%
% Notes:
%   - The function assumes that the 'hyperparameters' field in optOptions
%     is a cell array of structures, each containing a 'name' field.
%   - The function excludes hyperparameters listed in the 'UseDefaultsFor'
%     field from the output.
function [hpNames, hpIndexes] = extractHyperarameterNames(optOptions)
    hyperparameters = optOptions.hyperparameters;
    nhps = length(optOptions.hyperparameters);
    useDefaultsFor = optOptions.UseDefaultsFor;
    N = nhps - length(useDefaultsFor);
    hpNames = repmat({''}, 1, N);
    hpIndexes = zeros(1, N);
    index = 1;
    for i = 1:nhps
        hpName  = hyperparameters{i}.name;
        if ~any(strcmp(useDefaultsFor, hpName))
            hpIndexes(index) = i;
            hpNames{index} = hpName;
            index = index + 1;
        end
    end
end
