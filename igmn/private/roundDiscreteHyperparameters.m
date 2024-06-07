function population = roundDiscreteHyperparameters(population, hyperparameters, hpIndexes) %#codegen
    for i = 1:length(hpIndexes)
        hp = hyperparameters{hpIndexes(i)};
        if hp.isDiscrete
            population(:, i) = round(population(:, i));
        end
    end
end
