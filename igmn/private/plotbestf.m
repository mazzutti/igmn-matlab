% plotbestf - Plots the best, mean, and worst scores of individuals during optimization.
%
% Syntax:
%   plotbestf(optimValues, flag)
%
% Description:
%   This function is used as a custom plot function for optimization routines.
%   It visualizes the progression of the best and mean fitness values over
%   iterations. The function is typically called by an optimization solver
%   and updates the plot dynamically.
%
% Inputs:
%   optimValues - A structure containing information about the current state
%                 of the optimization. Relevant fields include:
%                 - iteration: The current iteration number.
%                 - meanfval: The mean fitness value of the population.
%                 - bestfval: The best fitness value in the population.
%   flag        - A string indicating the current stage of the optimization.
%                 Possible values:
%                 - 'init': Called at the start of the optimization to
%                           initialize the plot.
%                 - 'iter': Called at each iteration to update the plot.
%
% Behavior:
%   - During the 'init' stage, the function initializes the plot with labels,
%     legends, and placeholders for the mean and best fitness values.
%   - During the 'iter' stage, the function updates the plot with the latest
%     mean and best fitness values and updates the title to display the
%     current best and mean values.
%
% Notes:
%   - This function is intended to be used as a custom plot function in
%     optimization routines such as those provided by MATLAB's Global
%     Optimization Toolbox.
%   - Ensure that the figure and axes are properly set up before calling
%     this function.
function plotbestf(optimValues,flag)
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
