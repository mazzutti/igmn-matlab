function exitFlag = stopOptimization(optOptions, state, bestFvalsWindow) %#codegen
    iteration = state.Iteration;
    iterationIndex = 1 + mod(iteration-1, optOptions.StallIterLimit);
    bestFval = bestFvalsWindow(iterationIndex);
    if optOptions.Verbosity > 1 && ...
            mod(iteration, optOptions.DisplayInterval) == 0 && ...
            iteration > 0
        FunEval = state.FunEval;
        MeanFval = meanf(state.Fvals);
        StallGen = iteration  - state.LastImprovement;
        bestFvalDisplay = bestFval;
        meanFvalDisplay = MeanFval;
        fprintf('%5.0f         %7.0f    %12.4g    %12.4g    %5.0f\n', ...
            iteration, FunEval, bestFvalDisplay, meanFvalDisplay, StallGen);
        pause(0.000001);
    end
    
    % Compute change in fval and individuals in last 'Window' iterations
    Window = optOptions.StallIterLimit;
    if iteration > Window
        % The smallest fval in the window should be bestFval.
        % The largest fval in the window should be the oldest one in the
        % window. This value is at iterationIndex+1 (or 1).
        if iterationIndex == Window
            % The window runs from index 1:iterationIndex
            maxBestFvalsWindow = bestFvalsWindow(1);
        else
            % The window runs from [iterationIndex+1:end, 1:iterationIndex]
            maxBestFvalsWindow = bestFvalsWindow(iterationIndex + 1);
        end
        funChange = abs(maxBestFvalsWindow - bestFval) / max(1, abs(bestFval));
    else
        funChange = Inf;
    end
    
    reasonToStop = '';
    exitFlag = [];
    if state.Iteration >= optOptions.MaxIter
        reasonToStop = 'number of iterations exceeded OPTIONS.MaxIter';
        exitFlag = 0;
    elseif state.FunEval >= optOptions.MaxFunEval
        reasonToStop = 'number of function evaluations exceeded OPTIONS.MaxFunEval';
        exitFlag = -6;
    elseif toc(state.StartTime) > optOptions.MaxTime
        reasonToStop = 'time limit exceeded OPTIONS.MaxTime';
        exitFlag = -5;
    elseif (toc(state.StartTime) - state.LastImprovementTime) > optOptions.StallTimeLimit
        reasonToStop = 'stall time limit exceeded OPTIONS.StallTimeLimit';
        exitFlag = -4;
    elseif bestFval <= optOptions.ObjectiveLimit
        reasonToStop = 'objective limit reached OPTIONS.ObjectiveLimit';
        exitFlag = -3;
    elseif state.StopFlag
        reasonToStop = 'plotting window closed OPTIONS.PlotFcns';
        exitFlag = -1; 
    elseif funChange <= optOptions.TolFunValue
        reasonToStop = ['relative change in the objective value over ' ...
            'the last OPTIONS.StallIterLimit iterations is less than OPTIONS.TolFunValue'];
        exitFlag = 1;
    end
    
    if ~isempty(reasonToStop) && optOptions.Verbosity > 0
        fprintf('Optimization ended: %s\n', reasonToStop);
        return
    end
    
    % Print header again
    if optOptions.Verbosity > 1 && rem(iteration, 30 * optOptions.DisplayInterval) == 0 && iteration > 0
        fprintf('\n                                 Best            Mean    Stall\n');
        fprintf('Iteration     f-count            f(x)            f(x)    Iterations\n');
    end
end
