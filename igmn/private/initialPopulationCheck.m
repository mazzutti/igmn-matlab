function options = initialPopulationCheck(options) %#codegen
    numInitPositions = size(options.InitialPopulation, 1);
    
    % No tests if initial positions is empty
    if numInitPositions == 0; return; end
    
    % Warn if too many positions were specified.
    numIndividuals = options.PopulationSize;
    if numInitPositions > numIndividuals
        warning('Too many positions were specified');
        options.InitialPopulation((numIndividuals + 1):numInitPositions, :) = [];
    end

end % function initialPopulationCheck
