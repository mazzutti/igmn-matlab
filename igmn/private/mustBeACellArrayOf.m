function mustBeACellArrayOf(cellArray, className)
    if ~isempty(cellArray)
        if ~all(arrayfun(@(i) strcmp(class(cellArray{i}), className), 1:length(cellArray)))
            eidType = 'mustBeACellArrayOf:notACellArrayOf';
            msgType = sprintf('The input argument nust be a cell array of %ss', className');
            error(eidType,msgType); %#ok<SPERR>
        end
    end
end

