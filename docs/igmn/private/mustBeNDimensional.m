% mustBeNDimensional - Validate that input dimensions match the network's dimension
%
%   mustBeNDimensional(net, x, y) checks if the combined dimensions of 
%   inputs `x` and `y` match the expected dimension specified in the 
%   `net.dimension` property. If the dimensions do not match, an error 
%   is thrown.
%
%   mustBeNDimensional(net, x) checks if the dimensions of input `x` 
%   match the expected dimension specified in the `net.dimension` 
%   property. If the dimensions do not match, an error is thrown.
%
%   Inputs:
%       net - A structure or object containing the `dimension` property 
%             that specifies the expected dimensionality.
%       x   - Input data array whose second dimension is considered.
%       y   - (Optional) Additional input data array whose second 
%             dimension is considered.
%
%   Throws:
%       MException with identifier 'mustHaveSameDimension:notSameDimension' 
%       if the combined dimensions of `x` and `y` (or just `x` if `y` is 
%       not provided) do not match `net.dimension`.
function mustBeNDimensional(net, x, y)
    coder.extrinsic('MException')
    coder.extrinsic('throwAsCaller')
    if nargin == 3
        D = size(x, 2) + size(y, 2); 
    else
        D = size(x, 2); 
    end
    if D ~= net.dimension
        eidType = 'mustHaveSameDimension:notSameDimension';
        msgType = 'Input must have the same dimension of data range';
        throwAsCaller(MException(eidType,msgType))
    end
end
