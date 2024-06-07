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

