function sensiAnalysisScatterPlot(sensitivityResultTable, exportFileName)
    sensitivityResultTable(table2array(sensitivityResultTable(:, 8)) > 0.335, :) = [];
    sensitivityResultTable(table2array(sensitivityResultTable(:, 9)) > 0.085, :) = [];
    % sensitivityResultTable(table2array(sensitivityResultTable(:, 2)) < 0.0011, :) = [];
    % sensitivityResultTable(table2array(sensitivityResultTable(:, 1)) > 0.32, :) = [];

    sensitivityResult = table2array(sensitivityResultTable);
    sensitivityResult = sortrows(sensitivityResult, -8);
    sensitivityResult = sensitivityResult(1:end-6000, :);
    
    [~, indexes] = unique(sensitivityResult(:, 8));
    sensitivityResult = sensitivityResult(indexes, :);
    set(0, 'DefaultAxesFontSize', 16, 'defaultTextInterpreter', 'latex');
    fig = figure('units', 'normalized', 'outerposition', ...
        [0.08, 0.025, 0.7, 0.95], 'MenuBar','none', 'ToolBar','none');
    cmap = parula(4);
    colormap(fig, cmap(2:end, :));
    ha = tight_subplot(2, 2, [.075 .095], [0.069 .08],[.08 .12]);
    axes(ha(1));
    scatter3(sensitivityResult(:,1), sensitivityResult(:, 2), ...
        sensitivityResult(:, 8), 7, sensitivityResult(:, end), 'filled');
   
   
    xlabel('\emph{$\tau_{nov}$}', 'Interpreter', 'latex',  'FontSize', 24);  
    ylabel('\emph{$\delta$}', 'Interpreter', 'latex', 'FontSize', 24);  
    zlabel('\emph{RMSE}', 'Interpreter', 'latex', 'FontSize', 24);
    xlim([min(sensitivityResult(:, 1)), max(sensitivityResult(:, 1))])
    ylim([min(sensitivityResult(:, 2)), max(sensitivityResult(:, 2))])
    zlim([min(sensitivityResult(:, 8)), max(sensitivityResult(:, 8))])
    title('\textbf{(a)}', 'FontSize', 24);

    hold on;
    plot3(sensitivityResult(1,1),sensitivityResult(1,2), ...
        sensitivityResult(1,8),'o-', ...
        'MarkerFaceColor','red', 'MarkerEdgeColor','red', 'MarkerSize', 5);
    set(gca, 'SortMethod', 'childorder');
    hold off;
    
    
    axes(ha(2));
    scatter3(sensitivityResult(:,5), sensitivityResult(:,6), ...
        sensitivityResult(:, 8), 7, sensitivityResult(:, end), 'filled');
    
    xlabel('\emph{$sp_{min}$}', 'Interpreter', 'latex',  'FontSize', 24);  
    ylabel('\emph{$v_{min}$}', 'Interpreter', 'latex', 'FontSize', 24);
    xlim([min(sensitivityResult(:, 5)), max(sensitivityResult(:, 5))])
    ylim([min(sensitivityResult(:, 6)), max(sensitivityResult(:, 6))])
    zlim([min(sensitivityResult(:, 8)), max(sensitivityResult(:, 8))])
    title('\textbf{(b)}', 'FontSize', 24);
    

    hold on;
    plot3(sensitivityResult(1,5),sensitivityResult(1,6), ...
        sensitivityResult(1,8),'o-', ...
        'MarkerFaceColor','red','MarkerEdgeColor','red', 'MarkerSize', 5);
    set(gca, 'SortMethod', 'childorder');

    hold off;

    axes(ha(3));
    scatter3(sensitivityResult(:,1), sensitivityResult(:,2), ...
        sensitivityResult(:, 9), 7, sensitivityResult(:, end), 'filled');
    
    xlabel('\emph{$\tau_{nov}$}', 'Interpreter', 'latex',  'FontSize', 24);  
    ylabel('\emph{$\delta$}', 'Interpreter', 'latex', 'FontSize', 24);  
    zlabel('\emph{MAE}', 'Interpreter', 'latex', 'FontSize', 24);
    xlim([min(sensitivityResult(:, 1)), max(sensitivityResult(:, 1))])
    ylim([min(sensitivityResult(:, 2)), max(sensitivityResult(:, 2))])
    zlim([min(sensitivityResult(:, 9)), max(sensitivityResult(:, 9))])
    title('\textbf{(c)}', 'FontSize', 24);

    ha(3).ZAxis.Exponent = -2;

    hold on;
    plot3(sensitivityResult(1,1),sensitivityResult(1,2), ...
        sensitivityResult(1,9),'o-', ...
            'MarkerFaceColor','red','MarkerEdgeColor','red', 'MarkerSize', 5);
    set(gca, 'SortMethod', 'childorder');
    hold off;

    axes(ha(4));
    scatter3(sensitivityResult(:,5), sensitivityResult(:,6), ...
        sensitivityResult(:, 9), 7, sensitivityResult(:, end), 'filled');
   
    xlabel('\emph{$sp_{min}$}', 'Interpreter', 'latex',  'FontSize', 24);  
    ylabel('\emph{$v_{min}$}', 'Interpreter', 'latex', 'FontSize', 24);
    xlim([min(sensitivityResult(:, 5)), max(sensitivityResult(:, 5))])
    ylim([min(sensitivityResult(:, 6)), max(sensitivityResult(:, 6))])
    zlim([min(sensitivityResult(:, 9)), max(sensitivityResult(:, 9))])
    title('\textbf{(d)}', 'FontSize', 24);
    ha(4).ZAxis.Exponent = -2;

    hold on;
    plot3(sensitivityResult(1,5),sensitivityResult(1,6), ...
        sensitivityResult(1, 9),'o-', ...
            'MarkerFaceColor', 'red', 'MarkerEdgeColor','red', 'MarkerSize', 5); 
    set(gca, 'SortMethod', 'childorder');
    hold off;

    h = axes(fig, 'visible','off');
    c = colorbar(h, 'Position',[0.94 0.068 0.02 0.85], ...
        'XTickLabel',{'1','2','3'}, 'XTick', [1.35, 2, 2.65]);
    clim([1 3]);
    ylabel(c,'\emph{\# of Neurons}','FontSize', 24, 'Interpreter', 'latex'); 

    if exist('exportFileName', 'var')
         exportgraphics(fig, sprintf('figs/%s.pdf', exportFileName), ...
             'BackgroundColor', 'none', 'Resolution', 1000)
    end
end

