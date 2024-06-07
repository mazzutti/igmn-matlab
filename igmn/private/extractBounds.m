function [lbRow, ubRow, nhps] = extractBounds(hyperparameters, hpIndexes) %#codegen
    nhps = length(hpIndexes);
    lbRow = arrayfun(@(i) hyperparameters{i}.lb, hpIndexes);
    ubRow = arrayfun(@(i) hyperparameters{i}.ub, hpIndexes);
end
