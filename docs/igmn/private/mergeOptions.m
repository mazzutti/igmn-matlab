% mergeOptions - Merges two structures, overriding default values with user-specified options.
%
% Syntax:
%   defaults = mergeOptions(defaults, options)
%
% Description:
%   This function takes two structures, `defaults` and `options`, and merges them. 
%   If a field in `options` exists in `defaults`, the value in `options` will 
%   override the value in `defaults`. If the value of a field is a structure, 
%   the function recursively merges the substructures.
%
% Inputs:
%   defaults - A structure containing default values.
%   options  - A structure containing user-specified values to override defaults.
%
% Outputs:
%   defaults - A structure with merged values, where fields in `options` 
%              override corresponding fields in `defaults`.
%
% Notes:
%   - The function assumes that `options` contains fields that are also present 
%     in `defaults` or are intended to be added to `defaults`.
%   - If a field in `options` is a structure and the corresponding field in 
%     `defaults` is also a structure, the function performs a recursive merge.
%
% Example:
%   defaults = struct('a', 1, 'b', struct('c', 2, 'd', 3));
%   options = struct('b', struct('c', 10), 'e', 5);
%   result = mergeOptions(defaults, options);
%   % result will be:
%   % struct('a', 1, 'b', struct('c', 10, 'd', 3), 'e', 5)
function defaults = mergeOptions(defaults, options) %#codegen
    fields = fieldnames(options);
    for i = 1:length(fields)
        value = defaults.(fields{i});
        if isfield(defaults, fields{i}) && isstruct(value)
            defaults.(fields{i}) = mergeOptions(defaults.(fields{i}), options.(fields{i}));
        else
            defaults.(fields{i}) = options.(fields{i});
        end
    end
end
