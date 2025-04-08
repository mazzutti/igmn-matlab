% mustHaveSameNumberOfColumns - Validates that two input arrays have the same number of columns.
%
% Syntax:
%   mustHaveSameNumberOfColumns(x, y)
%
% Description:
%   This function checks whether the two input arrays, `x` and `y`, have the same
%   number of columns. If the number of columns is not the same, the function
%   throws an error with a specific identifier and message.
%
% Inputs:
%   x - First input array. Can be a matrix or any array-like structure.
%   y - Second input array. Can be a matrix or any array-like structure.
%
% Errors:
%   Throws an error with identifier 'mustHaveSameNumberOfColumns:notSameNumberOfColumns'
%   and message 'Input data has different numbers of columns' if the number of
%   columns in `x` and `y` are not equal.
%
% Example:
%   % Example usage:
%   A = [1, 2; 3, 4];
%   B = [5, 6; 7, 8];
%   mustHaveSameNumberOfColumns(A, B); % No error
%
%   C = [1, 2, 3; 4, 5, 6];
%   mustHaveSameNumberOfColumns(A, C); % Throws an error
function mustHaveSameNumberOfColumns(x, y)
    if (size(x, 2) ~= size(y, 2))
        eidType = 'mustHaveSameNumberOfColumns:notSameNumberOfColumns';
        msgType = 'Input data has different numbers of columns';
        error(eidType, msgType) 
    end
end

