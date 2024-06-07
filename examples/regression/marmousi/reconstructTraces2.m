function plotImage = reconstructTraces2(net, data, traceSizes, ...
    testTraces, inputVars, outputVars, outvarNames, predict, waveSize, initDeth)
    ends = cumsum(traceSizes(testTraces) - waveSize + 1);
    starts = ends - (traceSizes(testTraces)  -  waveSize + 1) + 1;

    % height = max(traceSizes(testTraces));

    T = numel(testTraces);

    % regressions = cell(3*T, 1);
    tracesFig = figure('units', 'normalized', 'outerposition', [0.1 0.1 0.9 0.9]);
    set(tracesFig,'Color', [.8 .8 .8])
    layout = tiledlayout(1, T, 'Padding', 'none', 'TileSpacing', 'loose');
    % colormap('jet');

    for i = 1:T
        traceSize = traceSizes(testTraces(i));
        inputData = data(starts(i):ends(i), inputVars);
        predictValues = fliplr(predict(net, inputData, outputVars, 0));
        targetValues = fliplr(data(starts(i):ends(i), outputVars));
        seismicValues = fliplr(data(starts(i):ends(i), inputVars(waveSize+1:2*waveSize)));
        indexes = (waveSize-1):-1:(-traceSize + waveSize);
        outputs = arrayfun(@(k) mean(diag(predictValues, k)), indexes)';
        targets = arrayfun(@(k) mean(diag(targetValues, k)), indexes)';
        seismic = arrayfun(@(k) mean(diag(seismicValues, k)), indexes)';
        stds = arrayfun(@(k) sqrt(std(diag(predictValues, k))), indexes)';
        time = initDeth:(initDeth + numel(outputs) - 1);
        % regressions(((i - 1) * 3 + 1):(i*3)) = ...
        %     {targets, outputs, sprintf('Pred. Vp Regression (trace: %d)', testTraces(i))};
        ax = nexttile(layout);
        hold(ax, 'on');
        
        gridSize = 50;
        minValues = min(outputs - stds);
        maxValues = max(outputs + stds);
        domain = linspace(floor(minValues), ceil(maxValues), gridSize);
        grid = zeros(numel(time), gridSize);
        for k = 1:numel(time)
            grid(k, :) = gaussmf(domain, [stds(k)+eps outputs(k)]);
        end

        pcolor(domain, time, grid);
        shading interp;
        % set(bg, 'facealpha', 0.6)
        h = colorbar;
        if i == T
            ylabel(h, 'Probability', 'FontSize', 10);
        end

        plot(ax, rescale(seismic, domain(1), domain(end)), time, 'm', 'LineWidth', 1);
        plot(ax, targets, time, 'k', 'LineWidth', 1);
        plot(ax, outputs, time, 'r', 'LineWidth', 1.5);

        ylim(time([1, end]));
        legend(ax, '', 'Seismic', 'Vp', 'Pred. Vp');
        title(ax, sprintf('Trace: %d', testTraces(i)))
        ylabel(ax, 'Depth (ms)');
        set(ax, 'YDir','reverse');
        hold(ax, 'off');
    end
    % figure('NumberTitle', 'off', 'Name', 'Regressions', 'WindowState','maximized');
    % axes('Units', 'normalized', 'Position', [0 0 1 1]);
    % plotregression(regressions{:});

    plotImage = frame2im(getframe(ax));
end