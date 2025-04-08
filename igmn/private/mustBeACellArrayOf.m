% MUSTBEACELLARRAYOF Validate that input is a cell array of a specific class
%
%   mustBeACellArrayOf(cellArray, className) checks if the input `cellArray`
%   is a non-empty cell array where all elements are instances of the class
%   specified by `className`. If the condition is not met, an error is thrown.
%
%   Inputs:
%       cellArray - A cell array to be validated.
%       className - A string specifying the required class of the elements
%                   in the cell array.
%
%   Errors:
%       mustBeACellArrayOf:notACellArrayOf - Thrown if `cellArray` is not a
%       cell array of elements of the specified class.
%
%   Example:
%       % Valid input
%       mustBeACellArrayOf({1, 2, 3}, 'double');
%
%       % Invalid input
%       mustBeACellArrayOf({1, 'text', 3}, 'double'); % Throws an error
function mustBeACellArrayOf(cellArray, className)
    if ~isempty(cellArray)
        if ~all(arrayfun(@(i) strcmp(class(cellArray{i}), className), 1:length(cellArray)))
            eidType = 'mustBeACellArrayOf:notACellArrayOf';
            msgType = sprintf('The input argument nust be a cell array of %ss', className');
            error(eidType,msgType); %#ok<SPERR>
        end
    end
end

