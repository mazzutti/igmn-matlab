%{
PLOTRESULTS - Visualizes regression results and probabilities for rock physics data.

This function generates a tiled plot layout to display the regression 
results, including facies classification, probability distributions, 
and comparisons between reference and predicted outputs.

SYNTAX:
    plotResults(targets, outputs, xlabels, depth, facies, legends, ...
                outputVars, variableRanges, variableNames, outputsDomain, ...
                probabilities, initDeth, endDepth, plotTitle, exportFileName)

INPUTS:
    targets         - Matrix of reference target values (depth x variables).
    outputs         - Matrix of predicted output values (depth x variables).
    xlabels         - Cell array of strings for x-axis labels of each variable.
    depth           - Vector of depth values (depth x 1).
    facies          - Vector of facies classification values (depth x 1).
    legends         - Cell array of legend labels for the plots.
    outputVars      - Vector of indices specifying which variables to plot.
    variableRanges  - Matrix specifying the range of each variable (2 x variables).
    variableNames   - Cell array of variable names for labeling.
    outputsDomain   - Cell array of domain values for each output variable.
    probabilities   - Cell array of probability matrices (depth x domain).
    initDeth        - Integer specifying the starting depth index for plotting.
    endDepth        - Integer specifying the ending depth index for plotting.
    plotTitle       - String specifying the title of the plot (optional).
    exportFileName  - String specifying the file name for exporting the plot 
                      as a PDF (optional).

OUTPUTS:
    A figure displaying:
        - Facies classification as an image.
        - Probability distributions for each output variable.
        - Reference and predicted values overlaid on the probability plots.

NOTES:
    - The function uses a colormap loaded from "prob_color_map.mat" for 
      probability visualization.
    - If 'exportFileName' is provided, the plot is saved as a PDF with 
      high resolution.

EXAMPLE USAGE:
    plotResults(targets, outputs, {'Porosity', 'Permeability'}, depth, facies, ...
                {'Shale', 'Water Sand', 'Oil Sand'}, [1, 2], ...
                [0, 1; 0, 1000], {'Depth', 'Facies'}, outputsDomain, ...
                probabilities, 1, 100, 'Rock Physics Results', 'results_plot');

%}
function plotResults(targets, outputs, xlabels, depth, facies, legends, ...
    outputVars, variableRanges, variableNames, outputsDomain, probabilities, initDeth, endDepth, plotTitle, exportFileName)

    f = figure('units','normalized', 'outerposition', [0.1 0.2 0.8 0.6]);
    set(0, 'DefaultAxesFontSize', 16,  'defaultTextInterpreter', 'none');
    tiledlayout('horizontal', 'Padding', 'none', 'TileSpacing', 'tight');
    O = length(probabilities);

    depth = depth(initDeth:endDepth, :);
    facies = facies(initDeth:endDepth, :);

    nexttile;
    colormap(parula);
    imagesc(1, depth, facies);
    xlabel(variableNames{1});
    ylabel('Depth (m)');

    % hold on;
    % for K = 1 : 3; hidden_h(K) = surf(uint8(K-[1 1;1 1]), 'facealpha', 0, 'edgecolor', 'none'); end
    % hold off
    % uistack(hidden_h, 'bottom');

    hold on
    cmap = parula(3); 
    L = line(ones(3),ones(3), 'LineWidth',12);               % generate line 
    set(L,{'color'}, mat2cell(cmap,ones(1,3),3));            % set the colors according to cmap
    legend('Shale', 'Water Sand', 'Oil Sand');       

    % legend(hidden_h, {'Shale', 'Water Sand', 'Oil Sand'} )
    hold off;
    

    prob_color_map = load("prob_color_map.mat").prob_color_map;
    
    for i = 1:O
        ax = nexttile;
        ax.FontSize = 16;
        pcolor(outputsDomain{i}, depth, probabilities{i}(initDeth:endDepth, :));
        hold on; 
        shading interp;
        h = colorbar;
        if i == O
            ylabel(h, 'Probability', 'FontSize', 16);
        end
        yticklabels([]);
        set(ax, 'YDir','reverse');
        xlim(variableRanges(:, outputVars(i)));
        plot(targets(initDeth:endDepth, i), depth, 'k', 'LineWidth', 0.5); 
        plot(outputs(initDeth:endDepth, i), depth, 'r', 'LineWidth', 1);
        xlabel(xlabels{i}, 'FontSize', 16);
        legend({'', 'Reference', 'Prediction'}, 'Location','best');
        colormap(ax, prob_color_map);
        hold off; 
    end

    if ~exist('exportFileName', 'var')
        sgtitle(plotTitle);
    else
        exportgraphics(gcf, sprintf('%s.pdf', exportFileName), 'BackgroundColor', 'none', 'Resolution', 1000)
    end
end

