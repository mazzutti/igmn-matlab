% callPlotFcns - A function to manage and execute plotting functions during 
% optimization processes.
% 
% This function is designed to handle the initialization and updating of 
% plotting functions provided in the `optimValues.plotFcns` field during 
% optimization. It creates a figure window with subplots for each plotting 
% function and updates the plots as the optimization progresses.
% 
% Inputs:
%     optimValues - A structure containing information about the current 
%                   state of the optimization. It must include the following fields:
%                   - plotFcns: A cell array or single function handle of 
%                     plotting functions to be executed.
%                   - algorithm: A string specifying the name of the optimization 
%                     algorithm.
%     flag        - A string indicating the current stage of the optimization. 
%                   Possible values are:
%                   - 'init': Initialization stage, where the figure and subplots 
%                     are created.
%                   - Other values: Update stage, where the plots are updated.
% 
% Outputs:
%     stop        - A logical value indicating whether the optimization should 
%                   stop. Returns `true` if the figure is closed, otherwise `false`.
% 
% Persistent Variables:
%     Figure      - A handle to the figure window used for plotting.
%     Axes        - An array of subplot axes handles.
% 
% Usage:
%     This function is typically called within an optimization loop to 
%     initialize and update plots dynamically. It supports multiple plotting 
%     functions and arranges them in a grid layout.
% 
% Notes:
%     - The function uses persistent variables to maintain the figure and axes 
%       handles across calls.
%     - If the figure is closed by the user, the function sets `stop` to `true` 
%       to signal the optimization process to terminate.
%     - The subplot layout is determined dynamically based on the number of 
%       plotting functions.
% 
% Example:
%     % Define plotting functions
%     optimValues.plotFcns = {@plotFcn1, @plotFcn2};
%     optimValues.algorithm = 'ExampleAlgorithm';
% 
%     % Call the function during optimization
%     stop = callPlotFcns(optimValues, 'init');
%     while ~stop
%         % Update optimValues as needed
%         stop = callPlotFcns(optimValues, 'update');
%     end
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



