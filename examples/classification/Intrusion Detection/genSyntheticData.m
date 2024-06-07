function [trainData, testData, allData] = genSyntheticData(data, opts, vars, nSimTrain, nSimTest)

    warning('off', 'stats:cvpartition:HOTrainingZero');
    warning('off', 'stats:cvpartition:HOTestZero');
    
    data = data(:, vars);
    data = data(randperm(size(data, 1)), :);
    categoricalVarIndexes = strcmp(opts.VariableTypes, 'categorical');
    categoricalVarNames = opts.VariableNames(categoricalVarIndexes);
    categoricals = data.Properties.VariableNames(ismember(data.Properties.VariableNames, categoricalVarNames));
    V = length(categoricals);
    for i = 1:V
        varName = categoricals{i};    
        data.(varName) = grp2idx(categorical(data.(varName)));
    end
    classVar = categoricals{end};
    uniqueClasses = unique(data.(classVar));
    C = length(uniqueClasses);
    class2OneHot = onehotencode(categorical(data.(classVar)), C);
    categoricalVars = ismember(vars, categoricals);

    data = table2array(data);
    p = data(:, 1:end-1);
    % 
    % p = gaussianize2(p);
    % save("gaussianized_data_all_vars.mat", "p");
    % load('gaussianized_data_all_vars.mat');

    p(:, ~categoricalVars) = gaussianize(p(:, ~categoricalVars));

    allData = [p, class2OneHot];

    categoricalData = data(:, categoricalVars);
    catDataCells = arrayfun(@(c) categoricalData(:, c), 1:size(categoricalData, 2), 'UniformOutput', false);
    groups = findgroups(catDataCells{:});

   
    counts = groupcounts(groups);
    threshold = round(length(counts)/2);
    % threshold = 4;
    oversampledData = [];
    oversampledClass2OneHot = [];
    for i = 1:length(counts)
        c = counts(i);
        if c < threshold
            if c == 1
                oversampledData = [oversampledData; repmat(p(groups == i, :)', 1, threshold-c)']; %#ok<*AGROW>
                oversampledClass2OneHot = [oversampledClass2OneHot; repmat(class2OneHot(groups == i, :)', 1, threshold-c)'];
            else
                [inputs, idx] = datasample(p(groups == i, :)', threshold - c, 2);
                targets = class2OneHot(groups == i, :);
                oversampledData = [oversampledData; inputs']; %#ok<*AGROW>
                oversampledClass2OneHot = [oversampledClass2OneHot; targets(idx, :)];
            end
        end
    end

    oversampledData = [p; oversampledData];
    oversampledClass2OneHot = [class2OneHot; oversampledClass2OneHot];
    oversampledData = [oversampledData, oversampledClass2OneHot];
    oversampledData = oversampledData(randperm(size(oversampledData, 1)), :);

    % oversampledData = [p, class2OneHot];

    categoricalData = oversampledData(:, categoricalVars);
    catDataCells = arrayfun(@(c) categoricalData(:, c), 1:size(categoricalData, 2), 'UniformOutput', false);
    groups = findgroups(catDataCells{:});

    numTrainSamples = round(size(groups, 1) * 0.8);

    trainPartition = cvpartition(groups, 'HoldOut', numTrainSamples, 'Stratify', true);
    trainIndexes = test(trainPartition);
    testIndexes = training(trainPartition);
    
    trainData = oversampledData(trainIndexes, :);
    testData = oversampledData(testIndexes, :);

    categoricalData = trainData(:, categoricalVars);
    catDataCells = arrayfun(@(c) categoricalData(:, c), 1:size(categoricalData, 2), 'UniformOutput', false);
    groups = findgroups(catDataCells{:});

    trainPartition = cvpartition(groups, 'HoldOut', nSimTrain, 'Stratify', true);
    trainData = trainData(test(trainPartition), :);

    categoricalData = testData(:, categoricalVars);
    catDataCells = arrayfun(@(c) categoricalData(:, c), 1:size(categoricalData, 2), 'UniformOutput', false);
    groups = findgroups(catDataCells{:});

    testPartition = cvpartition(groups, 'HoldOut', nSimTest, 'Stratify', true);
    testData = testData(test(testPartition), :);

end 
