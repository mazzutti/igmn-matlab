%{
OPTIMIZE - Optimizes the parameters of a given problem using a specified algorithm.

Syntax:
    options = optimize(problem)

Description:
    This function takes a problem structure as input and optimizes its parameters
    based on the specified optimization algorithm. The function supports multiple
    algorithms such as 'pso', 'psogsa', and 'imode'. It determines which properties
    of the default options need to be changed and applies the optimization accordingly.

Inputs:
    problem - A structure containing the following fields:
        - OptimizeOptions: A structure specifying the optimization settings, including:
            * Algorithm: The optimization algorithm to use ('pso', 'psogsa', or 'imode').
            * UseDefaultsFor: A cell array of property names for which default values should be used.
        - DefaultIgmnOptions: A structure containing the default options for the IGMN algorithm.

Outputs:
    options - A structure containing the optimized parameters for the problem.

Notes:
    - The function uses helper functions `pso`, `psogsa`, and `imode` to perform the optimization
      based on the selected algorithm.
    - The `igmnoptions.from` method is used to construct the final options structure by
      combining the default options with the optimized values for the specified properties.

Example:
    % Define a problem structure
    problem.OptimizeOptions.Algorithm = 'pso';
    problem.OptimizeOptions.UseDefaultsFor = {'property1', 'property2'};
    problem.DefaultIgmnOptions = defaultOptions;

    % Optimize the problem
    options = optimize(problem);

See also:
    pso, psogsa, imode, igmnoptions.from
%}
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
