%{
validateOptimizationOptions - Validates and adjusts optimization options for a given problem.

Syntax:
    options = validateOptimizationOptions(options, nhps, varIndexes)

Description:
    This function ensures that the provided optimization options are consistent
    with the number of hyperparameters (nhps) and performs necessary corrections
    to the range of initial population spans. It validates the size and content
    of the initial population and adjusts the range of the initial population
    span to match the expected dimensions.

Inputs:
    options - A structure containing optimization options, including:
              - InitialPopulation: Initial population matrix.
              - InitialPopulationSpan: Range of initial population values.
    nhps - Number of hyperparameters (scalar).
    varIndexes - Indices of variables to consider for range correction (vector).

Outputs:
    options - The validated and corrected options structure.

Subfunctions:
    rangeCorrection - Adjusts and validates the range of the initial population span.

Errors:
    - Throws an error if the size of the initial population is inconsistent with nhps.
    - Throws an error if the range of the initial population span is invalid, contains
      non-finite values, or does not match the expected dimensions.

Example:
    % Example usage of validateOptimizationOptions
    options.InitialPopulation = rand(10, 5);
    options.InitialPopulationSpan = [0.1, 0.2, 0.3, 0.4, 0.5];
    nhps = 5;
    varIndexes = [1, 2, 3, 4, 5];
    options = validateOptimizationOptions(options, nhps, varIndexes);

%}
function options = validateOptimizationOptions(options, nhps, varIndexes) %#codegen
    
    % Make sure that initial individuals are consistent with nhps
    if ~isempty(options.InitialPopulation) && size(options.InitialPopulation, 2) ~= nhps
        error('Wrong size initial population');
    end
    
    % InitialPopulationSpan
    options = rangeCorrection(options, nhps, varIndexes);
   
end % validateOptimizationOptions


function options = rangeCorrection(options, nhps, varIndexes) %#codegen
   
    range = options.InitialPopulationSpan;
    
    if ~isempty(varIndexes); range = range(varIndexes); end

    %rangeCorrection Check the size of a range variable
    range = reshape(range, 1, []); % Want row vector
    
    % Perform scalar expansion, if required
    if isscalar(range)
        range = repmat(range, 1, nhps);
    end
    
    % Check vector size
    if ~isvector(range) || numel(range) ~= nhps
        error('Invalid initial swarm span');
    end
    
    % Check for inf/nan range
    if ~all(isfinite(range))
        error('Non finite initial swarm span');
    end

    options.InitialPopulationSpan = range;
end % range correction

