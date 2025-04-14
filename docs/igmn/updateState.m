% updateState - Updates the state of the optimization process.
%
% Syntax:
%   state = updateState(state, numIndividuals, pIdx)
%
% Description:
%   This function updates the state of an optimization process by:
%   - Incrementing the function evaluation counter.
%   - Updating the best function values and corresponding positions for 
%     individuals that have improved during the current iteration.
%
% Inputs:
%   state           - A structure containing the current state of the 
%                     optimization process. It includes fields such as:
%                     - FunEval: Total number of function evaluations.
%                     - Fvals: Current function values for all individuals.
%                     - IndividualBestFvals: Best function values for each 
%                       individual.
%                     - IndividualBestPositions: Best positions for each 
%                       individual.
%                     - Positions: Current positions of all individuals.
%   numIndividuals  - The total number of individuals in the population.
%   pIdx            - Indices of the individuals to be updated.
%
% Outputs:
%   state           - The updated state structure with the following changes:
%                     - FunEval incremented by the number of individuals 
%                       specified in pIdx.
%                     - IndividualBestFvals and IndividualBestPositions 
%                       updated for individuals that have improved.
%
% Notes:
%   - The function assumes that the input state structure is properly 
%     initialized and contains all required fields.
%   - The function uses logical indexing to efficiently update the best 
%     values and positions for improved individuals.
function state = updateState(state, numIndividuals, pIdx) %#codegen

    state.FunEval = state.FunEval + numel(pIdx);

    % Remember the best fvals and positions for this block.
    tfImproved = false(numIndividuals, 1);
    tfImproved(pIdx) = state.Fvals(pIdx) < state.IndividualBestFvals(pIdx);
    state.IndividualBestFvals(tfImproved) = state.Fvals(tfImproved);
    state.IndividualBestPositions(tfImproved, :) = state.Positions(tfImproved, :);
end
