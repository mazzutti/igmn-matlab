function plotscorediversity(optimValues,flag)
    % Plots a histogram containing the best and mean scores of individuals.
    if strcmp(flag,'init')
        set(gca,'NextPlot','replacechildren',...
            'XLabel',xlabel('Fvals'),...
            'YLabel',ylabel('Number of inidividuals'))
    end
    
    [n, bins] = hist(optimValues.populationfvals); %#ok<HIST>
    bar(bins, n, 'Tag', 'scorehistogram', 'FaceColor', [0.1 0.1 0.5])
end
