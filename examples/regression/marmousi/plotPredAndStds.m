function plotPredAndStds(net, predict, data, inputVars, outputVars, noise, theta, ...
        traceSizes, testTraces, initDeth, waveSize, traceNumber, noiseMultipliers, gridSize)
    ends = cumsum(traceSizes(testTraces) - waveSize + 1);
    starts = ends - (traceSizes(testTraces) - waveSize + 1) + 1;
    traceSize = traceSizes(testTraces(traceNumber));
    indexes = (waveSize-1):-1:(-traceSize + waveSize);
    colormap('jet');

    stdsFig = figure;
    set(stdsFig,'Color', [.8 .8 .8])
    layout = tiledlayout(1, numel(noiseMultipliers), 'Padding', 'tight', 'TileSpacing', 'tight');

    inputData = data(starts(traceNumber):ends(traceNumber), inputVars);
    outputValues = fliplr(predict(net, inputData, outputVars, 0));
    nonNousyStds = arrayfun(@(k) sqrt(std(diag(outputValues, k))), indexes)';
    nonNoisyOutputs = arrayfun(@(k) mean(diag(outputValues, k)), indexes)';

    for m = 1:numel(noiseMultipliers)
        noiseData = addSeismicNoise(data, theta, waveSize, ...
            noise, testTraces, traceSizes, starts, noiseMultipliers(m));
        inputData = noiseData(starts(traceNumber):ends(traceNumber), inputVars);
        outputValues = fliplr(predict(net, inputData, outputVars, 0));
        outputs = arrayfun(@(k) mean(diag(outputValues, k)), indexes)';
        stds = arrayfun(@(k) sqrt(std(diag(outputValues, k))), indexes)';
    
        time = initDeth:(initDeth + numel(outputs) - 1);

        ax = nexttile(layout);
        hold(ax, 'on');

        plot(nonNoisyOutputs(2:end-1), time(2:end-1), 'r', 'LineWidth', 0.75);
        plot(outputs(2:end-1), time(2:end-1), 'k', 'LineWidth', 0.75);
        barh(time(2:end-1), abs(stds(2:end-1) - nonNousyStds(2:end-1, 1)), 'b',  'FaceAlpha', 0.4);
        ylim(time([2, end-1]));
        set(gca, 'YDir','reverse');
        legend('non-noisy pred.', sprintf('noisy pred. (%.1f)', noiseMultipliers(m)), 'abs. std diff');
        hold(ax, 'off');
    end
end

