function runAndPlotResults(problem, igmnOptions, legends, showTime)
    trainData = problem.trainData;
    testData = problem.testData;
    outputVarIndexes = problem.OutputVarIndexes;
    targets = testData(:, outputVarIndexes);
    testData = testData(:, problem.InputVarIndexes);
    
    if problem.UseMex; igmn = @igmnBuilder_mex; else; igmn = @igmn; end
    if problem.UseMex; train = @train_mex; else; train = @train; end
    if problem.UseMex; classify = @classify_mex; else; classify = @classify; end
    
    if showTime; tic; end
    net = igmn(igmnOptions);
    net = train(net, trainData);
    outputs = classify(net, testData, outputVarIndexes);
    if showTime; toc; end

    O = length(outputVarIndexes);
    regressionEntries = cell(1, 3 * O);
    for i = 1:O
        index = (i - 1) * (O + 1) + 1; 
        regressionEntries{index} = targets(:, i);
        regressionEntries{index + 1} = outputs(:, i);
        regressionEntries{index + 2} = sprintf('%s x %s - Regression', legends{i}{:});
    end
    classes = {legends{1}{1} legends{2}{1}};
    targets = onehotdecode(double(targets), classes, 2);
    outputs = onehotdecode(double(outputs), classes, 2);

    legendNames = horzcat(legends{:});
    figure('Name', sprintf('Regressions: s x %s | %s x %s', legendNames{:}));
    plotregression(regressionEntries{:});
    figure('Name', sprintf('Confusion Matrix: s x %s | %s x %s', legendNames{:}));
    plotconfusion(targets, outputs);
end
