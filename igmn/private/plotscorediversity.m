% plotscorediversity Plots a histogram of the best and mean scores of individuals.
%
%   plotscorediversity(optimValues, flag) generates a histogram to visualize
%   the diversity of scores in the population during an optimization process.
%
%   Inputs:
%       optimValues - A structure containing information about the current
%                     state of the optimization. The field 'populationfvals'
%                     is expected to contain the fitness values of the population.
%       flag        - A string indicating the current state of the optimization.
%                     If flag is 'init', the function initializes the plot.
%
%   Behavior:
%       - When flag is 'init', the function sets up the axes properties for
%         the histogram plot.
%       - During subsequent calls, the function plots a histogram of the
%         fitness values in optimValues.populationfvals.
%
%   Notes:
%       - The histogram uses the 'hist' function to compute the bin counts
%         and bin edges.
%       - The histogram bars are displayed with a specific color ([0.1 0.1 0.5]).
%
%   Example:
%       % Assuming optimValues.populationfvals contains fitness values:
%       plotscorediversity(optimValues, 'init');
%       plotscorediversity(optimValues, 'iter');
%
%   See also: bar, hist
function plotscorediversity(optimValues,flag)
    if strcmp(flag,'init')
        set(gca,'NextPlot','replacechildren',...
            'XLabel',xlabel('Fvals'),...
            'YLabel',ylabel('Number of inidividuals'))
    end
    
    [n, bins] = hist(optimValues.populationfvals); %#ok<HIST>
    bar(bins, n, 'Tag', 'scorehistogram', 'FaceColor', [0.1 0.1 0.5])
end
