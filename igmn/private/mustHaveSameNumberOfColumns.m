function mustHaveSameNumberOfColumns(x, y)
    if (size(x, 2) ~= size(y, 2))
        eidType = 'mustHaveSameNumberOfColumns:notSameNumberOfColumns';
        msgType = 'Input data has different numbers of columns';
        error(eidType, msgType) 
    end
end

