% wrapValues - Restrict values to a specified range.
%
% Syntax:
%   values = wrapValues(values, options)
%
% Description:
%   This function ensures that the input `values` are constrained within
%   the range specified by `options.minimum` and `options.maximum`. If a
%   value is less than the minimum, it is set to the minimum. If a value
%   is greater than the maximum, it is set to the maximum.
%
% Inputs:
%   values - A double array containing the values to be constrained.
%   options - A structure with the following fields:
%       minimum - (1x1 double) The minimum allowable value. Defaults to
%                 `igmn.minimum`.
%       maximum - (1x1 double) The maximum allowable value. Defaults to
%                 `igmn.maximum`.
%
% Outputs:
%   values - A double array with the same size as the input, where all
%            elements are constrained within the specified range.
%
% Notes:
%   - This function uses MATLAB's `coder.inline('always')` directive to
%     ensure inlining during code generation.
%   - The default values for `options.minimum` and `options.maximum` are
%     taken from the `igmn` class.
function values = wrapValues(values, options) %#codegen
    arguments
        values double
        options.minimum (1, 1) double = igmn.minimum
        options.maximum (1, 1) double = igmn.maximum
    end
    coder.inline('always');
    values = double(max(min(values, options.maximum), options.minimum));
end

