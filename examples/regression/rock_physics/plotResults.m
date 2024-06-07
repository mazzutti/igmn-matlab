function plotResults(targets, outputs, xlabels, depth, facies, legends, ...
         outputVars, variableRanges, variableNames, outputsDomain, probabilities, plotTitle, exportFileName)

    f = figure;
    tiledlayout('horizontal', 'Padding', 'none', 'TileSpacing', 'compact');
    O = length(probabilities);
    nexttile;
    imagesc(1, depth, facies);
    xlabel(variableNames{1});
    ylabel('Depth (m)');
    
    for i = 1:O
        ax = nexttile;
        ax.FontSize = 10;
        pcolor(outputsDomain{i}, depth, probabilities{i});
        hold on; 
        shading interp;
        h = colorbar;
        if i == O
            ylabel(h, 'Probability', 'FontSize', 10);
        end
        set(ax, 'YDir','reverse');
        xlim(variableRanges(:, outputVars(i)));
        plot(targets(:, i), depth, 'k', 'LineWidth', 0.5); 
        plot(outputs(:, i), depth, 'r', 'LineWidth', 1);
        xlabel(xlabels{i}, 'FontSize', 10);
        legend(legends{i}{:}, 'Location','southoutside');
        hold off; 
    end

    pos = f.Position;
    f.Position = [pos(1)/1.8, pos(2)/1.5, pos(3)*1.5, pos(4)*1.8];

    if ~exist('exportFileName', 'var')
        sgtitle(plotTitle);
    else
        exportgraphics(f, sprintf('%s.pdf', exportFileName), 'BackgroundColor', 'none', 'Resolution', 1000)
    end
end

