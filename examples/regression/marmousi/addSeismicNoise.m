function noiseData = addSeismicNoise(data, theta, noise, ...
        waveSize, traces, traceSizes, starts, noiseMultiplier)
    noiseData = data;
    seismicInputVars = 1:numel(theta) * waveSize;
    for i = 1:numel(traces)
        trace = traces(i);
        endIndex = traceSizes(trace) - waveSize + 1;
        % noise = circshift(noise, randi(size(noise, 1)));
        for k = 1:endIndex
            inputData = noiseData(k + starts(i) - 1, seismicInputVars);
            noiseRow = noiseMultiplier .* noise.traces(k + starts(i) - 1, seismicInputVars);
            noiseData(k + starts(i) - 1, seismicInputVars) = inputData + noiseRow;
        end
    end
end