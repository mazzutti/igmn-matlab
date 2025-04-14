% plot_histogram - Plots histograms of a given data vector `p` grouped by 
% categories specified in `cat`.
% 
% SYNTAX:
%     plot_histogram(p, cat, label)
% 
% INPUTS:
%     p     - A numeric vector containing the data to be plotted.
%     cat   - A numeric vector of the same length as `p` that specifies 
%             the category for each element in `p`. Each unique value in 
%             `cat` represents a different category.
%     label - A string specifying the label for the y-axis of the plot.
% 
% DESCRIPTION:
%     This function generates histograms for the data in `p`, grouped by 
%     the unique integer values in `cat`. Each histogram corresponds to 
%     a unique category in `cat`. The histograms are overlaid on the same 
%     plot with transparency for better visualization. The function also 
%     adds a title, y-axis label, and a legend indicating the categories.
% 
% NOTES:
%     - The function sets default font size and LaTeX interpreter for 
%       axes and text.
%     - The colormap is set to 'jet' for the plot.
% 
% EXAMPLE USAGE:
%     % Example data
%     p = randn(100, 1); % Random data
%     cat = randi([1, 3], 100, 1); % Random categories (1, 2, or 3)
%     label = 'Frequency';
% 
%     % Plot histograms
%     plot_histogram(p, cat, label);
function plot_histogram(p, cat, label)

    set(0, 'DefaultAxesFontSize', 22, 'defaultTextInterpreter','latex');

    % Get unique integer values from cat variable
    unique_cat = unique(cat);


    % Plot histograms for each unique integer value of cat
    hold on;
    for i = 1:numel(unique_cat)
        current_cat = unique_cat(i);
        current_p = p(cat == current_cat);  % Filter p values for the current cat
        
        histogram(current_p, 'FaceAlpha', 0.4);
    end
    hold off;

    % Add title and labels
    title('Histograms of p for different cat values');
    ylabel(label, 'FontWeight','bold');

    % Add a legend
    legend(cellstr(num2str(unique_cat)), 'Location', 'best');
    colormap('jet');
end
