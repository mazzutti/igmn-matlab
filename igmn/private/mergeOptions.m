function defaults = mergeOptions(defaults, options) %#codegen
    fields = fieldnames(options);
    for i = 1:length(fields)
        defaults.(fields{i}) = options.(fields{i});
    end
end
