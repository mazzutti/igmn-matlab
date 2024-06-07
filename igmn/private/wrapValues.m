function values = wrapValues(values, options) %#codegen
    arguments
        values double
        options.minimum (1, 1) double = igmn.minimum
        options.maximum (1, 1) double = igmn.maximum
    end
    coder.inline('always');
    values = double(max(min(values, options.maximum), options.minimum));
end

