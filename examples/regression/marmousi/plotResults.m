function plotResults(net, predict, data, inputVars, outputVars, ...
        selectedOutVar, traceNumber, theta, initDeth, traces, traceSizes, waveSize, noiseMultipliers, gridSize)
    ends = cumsum(traceSizes(traces) - waveSize + 1);
    starts = ends - (traceSizes(traces) - waveSize + 1) + 1;

    tracesFig = figure;
    set(tracesFig,'Color', [.8 .8 .8])
    layout = tiledlayout(1, numel(noiseMultipliers), 'Padding', 'tight', 'TileSpacing', 'compact');
    noise = s_noise(data(:, 1:15), {'ratio', 1}, {'type','gaussian'}, {'amplitude', 'median'});
    for m = 1:numel(noiseMultipliers)
        noiseData = addSeismicNoise(data, theta, noise, waveSize, traces, traceSizes, starts, noiseMultipliers(m));
        traceSize = traceSizes(traces(traceNumber));
        inputData = noiseData(starts(traceNumber):ends(traceNumber), inputVars);
        outputValues = fliplr(predict(net, inputData, outputVars, 0));
        targetValues = fliplr(data(starts(traceNumber):ends(traceNumber), outputVars));
        seismicValues = fliplr(inputData(:, inputVars(waveSize+1:2*waveSize)));
        indexes = (waveSize-1):-1:(-traceSize + waveSize);

        ax = nexttile(layout);
        
        if m == numel(noiseMultipliers); withColorBar = true; else; withColorBar = false; end
        if m == 1
            legends = {'', 'Seismic', selectedOutVar, sprintf('Pred. %s', selectedOutVar)};
            title = 'non-noisy';
            ylabelText = 'Time (ms)';
        else
            legends = {'', 'Seismic', selectedOutVar, sprintf('Pred. %s', selectedOutVar)};
            title = sprintf('%.1f × noise ratio', noiseMultipliers(m));
            ylabelText = [];
        end
        hold(ax, 'on');
        plotTrace(outputValues, targetValues, seismicValues, ...
            indexes, initDeth, ax, legends, title, gridSize, ylabelText, withColorBar)
        hold(ax, 'off');
    end
end



function plotTrace(outputValues, targetValues, seismicValues, ...
    indexes, initDeth, ax, legends, titleText, gridSize, ylabelText, withColorBar)
    outputs = arrayfun(@(k) mean(diag(outputValues, k)), indexes)';
    targets = arrayfun(@(k) mean(diag(targetValues, k)), indexes)';
    seismic = arrayfun(@(k) mean(diag(seismicValues, k)), indexes)';
    stds = arrayfun(@(k) sqrt(std(diag(outputValues, k))), indexes)';

    time = initDeth:(initDeth + numel(outputs) - 1);

    minValues = min(outputs - stds);
    maxValues = max(outputs + stds);
    domain = linspace(floor(minValues), ceil(maxValues), gridSize);
    grid = zeros(numel(time), gridSize);
    for k = 1:numel(time)
        grid(k, :) = gaussmf(domain, [stds(k)+eps outputs(k)]) .^ (1/4);
    end

    % interval = 154:305;
    interval = 1:size(time, 2);
    
    pcolor(domain, time(interval), grid(interval, :));
    shading interp;
    
    rescaledSeimic = rescale(seismic, domain(1), domain(end));
    plot(ax, rescaledSeimic(interval), time(interval), 'm', 'LineWidth', 1);
    plot(ax, targets(interval), time(interval), 'k', 'LineWidth', 1);
    plot(ax, outputs(interval), time(interval), 'r', 'LineWidth', 1.5);

    xlim([min([rescaledSeimic(interval), outputs(interval)], [], 'all'), ...
        max([rescaledSeimic(interval), outputs(interval)], [], 'all')])
    
    time = time(interval);
    ylim(time([1, end]));
    yticklabels(round(linspace(70, 500, 11)))
    legend(ax, legends{:}, 'FontSize', 9);
    title(ax, titleText, 'FontSize', 12)
    ylabel(ax, ylabelText, 'FontSize', 12);
    if withColorBar
        h = colorbar('FontSize', 12);
        ylabel(h, 'Probability', 'FontSize', 12);
    end
    ax.XAxis.FontSize = 12;
    ax.YAxis.FontSize = 12;
    set(ax, 'YDir','reverse');
end

