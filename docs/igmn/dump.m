% dump Dumps the properties of an IGMN network object to the console.
%
%   dump(net) displays the public properties of the given IGMN network
%   object `net` in a formatted manner. If the properties are stored as
%   GPU arrays, they are gathered back to the CPU before being displayed.
%   The function handles specific formatting for properties like `covs`
%   and `means` based on the number of components (`net.nc`).
%
%   Input:
%       net - An instance of the IGMN network object whose properties
%             are to be displayed.
%
%   Behavior:
%       - Only public properties with non-empty values are displayed.
%       - The output is formatted with separators for better readability.
%       - GPU arrays are converted to standard arrays using `gather`.
%       - The display width dynamically adjusts to the longest line of
%         the formatted property values.
%
%   Example:
%       dump(myIGMN);
%       % This will display the public properties of the `myIGMN` object
%       % in a structured and readable format.
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