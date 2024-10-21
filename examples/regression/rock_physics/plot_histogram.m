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
