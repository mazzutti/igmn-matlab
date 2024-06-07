function [trainData, testData, allData, timeSeis, traceSizes, targets] = ...
    prepareData(genSynthData, plotData, theta, trainTraces, testTraces, initDeth, waveSize, selectedOutVar, variableNames)
   
    VpTraces = read_segy_file('data/model/MODEL_P-WAVE_VELOCITY_1.25m.segy').traces(initDeth:end, :) ./ 1000;
    VsTraces = read_segy_file('data/model/MODEL_S-WAVE_VELOCITY_1.25m.segy').traces(initDeth:end, :) ./ 1000;
    RhoTraces = read_segy_file('data/model/MODEL_DENSITY_1.25m.segy').traces(initDeth:end , :);
    
    % VpTraces = VpTraces(1:4:end, 1:5:end);
    % VsTraces = VsTraces(1:4:end, 1:5:end);
    % RhoTraces = RhoTraces(1:4:end, 1:5:end);
    
    allTheta = 15:3:45;
    if genSynthData
        [allData, timeSeis, traceSizes] = genSyntheticData(VpTraces, VsTraces, RhoTraces, initDeth, allTheta);
    else
        structData = load(sprintf('data/processedSynthAI.mat'));
        allData = structData.allData;
        timeSeis = cat(1, structData.timeSeis{:});
        traceSizes = structData.traceSizes;
    end
   
    if plotData
        T = numel(allTheta);
        thetaIndexes = arrayfun(@(x) find(allTheta == x), theta);
        for i = 1:length(variableNames)
            varName = variableNames{i};
            if i <= T && any(thetaIndexes == i)
                data = squeeze(allData(:, :, thetaIndexes == i));
                figure('Name', sprintf('Variable: theta%s', string(varName)));
                s_plot(data);
            elseif i > T
                data = squeeze(allData(:, :, i));
                figure('Name', sprintf('Variable: %s', string(varName)));
                imagesc(data);
            end 
        end
    end
    [trainData, testData, targets] = genBaggingData(allData, traceSizes, ...
        theta, trainTraces, testTraces, waveSize, selectedOutVar, variableNames);
end

