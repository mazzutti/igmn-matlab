function options = optimize(problem) %#codegen
    optOptions = problem.OptimizeOptions;
    defaultIgmnOptions = problem.DefaultIgmnOptions;
    props = properties(defaultIgmnOptions);
    useDefaultsFor = ['range', optOptions.UseDefaultsFor];
    toChangeProps = repmat({''}, 1, length(props) - length(useDefaultsFor));
    index = 1;
    for i = 1:length(props)
        if ~any(strcmp(useDefaultsFor, props{i}))
            toChangeProps{index} = props{i};
            index = index + 1;
        end
    end
    if strcmp(optOptions.Algorithm, 'pso')
        options = igmnoptions.from(defaultIgmnOptions, toChangeProps, num2cell(pso(problem)));
    elseif strcmp(optOptions.Algorithm, 'psogsa')
        options = igmnoptions.from(defaultIgmnOptions, toChangeProps, num2cell(psogsa(problem)));
    else
        options = igmnoptions.from(defaultIgmnOptions, toChangeProps, num2cell(imode(problem)));
    end
end
