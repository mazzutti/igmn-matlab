function [trainData, testData, fullData] = ...
        genSyntheticData(data, opts, ignoredVars, nSimTrain, nSimTest)
    
    %% Split data by the cartesian product of the categorical variables
    data = removevars(data, ignoredVars);
    categoricalVarIndexes = strcmp(opts.VariableTypes(1:end-1), 'categorical');
    categoricalVarIndexes(ismember(opts.VariableNames, ignoredVars)) = [];
    categoricalVarNames = opts.VariableNames(categoricalVarIndexes);
    V = length(categoricalVarNames);
    for i = 1:V
        varName = categoricalVarNames{i};    
        data.(varName) = grp2idx(categorical(data.(varName)));
    end
    classVar = opts.VariableNames{end};
    uniqueClasses = unique(data.(classVar));
    C = length(uniqueClasses);
    subSets = cell(1, C);
    class2OneHot = onehotencode(categorical(data.(classVar)), 2);
    for i = 1:C
        indexes = data.(classVar) == uniqueClasses(i);
        subSets{i} = [table2array(data(indexes, 1:end-1)) class2OneHot(indexes, :)];
    end
  
    
    %% Gen the synthetic train and test data
    
    models = genSynthModels(subSets);
    trainData = genSynthData(models, nSimTrain, subSets);
    testData = genSynthData(models, nSimTest, subSets);
    fullData = vertcat(subSets{:});

    noise = 0.02;
    trainData = addNoise(trainData, noise, categoricalVarIndexes);
    testData = addNoise(testData, noise, categoricalVarIndexes);
end

function models = genSynthModels(subSets)
    S = length(subSets);
    models = cell(1, S);
    for i = 1:S
        subset = subSets{i};
        models{i} = fitgmdist(subset(:, 1:end-2), 2 * size(subset, 2) - 2, ...
            'RegularizationValue', 0.01,  'Options', statset(...
                'Display','final','MaxIter', 1500, 'TolFun', 1e-5));
    end
end

function synthData = genSynthData(models, nSim, subSets)
    S = length(models);
    N = size(subSets{1}, 2);
    synthData = zeros(nSim * S, N);
    for i = 1:S
        rows = (i - 1) * nSim + 1:i * nSim;
        subSet = subSets{i};
        synthData(rows, 1:N-2) = random(models{i}, nSim);
        synthData(rows, N-1:end) = repmat(subSet(1, N-1:end), nSim, 1);
    end
end

function data = addNoise(data, noise, categoricalVarIndexes)
    [N, M] = size(data);
    for i = 1: M-2
        if 	~ismember(i, categoricalVarIndexes)
            data(:, i) = data(:, i) + noise*std(data(:, i)) * randn(N, 1);
        end
    end
end
