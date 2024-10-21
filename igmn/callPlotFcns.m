function stop = callPlotFcns(optimValues, flag)
    
    persistent Figure
    persistent Axes

    set(0, 'DefaultAxesFontSize', 10);
    
    N = length(optimValues.plotFcns);

    algorithm = optimValues.algorithm;

    if strcmpi(flag, 'init')
        Figure = figure(...
            'NumberTitle', 'off', ...
            'Name', sprintf('IGMN %s Optimization', algorithm), ...
            'NextPlot', 'replacechildren');
        pos = zeros(1, 4);
        pos(:) = get(Figure, 'Position');
        pos(1) = pos(1) - pos(3)/2;
        pos(3) = pos(3) * N;
        set(Figure, 'Position', pos);
        Axes = zeros(N);
    end
    stop = false;
    
    if ~isempty(Figure)  && ishandle(Figure)
        set(0, 'CurrentFigure', Figure);
        
        % Find a good size for subplot array
        rows = floor(sqrt(N));
        cols = ceil(N / rows);

        % Cycle through plotting functions
        for i = 1:N
            if strcmpi(flag, 'init') 
                index = subplot(rows, cols, i, 'Parent', Figure);
                Axes(i) = index;
                set(gca, 'NextPlot', 'replacechildren')
            else
                subplot(Axes(i))
            end % if strcmpi
            if iscell(optimValues.plotFcns)
                feval(optimValues.plotFcns{i}, optimValues, flag);
            else
                feval(optimValues.plotFcns, optimValues, flag);
            end
        end % for i 
    else
        stop = true;
        Figure = [];
        Axes = [];
    end
    drawnow;
end



