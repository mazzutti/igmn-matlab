% FANCYCORRPLOT Generates a fancy correlation plot with labeled scatter points.
%
%   fancyCorrPlot(R, labels) creates a scatter plot visualizing the 
%   correlation matrix R with annotations and labels. The plot includes 
%   a color-coded representation of the correlation values, grid lines, 
%   and axis labels.
%
%   Inputs:
%       R      - A square matrix representing the correlation coefficients.
%       labels - A cell array of strings containing the labels for the 
%                rows and columns of the correlation matrix.
%
%   Features:
%       - Displays the correlation values as scatter points with sizes 
%         proportional to the absolute value of the correlation coefficients.
%       - Annotates each scatter point with the corresponding correlation value.
%       - Includes grid lines to enclose the scatter points.
%       - Adds axis labels and a colorbar to indicate the p-values.
%       - Customizes the appearance of the plot, including font size, 
%         colors, and layout.
%       - Exports the plot as a high-resolution PDF file.
%
%   Example:
%       R = [1, 0.8, 0.5; 0.8, 1, 0.3; 0.5, 0.3, 1];
%       labels = {'Var1', 'Var2', 'Var3'};
%       fancyCorrPlot(R, labels);
%
%   Notes:
%       - The function uses the 'parula' colormap by default.
%       - The exported PDF file is named "vartestn.pdf".
%       - The function assumes that the input matrix R is square and 
%         symmetric.
function fancyCorrPlot(R, labels)
    f = figure('units','normalized', 'outerposition', [0.1 0.1 0.9 0.9]);
    set(0, 'DefaultAxesFontSize', 22,  'defaultTextInterpreter', 'latex');
    set(f, 'color', [254/255, 251/255, 243/255]);
    % for i = 1:size(R, 1)
    %     R(i, i) = 1;
    % end
    % scatter plot
    n = size(R, 1);
    y = triu(repmat(n+1, n, n) - (1:n)') + 0.5;
    x = triu(repmat(1:n, n, 1)) + 0.5;
    x(x == 0.5) = NaN;
    scatter(x(:), y(:), 6400.*abs(R(:)), R(:), 'filled');
    label = cellstr(num2str(round(R(:), 2)));
    % dx = 0.1; dy = 0.1; % displacement so the text does not overlay the data points
    text(x(:), y(:), label, 'HorizontalAlignment', 'center', 'FontSize', 22);
    % enclose markers in a grid
    xl = [1:n+1;repmat(n+1, 1, n+1)];
    xl = [xl(:, 1), xl(:, 1:end-1)];
    yl = repmat(n+1:-1:1, 2, 1);
    line(xl, yl, 'color', 'k') % horizontal lines
    line(yl, xl, 'color', 'k') % vertical lines
    % show labels
    text(n-1, n+1.3, 'Seismic Noise Ratio', 'HorizontalAlignment', 'center', 'FontSize', 22);
    text(n/2+0.4, n/2+0.4, 'Seismic Noise Ratio', 'HorizontalAlignment', 'center', 'Rotation', 315, 'FontSize', 22);
    text((1:n) - 0.05, (n:-1:1) + 0.5, labels, 'HorizontalAlignment', 'right', 'FontSize', 22);
    text((1:n) + 0.5, repmat(n + 1, n, 1), labels, ...
        'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center', 'FontSize', 22)
    h = gca;
    cb = colorbar(h);
    cb.Position(1) = cb.Position(1) - 0.11;
    cb.Position(3) = cb.Position(3) + 0.02;
    % ylim(cb, [0.9 1]);
    ylim(h, [0.9 1]);
    ylabel(cb, '$p$-value', 'FontSize', 22,  'Interpreter', 'latex');
    % cb.Position(2) = cb.Position(2)*0.9;
    h.Visible = 'off';
    % h.Position(4) = h.Position(4)*0.8;
    axis(h, 'equal');
    % colormap(load('corr_colormap.mat').cmap);
    colormap(parula);
    h.XAxis.Label.Visible='on';
    h.YAxis.Label.Visible='on';
    h.YAxis.Label.Position(1) = h.YAxis.Label.Position(1)+1.25;
    h.XAxis.Label.Position(2) = h.XAxis.Label.Position(2)+0.2;
    xlabel("ANN with Bagging", 'Color', 'k');
    ylabel("ESMDA", 'Color', 'k');

    exportgraphics(f, "vartestn.pdf", 'BackgroundColor', [254/255 252/255 246/255], 'Resolution', 300)
end

