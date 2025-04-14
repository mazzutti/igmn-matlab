% stopOptimization - Determines whether to stop the optimization process based on various criteria.
%
% Syntax:
%   exitFlag = stopOptimization(optOptions, state, bestFvalsWindow)
%
% Inputs:
%   optOptions      - Structure containing optimization options:
%                     - MaxIter: Maximum number of iterations.
%                     - MaxFunEval: Maximum number of function evaluations.
%                     - MaxTime: Maximum allowed time for optimization.
%                     - StallTimeLimit: Maximum allowed stall time.
%                     - ObjectiveLimit: Objective function value limit.
%                     - StallIterLimit: Number of iterations to check for stagnation.
%                     - TolFunValue: Tolerance for relative change in objective value.
%                     - Verbosity: Level of verbosity for displaying progress.
%                     - DisplayInterval: Interval for displaying progress.
%   state           - Structure containing the current state of the optimization:
%                     - Iteration: Current iteration number.
%                     - FunEval: Number of function evaluations.
%                     - Fvals: Array of function values.
%                     - LastImprovement: Iteration of the last improvement.
%                     - LastImprovementTime: Time of the last improvement.
%                     - StartTime: Start time of the optimization.
%                     - StopFlag: Flag indicating if the optimization should stop.
%   bestFvalsWindow - Array containing the best function values over a sliding window.
%
% Outputs:
%   exitFlag - Integer flag indicating the reason for stopping:
%              0  - Maximum number of iterations exceeded.
%              -6 - Maximum number of function evaluations exceeded.
%              -5 - Time limit exceeded.
%              -4 - Stall time limit exceeded.
%              -3 - Objective function value limit reached.
%              -1 - Plotting window closed.
%              1  - Relative change in objective value is below tolerance.
%
% Description:
%   This function evaluates various stopping criteria for an optimization
%   process. It checks for conditions such as exceeding maximum iterations,
%   function evaluations, or time limits, as well as stagnation in the
%   objective function value. If a stopping condition is met, the function
%   returns an appropriate exit flag and optionally displays a message
%   depending on the verbosity level.
%
% Notes:
%   - The function assumes that the optimization process is iterative and
%     maintains a sliding window of the best function values for stagnation
%     detection.
%   - The function also handles optional display of progress information
%     based on the verbosity level and display interval.
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
