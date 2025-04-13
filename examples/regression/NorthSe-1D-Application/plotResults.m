function plotResults(net, targets, inputs, outputs, useFacies, depth, facies, legends, ...
         variableRanges, variableNames, outputsDomain, probabilities, plotTitle, exportFileName)

    titles = {'(a)', '(b)', '(c)', '(d)', '(e)', '(f)', '(g)'};
    set(0, 'DefaultAxesFontSize', 20,  'defaultTextInterpreter', 'latex');
 
    f = figure('units','normalized', 'outerposition', [0 0 1 1]);
    tiledlayout(f, 1, 7, 'Padding', 'loose', 'TileSpacing', 'loose');
    ax = nexttile;
    imagesc(1, depth, facies);
    label = xlabel(variableNames{1}, 'FontWeight', 'bold', 'FontSize', 22);
    label.Position(2) = label.Position(2) + 2;
    ylabel('\boldmath{$Depth$} \boldmath{$(m)$}', 'FontSize', 22);
    ax.YAxis.Exponent = 3;
    xticks(ax, []);
    tt = title(titles{1}, 'FontSize', 20, 'FontWeight', 'bold', 'Interpreter', 'none');
    tt.Position(2) = tt.Position(2) - 0.6;
    patch(nan, nan, [0.2, 0.2, 0.7], 'EdgeColor', 'black');
    patch(nan, nan, [1, 1, 0.1], 'EdgeColor', 'black');
    leg = legend({'\emph{Oil Sand}', '\emph{Shale}'}, 'Location', 'southoutside', 'FontSize', 22, 'Interpreter', 'latex');
    leg.ItemTokenSize = [leg.ItemTokenSize(2)/2, leg.ItemTokenSize(2)/2];
    leg.Position(2) = leg.Position(2) - 0.000015;
    colormap(ax, parula)
    
    if useFacies
        inputs = inputs(:, 2:end);
    end

    for i = 1:size(inputs, 2)
        ax = nexttile;
        plot(inputs(:, i), depth, 'k', 'LineWidth', 0.5);
        label = xlabel(variableNames{i + 1}, 'FontWeight', 'bold', 'FontSize', 22);
        set(ax, 'YDir','reverse');
        set(ax, 'Yticklabel', []);
        if max(ax.XAxis.TickValues) >= 1000 
            ax.XAxis.Exponent = 3;
            sl = ax.XRuler.SecondaryLabel;
            sl.Units = 'normalized';
            sl.Position(2) = sl.Position(2) + abs(sl.Position(2)) * 0.3;
            sl.Position(1) = sl.Position(1) + abs(sl.Position(1)) * 0.2;
        end
        label.Position(2) = label.Position(2) + 8;
        tt = title(titles{i + 1}, 'FontSize', 22, 'FontWeight', 'bold', 'Interpreter', 'none');
        tt.Position(2) = tt.Position(2) - 1;
    end

    I = size(inputs, 2);
    for i = 1:size(targets, 2)
        ax = nexttile;
        plot(targets(:, i), depth, 'k', 'LineWidth', 2);
        label = xlabel(variableNames{i + I + 1}, 'FontWeight', 'bold', 'FontSize', 22);
        set(ax, 'YDir','reverse');
        set(ax, 'Yticklabel', []);
        xlim(variableRanges(:, i));
        xticks(variableRanges(1, i):(variableRanges(2, i) - variableRanges(1, i))/2:variableRanges(2, i));
        if max(ax.XAxis.TickValues) >= 1000 
            ax.XAxis.Exponent = 3;
            sl = ax.XRuler.SecondaryLabel;
            sl.Units = 'normalized';
            sl.Position(2) = sl.Position(2) + abs(sl.Position(2)) * 0.35; 
        end
        label.Position(2) = label.Position(2) + 8;
        tt = title(titles{i + I + 1}, 'FontSize', 22, 'FontWeight', 'bold', 'Interpreter', 'none');
        tt.Position(2) = tt.Position(2) - 1;
    end

    if exist('exportFileName', 'var')
        exportgraphics(f, sprintf('figs/%s.pdf', '1D_well_logs'), 'BackgroundColor', 'none', 'Resolution', 1000)
    else
        sgtitle('Well Logs');
    end

    titles = {'(d)', '(e)', '(f)', '(g)', '(h)', '(i)'};
    O = size(outputs, 2);
    
    prob_color_map = load("prob_color_map.mat").prob_color_map;
   
    f = figure('units','normalized', 'outerposition', [0.02 0.02 0.96/2 0.96]);
    set(0, 'DefaultAxesFontSize', 22,  'defaultTextInterpreter', 'latex');
    % tiledlayout(f, 1, 6, 'Padding', 'loose', 'TileSpacing', 'compact');

    ha = tight_subplot(1, 3, [.01 .015], [0.01 .04], [.064 .036]);

    for i = 1:O
        ax = ha(i);
        axes(ax); %#ok<LAXES>
        probs = probabilities{i};
        pcolor(ax, outputsDomain{i}, depth, probs);
        hold('on');
        shading interp;
        h = colorbar;
        if i == 3
            ylabel(h, '\boldmath{$Probability$}', 'FontSize', 22, 'Interpreter', 'latex');
        end
        if i == 1
            ylabel('\boldmath{$Depth$} \boldmath{$(m)$}', 'FontSize', 22, 'Interpreter', 'latex');
        end
        set(ax, 'YDir','reverse');
        xlim(variableRanges(:, i));
        xticks(variableRanges(1, i):(variableRanges(2, i) - variableRanges(1, i))/2:variableRanges(2, i));
        plot(targets(:, i), depth, 'k', 'LineWidth', 2); 
        plot(outputs(:, i), depth, 'r', 'LineWidth', 2);
        xlabel(variableNames{ i + I + 1}, 'FontWeight', 'bold', 'FontSize', 22);
        if i  ~= 1
            set(ax, 'Yticklabel', []);
        end
        legend({'', 'Reference', 'Prediction'}, 'Location', 'southoutside', 'FontSize', 22);
        tt = title(titles{i}, 'FontSize', 22, 'FontWeight', 'bold', 'Interpreter', 'none');
        tt.Position(2) = tt.Position(2) - 0.6;
        colormap(ax, prob_color_map);
        grid;
        hold('off');
    end

    if exist('exportFileName', 'var')
        exportgraphics(f, sprintf('%s.pdf', exportFileName), 'BackgroundColor', 'none', 'Resolution', 1000)
    else
        sgtitle(plotTitle);
    end

    means = net.means;
    covs = pageinv(net.invCovs);
    gm = gmdistribution(net.means, covs, net.priors);
    logs = random(gm, 3000);
    if useFacies
        logs = logs(:, 2:end); 
        means = means(:, 2:end);
        covs = covs(2:end, 2:end, :);
    end

    variableRanges = [3040, 1630, 2, 0, 0, 0 ; 4880, 3125, 2.6, 0.4, 0.8, 1];
    variableNames = {'\boldmath{$\alpha$}', ...
        '\boldmath{$\beta$}', '\boldmath{$\rho$}', ...
        '\boldmath{$\phi$}', '\boldmath{$V_c$}', ...
        '\boldmath{$S_w$}'};
    f = generate_histograms(logs, variableNames, [0, 8], variableRanges, means, covs, net.priors);
    sgtitle(f, '(b)', 'FontWeight', 'bold', 'FontSize', 22,  'Interpreter', 'none');

    if exist('exportFileName', 'var')
         exportgraphics(f, 'figs/igmn_histogram.pdf', 'BackgroundColor', 'none', 'Resolution', 1000)
    end

    regressionEntries = cell(1, 3 * O);
    for i = 1:O
        index = (i - 1) * O + 1; 
        regressionEntries{index} = targets(:, i);
        regressionEntries{index + 1} = outputs(:, i);
        regressionEntries{index + 2} = sprintf('%s Prediction', legends{i}{1});
    end
    legendNames = horzcat(legends{:});
    f = figure('Name', sprintf('%Regressions: s x %s | %s x %s | %s x %s', legendNames{:}));
    plotregression(regressionEntries{:});
    f.Children(3).Children(1).Marker = '.';
    f.Children(5).Children(1).Marker = '.';
    f.Children(7).Children(1).Marker = '.';
end