function [trainData, testData, targets] = genBaggingData(data, traceSizes, ...
        theta, trainTraces, testTraces, waveSize, selectedOutVar, variableNames)
    allTheta = 15:3:45;
    lowIndex = find(contains(variableNames, sprintf('low%s', selectedOutVar)));
    varIndexes = [arrayfun(@(x) find(allTheta == x), theta), lowIndex];

    ends = cumsum(traceSizes(trainTraces) - waveSize + 1);
    starts = ends - (traceSizes(trainTraces) - waveSize + 1) + 1;

    T = numel(varIndexes) * waveSize;
    varIndex = find(matches(variableNames, selectedOutVar));

    trainData = zeros(sum(ends - starts), T + waveSize);
    for i = 1:numel(trainTraces)
        trace = trainTraces(i);
        endIndex = traceSizes(trace) - waveSize + 1;
        for k = 1:endIndex
            indexes = k:(k + waveSize - 1);
            inputData = reshape(data(indexes, trace, varIndexes), 1, []);
            % rockTypeAndFluid = squeeze(data(k, trace, [12, 13]))';
            trainData(k + starts(i) - 1, :) = [inputData, squeeze(data(indexes, trace, varIndex))'];
        end
    end

    ends = cumsum(traceSizes(testTraces) - waveSize + 1);
    starts = ends - (traceSizes(testTraces) - waveSize + 1) + 1;

    targets = [];
    testData = zeros(sum(ends - starts), T + waveSize);
    for i = 1:numel(testTraces)
        trace = testTraces(i);
        endIndex = traceSizes(trace) - waveSize + 1;
        targets = [targets ; data(1:traceSizes(trace), trace, varIndex)]; %#ok<AGROW>
        for k = 1:endIndex
            indexes = k:(k + waveSize - 1);
            % rockTypeAndFluid = squeeze(data(k, trace, [12, 13]))';
            inputData = reshape(data(indexes, trace, varIndexes), 1, []);
            testData(k + starts(i) - 1, :) = [inputData, squeeze(data(indexes, trace, varIndex))'];
        end
    end
    % T = numel(theta) * waveSize;
    trainData = trainData(randperm(size(trainData, 1)), :);
    % trainData(:, 1:T) = gaussianize(trainData(:, 1:T));
    % testData(:, 1:T) = gaussianize(testData(:, 1:T));
end

function [allData, timeSeis, traceSizes] = genSyntheticData(VpTraces, VsTraces, RhoTraces, initDeth, theta)
    frequencies = 45:45;
    F = length(frequencies);

    S = size(VpTraces, 2);
    T = numel(theta);

    ntw = 64;
    dt = 0.004;
    t0 = zeros(1, S);
    t0(:) = dt * initDeth;
    % TimeLog = [t0; t0 + 2 * cumsum(0.005 ./ (VpTraces(2:end, :)), 1)];
    TimeLog = [t0; t0 + 2 * cumsum(0.00125 ./ (VpTraces(2:end, :)), 1)];
    TL = size(TimeLog, 2);
    Times = cell(1, TL);
    timeSeis = cell(1, TL);
    traceSizes = zeros(1, TL);
    for i = 1:size(TimeLog, 2)
        Time = (TimeLog(1, i):dt:TimeLog(end, i))';
        timeSeis{i} = 1/2*(Time(1:end-1)+Time(2:end));
        Times{i} = Time;
        traceSizes(i) = length(Time) - 1;
    end

    traceSize = max(traceSizes, [], 'all');
    data = zeros(traceSize, S, T + 6);
    PB = ProgressBar(F * S, 'Generating Synthetic Data', 'cli');
    % if ~isfile('genSyntheticDataFor_mex.mexw64')
    %     codegen -v genSyntheticDataFor -args {theta, traceSize, Times, VpTraces, VsTraces, RhoTraces, TimeLog, zeros(ntw, 1), PB};
    %     codegen -v extractRockTypeAndFluid -args {rockTypeAndFluidData, data(:, :, T + 1:T + 3)}
    % end
    % lowFreq = 0.04;
    % highFreq = 0.4;
    % nfilt = 3;
    % [lb, la] = butter(nfilt, lowFreq, 'low');
    % [hb, ha] = butter(nfilt, highFreq, 'low');
    % lowFreqFilter = @(x) filtfilt(lb, la, x);
    % highFreqFilter = @(x) x - filtfilt(hb, ha, x);

    NCoef = 110;
    Ts = 4;
    lowFreqFilter = @(x) lowPassFilter(x, Ts, NCoef, 8); % 6 a 8
    % highFreqFilter = @(x) highPassFilter(x, Ts, NCoef, 60); % 50 a 60

    for f = 1:F
        %% Wavelet
        wavelet = RickerWavelet(frequencies(f), dt, ntw);
        data = data + genSyntheticDataFor(theta, traceSize, ...
            Times, VpTraces, VsTraces, RhoTraces, TimeLog, wavelet, lowFreqFilter, PB);
    end

    tempData = data ./ F;

    allData = cat(3, cat(3, tempData(:, :, 1:T), tempData(:, :, T+1) ...
        .* tempData(:, :, T+3)), tempData(:, :, end-2) .* tempData(:, :, end));

    % if ~isfile('extractRockTypeAndFluid_mex.mexw64')
    %     codegen extractRockTypeAndFluid -args {rockTypeAndFluidData, data(:, :, T + 1:T + 3)}
    % end
    % 
    % rockTypeAndFluid = extractRockTypeAndFluid(rockTypeAndFluidData, data(:, :, T + 1:T + 3));
    % allData = zeros(traceSize, S, T + 5);
    % allData(:, :, 1:T) = data(:, :, 1:T);
    % allData(:, :, T+1:T+2) = rockTypeAndFluid;
    % allData(:, :, T+3:end) = data(:, :, T+1:end);
    
    save('data/processedSynthAI.mat', 'allData' , 'timeSeis', 'traceSizes');
end

function data = genSyntheticDataFor(theta, traceSize, Times, ...
    VpTraces, VsTraces, RhoTraces, TimeLog, wavelet, lowFreqFilter,  PB)
    T = size(VpTraces, 2);
    data = nan(traceSize, T, numel(theta) + 6);
    
    parfor i = 1:T
        Time = Times{i};
        Vp =  VpTraces(:, i);
        Vs = VsTraces(:, i);
        Rho = RhoTraces(:, i);
        timeLog = TimeLog(:, i);
        data(:, i, :) = genSyntheticTrace(theta, ...
            traceSize, Time, timeLog, Vp, Vs, Rho, wavelet, lowFreqFilter);
        pause(0.0001*rand);
        count(PB);
    end
end
