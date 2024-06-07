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
