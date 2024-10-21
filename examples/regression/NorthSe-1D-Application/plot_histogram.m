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
