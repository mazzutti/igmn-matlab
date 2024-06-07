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
