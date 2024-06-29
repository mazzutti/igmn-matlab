function plotStds(net, predict, data, inputVars, outputVars, theta, ...
        traceSizes, testTraces, initDeth, waveSize, traceNumber, noiseMultipliers, gridSize)
    ends = cumsum(traceSizes(testTraces) - waveSize + 1);
    starts = ends - (traceSizes(testTraces) - waveSize + 1) + 1;
    traceSize = traceSizes(testTraces(traceNumber));
    indexes = (waveSize-1):-1:(-traceSize + waveSize);
    % colormap('jet');

    stdsFig = figure;
    set(stdsFig,'Color', [.8 .8 .8])
    layout = tiledlayout(1, numel(noiseMultipliers), 'Padding', 'tight', 'TileSpacing', 'compact');

    inputData = data(starts(traceNumber):ends(traceNumber), inputVars);
    outputValues = fliplr(predict(net, inputData, outputVars, 0));
    nonNousyStds = arrayfun(@(k) sqrt(std(diag(outputValues, k))), indexes)';
   
    noise = s_noise(data(:, 1:15), {'ratio', 1}, {'type','gaussian'}, {'amplitude', 'median'});
    for m = 1:numel(noiseMultipliers)
        noiseData = addSeismicNoise(data, theta, ...
            noise, waveSize, testTraces, traceSizes, starts, noiseMultipliers(m));
        inputData = noiseData(starts(traceNumber):ends(traceNumber), inputVars);
        outputValues = fliplr(predict(net, inputData, outputVars, 0));
        outputs = arrayfun(@(k) mean(diag(outputValues, k)), indexes)';
        stds = arrayfun(@(k) sqrt(std(diag(outputValues, k))), indexes)';
    
        time = initDeth:(initDeth + numel(outputs) - 1);

        ax = nexttile(layout);
        hold(ax, 'on');

        plot(nonNousyStds(2:end-1), time(2:end-1), 'Color', 'k', 'LineWidth', 0.5);
        plot(stds(2:end-1), time(2:end-1), 'Color', 'r', 'LineWidth', 0.5);
        barh(time(2:end-1), abs(stds(2:end-1) - nonNousyStds(2:end-1, 1)), 'FaceColor', "#EDB120");
        % plot(targets(2:end-1), time(2:end-1), 'Color', colors(4, :), 'LineWidth', 1);
        % plot(nonNoisyOutputs(2:end-1), time(2:end-1), 'Color', colors(5, :), 'LineWidth', 1);
        % plot(outputs(2:end-1), time(2:end-1), 'Color', colors(6, :), 'LineWidth', 1);
        if m == 1
            ylabel(ax, 'Time (ms)', 'FontSize', 12);
        end
        titleText = sprintf('%.1f × noise ratio', noiseMultipliers(m));
        title(ax, titleText, 'FontSize', 12) 
        ylim(time([2, end-1]));
        yticklabels(round(linspace(70, 500, 11)))
        xlim([0, max([nonNousyStds(2:end-1), stds(2:end-1)], [], 'all')])
        set(gca, 'YDir','reverse');
        legend('Non-Noisy', 'Noisy', 'Uncert.', 'FontSize', 9);
        ax.XAxis.FontSize = 12;
        ax.YAxis.FontSize = 12;
        hold(ax, 'off');
    end
end

