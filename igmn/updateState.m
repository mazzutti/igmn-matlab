function state = updateState(state, numIndividuals, pIdx) %#codegen
    % Update best fvals and best individual positions.

    state.FunEval = state.FunEval + numel(pIdx);

    % Remember the best fvals and positions for this block.
    tfImproved = false(numIndividuals, 1);
    tfImproved(pIdx) = state.Fvals(pIdx) < state.IndividualBestFvals(pIdx);
    state.IndividualBestFvals(tfImproved) = state.Fvals(tfImproved);
    state.IndividualBestPositions(tfImproved, :) = state.Positions(tfImproved, :);
end
