function fitness = fitnessFunction(y, yPred, N, WS, VS)
%     smfLimits = [0, model.vMin ^ model.spMin];
%     penalty = smf(model.nc, smfLimits);
    y = toTrace(y, N, WS, VS);
    yPred = toTrace(yPred, N, WS, VS);
    fitness = sum(sqrt(mean((y - exp(yPred)) .^ 2))); % + penalty;
end

function trace = toTrace(y, N, WS, VS)
    T = size(y, 1) / VS;
    trace = zeros(N, T);
    chunks = reshape(y, [VS, WS, T]);
    
    for i = 1:T
        ptrace = fliplr(chunks(:, :, i));
        trace(:, i) = arrayfun(@(k) mean(diag(ptrace, k)), WS-1:-1:-VS+1)';
    end
end