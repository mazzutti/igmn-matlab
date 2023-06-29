function dump(net) %#codegen
    metaClass = ?igmn;
    properties = metaClass.PropertyList;
    buffer = {};
    width = 0;
    for i = 1:size(properties, 1)
        prop = properties(i);
        propName = prop.Name;
        if isa(class(net.(propName)), 'gpuArray')
            value = gather(net.(propName));
            if strcmp(propName, "covs") || strcmp(propName, "means")
                value = value(1:net.nc);
            else
                if strcmp(propName, "covs")
                    value = value(:, :, 1:net.nc);
                else
                    value(:, 1:net.nc);
                end
            end
        else
            value = net.(propName);
        end
        if (strcmp(prop.GetAccess, 'public') && ~isempty(value))
            valueText = formattedDisplayText(value);
            lengths = strlength(strsplit(valueText, '\n'));
            width = max([width max(lengths)]);
            buffer{end+1} = strcat(sprintf(...
                "%s\n", [propName ':']), valueText);
        end 
    end
    disp(repmat('=',1, width));
    N = size(buffer, 2);
    for i = 1:N
        disp(buffer{i});
        if i < N
            disp(repmat('-',1, width));
        end
    end
    disp(repmat('=',1, width));
end