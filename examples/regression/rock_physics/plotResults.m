function plotResults(targets, outputs, xlabels, depth, facies, legends, ...
        outputVars, variableRanges, variableNames, outputsDomain, probabilities, plotTitle)
    subplots = [141, 142, 143, 144];
    O = length(probabilities);
    figure;
    subplot(subplots(1));
    imagesc(1, depth, facies);
    xlabel(variableNames{1});
    ylabel('Depth (m)');
    
    for i = 1:O
        ax = subplot(subplots(i + 1));
        pcolor(outputsDomain{i}, depth, probabilities{i});
        hold on; 
        shading interp;
        h = colorbar;
        ylabel(h, 'Probability');
        set(ax, 'YDir','reverse');
        xlim(variableRanges(:, outputVars(i)));
        plot(targets(:, i), depth, 'k', 'LineWidth', 0.1); 
        plot(outputs(:, i), depth, 'r', 'LineWidth', 0.1);
        xlabel(xlabels{i});
        legend(legends{i}{:});
        hold off; 
    end
    sgtitle(plotTitle);
end

