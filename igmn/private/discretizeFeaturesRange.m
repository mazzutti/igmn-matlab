function domain = discretizeFeaturesRange(intervals, nc)
    howMany = size(intervals, 2);
    domain = cell(1, howMany);
    for i = 1:howMany
        interval = intervals(:, i);
        domain{i} = linspace(interval(1), interval(2), nc);
    end
end
