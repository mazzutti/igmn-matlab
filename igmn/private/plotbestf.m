function plotbestf(optimValues,flag)
    % Plots the best, mean, and worst scores of individuals.

    if strcmp(flag,'init')
        set(gca,'NextPlot', 'add',...
            'XLabel', xlabel('Iteration'),...
            'YLabel', ylabel('Fvals'));
        line(optimValues.iteration, mean(optimValues.meanfval),...
            'Color', 'blue',...
            'Tag', 'Mean Fvals',...
            'Marker', '.',...
            'LineStyle', 'none');
        line(optimValues.iteration, optimValues.bestfval,...
            'Color', 'black',...
            'Tag', 'Best Fvals',...
            'Marker', '.',...
            'LineStyle', 'none');
        legend({'Mean Fval','Best Fval'});
    elseif strcmp(flag, 'iter')
        hmean = findobj(gca, 'Tag', 'Mean Fvals', 'Type', 'line');
        hbest = findobj(gca, 'Tag', 'Best Fvals', 'Type', 'line');
        x = [get(hmean,'XData'), optimValues.iteration];
        ymean = [get(hmean,'YData'), optimValues.meanfval];
        ybest = [get(hbest,'YData'), optimValues.bestfval];
        set(hmean,...
            'XData', x,...
            'YData', ymean);
        set(hbest,...
            'XData', x,...
            'YData', ybest);
        titletxt = sprintf('Best: %g Mean: %g', ybest(end), ymean(end));
        title(titletxt);
    end
end