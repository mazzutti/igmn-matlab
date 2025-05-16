% plotResults - Visualizes regression results and probabilities for rock physics data.
% 
% This function generates a tiled plot layout to display the regression 
% results, including facies classification, probability distributions, 
% and comparisons between reference and predicted outputs.
% 
% SYNTAX:
%     plotResults(targets, outputs, xlabels, depth, facies, legends, ...
%                 outputVars, variableRanges, variableNames, outputsDomain, ...
%                 probabilities, initDeth, endDepth, plotTitle, exportFileName)
% 
% INPUTS:
%     targets         - Matrix of reference target values (depth x variables).
%     outputs         - Matrix of predicted output values (depth x variables).
%     xlabels         - Cell array of strings for x-axis labels of each variable.
%     depth           - Vector of depth values (depth x 1).
%     facies          - Vector of facies classification values (depth x 1).
%     legends         - Cell array of legend labels for the plots.
%     outputVars      - Vector of indices specifying which variables to plot.
%     variableRanges  - Matrix specifying the range of each variable (2 x variables).
%     variableNames   - Cell array of variable names for labeling.
%     outputsDomain   - Cell array of domain values for each output variable.
%     probabilities   - Cell array of probability matrices (depth x domain).
%     initDeth        - Integer specifying the starting depth index for plotting.
%     endDepth        - Integer specifying the ending depth index for plotting.
%     plotTitle       - String specifying the title of the plot (optional).
%     exportFileName  - String specifying the file name for exporting the plot 
%                       as a PDF (optional).
% 
% OUTPUTS:
%     A figure displaying:
%         - Facies classification as an image.
%         - Probability distributions for each output variable.
%         - Reference and predicted values overlaid on the probability plots.
% 
% NOTES:
%     - The function uses a colormap loaded from "prob_color_map.mat" for 
%       probability visualization.
%     - If 'exportFileName' is provided, the plot is saved as a PDF with 
%       high resolution.
% 
% EXAMPLE USAGE:
%     plotResults(targets, outputs, {'Porosity', 'Permeability'}, depth, facies, ...
%                 {'Shale', 'Water Sand', 'Oil Sand'}, [1, 2], ...
%                 [0, 1; 0, 1000], {'Depth', 'Facies'}, outputsDomain, ...
%                 probabilities, 1, 100, 'Rock Physics Results', 'results_plot');
% 
function plotKDEInversionResults(targets, inputs, outputs, useFacies, depth, facies, legends, ...
         variableRanges, variableNames, outputsDomain, probabilities, plotTitle, exportFileName)

    % f = figure('units','normalized', 'outerposition', [0.1 0.2 0.8 0.6]);
    % set(0, 'DefaultAxesFontSize', 16,  'defaultTextInterpreter', 'none');
    % tiledlayout('horizontal', 'Padding', 'none', 'TileSpacing', 'tight');
    % O = length(probabilities);
    % 
    % depth = depth(initDeth:endDepth, :);
    % facies = facies(initDeth:endDepth, :);
    % 
    % nexttile;
    % colormap(parula);
    % imagesc(1, depth, facies);
    % xlabel(variableNames{1});
    % ylabel('Depth (m)');
    % 
    % % hold on;
    % % for K = 1 : 3; hidden_h(K) = surf(uint8(K-[1 1;1 1]), 'facealpha', 0, 'edgecolor', 'none'); end
    % % hold off
    % % uistack(hidden_h, 'bottom');
    % 
    % hold on
    % cmap = parula(3); 
    % L = line(ones(3),ones(3), 'LineWidth',12);               % generate line 
    % set(L,{'color'}, mat2cell(cmap,ones(1,3),3));            % set the colors according to cmap
    % legend('Shale', 'Water Sand', 'Oil Sand');       
    % 
    % % legend(hidden_h, {'Shale', 'Water Sand', 'Oil Sand'} )
    % hold off;
    % 
    % 
    % prob_color_map = load("prob_color_map.mat").prob_color_map;
    % 
    % for i = 1:O
    %     ax = nexttile;
    %     ax.FontSize = 16;
    %     pcolor(outputsDomain{i}, depth, probabilities{i}(initDeth:endDepth, :));
    %     hold on; 
    %     shading interp;
    %     h = colorbar;
    %     if i == O
    %         ylabel(h, 'Probability', 'FontSize', 16);
    %     end
    %     yticklabels([]);
    %     set(ax, 'YDir','reverse');
    %     xlim(variableRanges(:, outputVars(i)));
    %     plot(targets(initDeth:endDepth, i), depth, 'k', 'LineWidth', 0.5); 
    %     plot(outputs(initDeth:endDepth, i), depth, 'r', 'LineWidth', 1);
    %     xlabel(xlabels{i}, 'FontSize', 16);
    %     legend({'', 'Reference', 'Prediction'}, 'Location','best');
    %     colormap(ax, prob_color_map);
    %     hold off; 
    % end
    % 
    % if ~exist('exportFileName', 'var')
    %     sgtitle(plotTitle);
    % else
    %     exportgraphics(gcf, sprintf('%s.pdf', exportFileName), 'BackgroundColor', 'none', 'Resolution', 1000)
    % end

    titles = {'(a)', '(b)', '(c)', '(d)', '(e)', '(f)'};
    O = size(outputs, 2);
    I = size(inputs, 2);
   
    prob_color_map = load("prob_color_map.mat").prob_color_map;
   
    f = figure('units','normalized', 'outerposition', [0.02 0.02 0.96 0.96]);
    set(0, 'DefaultAxesFontSize', 22,  'defaultTextInterpreter', 'latex');

    ha = tight_subplot(1, 6, [.01 .015], [0.01 .04], [.064 .036]);

    for ii = 1:2
        limits = [0.3, 0.3, 0.15];
        for i = 1:O
            ax = ha((ii -1) * O + i);
            axes(ax); %#ok<LAXES>
            probs = probabilities{i};
            pcolor(ax, outputsDomain{i}, depth, probs);
            hold('on');
            shading interp;
            h = colorbar;
            clim([0 limits(i)])
            if (i + ii) == 5
                ylabel(h, '\boldmath{$Probability$}', 'FontSize', 22, 'Interpreter', 'latex');
            end
            if i + (ii - 1) == 1
                ylabel('\boldmath{$Depth$} \boldmath{$(m)$}', 'FontSize', 22, 'Interpreter', 'latex');
                 ax.YAxis.Exponent = 3;
            end
            set(ax, 'YDir','reverse');
            xlim(variableRanges(:, i));
            xticks(variableRanges(1, i):(variableRanges(2, i) - variableRanges(1, i))/2:variableRanges(2, i));
            plot(targets(:, i), depth, 'k', 'LineWidth', 2); 
            plot(outputs(:, i), depth, 'r', 'LineWidth', 2);
            xlabel(variableNames{ i + I}, 'FontWeight', 'bold', 'FontSize', 22);
            if i + (ii - 1) ~= 1
                set(ax, 'Yticklabel', []);
            end
            legend({'', 'Reference', 'Prediction'}, 'Location', 'southoutside', 'FontSize', 22);
            tt = title(titles{i + (ii - 1) * 3}, 'FontSize', 22, 'FontWeight', 'bold', 'Interpreter', 'none');
            tt.Position(2) = tt.Position(2) - 0.6;
            colormap(ax, prob_color_map);
            grid;
            hold('off');
        end
    end

    if exist('exportFileName', 'var')
        exportgraphics(f, sprintf('%s.pdf', exportFileName), 'BackgroundColor', 'none', 'Resolution', 1000)
    else
        sgtitle(plotTitle);
    end

    % means = net.means;
    % covs = pageinv(net.invCovs);
    % gm = gmdistribution(net.means, covs, net.priors);
    % logs = random(gm, 3000);
    % if useFacies
    %     logs = logs(:, 2:end); 
    %     means = means(:, 2:end);
    %     covs = covs(2:end, 2:end, :);
    % end

    % variableRanges = [3040, 1630, 2, 0, 0, 0 ; 4880, 3125, 2.6, 0.4, 0.8, 1];
    % variableNames = {'\boldmath{$\alpha$}', ...
    %     '\boldmath{$\beta$}', '\boldmath{$\rho$}', ...
    %     '\boldmath{$\phi$}', '\boldmath{$V_c$}', ...
    %     '\boldmath{$S_w$}'};
    % f = generate_histograms(logs, variableNames, [0, 8], variableRanges, means, covs, net.priors);
    % sgtitle(f, '(b)', 'FontWeight', 'bold', 'FontSize', 22,  'Interpreter', 'none');
    % 
    % if exist('exportFileName', 'var')
    %      exportgraphics(f, 'figs/kde_histogram.pdf', 'BackgroundColor', 'none', 'Resolution', 1000)
    % end

    % regressionEntries = cell(1, 3 * O);
    % for i = 1:O
    %     index = (i - 1) * O + 1; 
    %     regressionEntries{index} = targets(:, i);
    %     regressionEntries{index + 1} = outputs(:, i);
    %     regressionEntries{index + 2} = sprintf('%s Prediction', legends{i}{1});
    % end
    % legendNames = horzcat(legends{:});
    % f = figure('Name', sprintf('%Regressions: s x %s | %s x %s | %s x %s', legendNames{:}));
    % plotregression(regressionEntries{:});
    % f.Children(3).Children(1).Marker = '.';
    % f.Children(5).Children(1).Marker = '.';
    % f.Children(7).Children(1).Marker = '.';
end

