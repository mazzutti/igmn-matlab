%{
PLOT_HISTOGRAM - Plots histograms of a parameter `p` grouped by categories.

This function generates histograms for the values in the input vector `p`,
grouped by the unique integer values in the input vector `cat`. Each unique
category is assigned a distinct color for visualization.

Syntax:
    plot_histogram(p, cat)

Inputs:
    p   - A numeric vector containing the data to be plotted in histograms.
    cat - A numeric vector of the same length as `p`, containing integer
          category labels corresponding to the elements of `p`.

Outputs:
    None. The function generates a plot.

Example:
    % Example usage of plot_histogram
    p = randn(100, 1); % Random data
    cat = randi([1, 3], 100, 1); % Random categories (1, 2, or 3)
    plot_histogram(p, cat);

Notes:
    - The function uses a predefined set of three colors for the histograms.
      If there are more than three unique categories in `cat`, an error may
      occur due to insufficient colors.
    - The histograms are overlaid with transparency for better visualization.

%}
function [] = plot_histogram(p, cat)

% Get unique integer values from cat variable
unique_cat = unique(cat);

% Set up colors for plotting
colors =  {[58/255, 39/255, 161/255], [87/255, 187/255, 183/255], [249/255, 250/255, 85/255]};

% Plot histograms for each unique integer value of cat
hold on;
for i = 1:numel(unique_cat)
    current_cat = unique_cat(i);
    current_p = p(cat == current_cat);  % Filter p values for the current cat
    
    histogram(current_p, 'FaceColor', colors{i},  'FaceAlpha', 0.5);
end
hold off;

% Add title and labels
title('Histograms of p for different cat values');
ylabel('Frequency');

% Add a legend
legend(cellstr(num2str(unique_cat)), 'Location', 'best');
