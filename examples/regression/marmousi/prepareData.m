function [trainData, testData, allData, traceSizes, ... 
    targets, noisyTestData] = prepareData(genSynthData, ...
    trainTraces, testTraces, initDeth, waveSize, noiseMultipliers, plotData)
    
    allTheta = 15:15:45;
    if genSynthData
        VpTraces = read_segy_file('data/model/MODEL_P-WAVE_VELOCITY_1.25m.segy').traces(initDeth:end, :) ./ 1000;
        VsTraces = read_segy_file('data/model/MODEL_S-WAVE_VELOCITY_1.25m.segy').traces(initDeth:end, :) ./ 1000;
        RhoTraces = read_segy_file('data/model/MODEL_DENSITY_1.25m.segy').traces(initDeth:end , :);
        [allData, traceSizes] = genSyntheticData(VpTraces, VsTraces, RhoTraces, initDeth, allTheta);
    else
        structData = load(sprintf('data/processedSynthFreq45.mat'));
        allData = structData.allData;
        traceSizes = structData.traceSizes;
    end
   
    % if plotData
    %     T = numel(allTheta);
    %     thetaIndexes = arrayfun(@(x) find(allTheta == x), theta);
    %     for i = 1:length(variableNames)
    %         varName = variableNames{i};
    %         if i <= T && any(thetaIndexes == i)
    %             data = squeeze(allData(:, :, thetaIndexes == i));
    %             figure('Name', sprintf('Variable: theta%s', string(varName)));
    %             s_plot(data);
    %         elseif i > T
    %             data = squeeze(allData(:, :, i));
    %             figure('Name', sprintf('Variable: %s', string(varName)));
    %             imagesc(data);
    %         end 
    %     end
    % end
    [trainData, testData, targets, noisyTestData] = genBaggingData( ...
        allData, traceSizes, trainTraces, testTraces, waveSize,  noiseMultipliers);
end

function [trainData, testData, targets, noisyTestData] = genBaggingData( ...
    allData, traceSizes, trainTraces, testTraces, waveSize, noiseMultipliers)
    
    allTheta = 15:15:45;
    T = numel(allTheta);
    I = (T + 1) * waveSize;

    ends = cumsum(traceSizes(trainTraces) - waveSize + 1);
    starts = ends - (traceSizes(trainTraces) - waveSize + 1) + 1;

    trainData = zeros(sum(ends - starts), I + waveSize);
    for i = 1:numel(trainTraces)
        trace = trainTraces(i);
        endIndex = traceSizes(trace) - waveSize + 1;
        data = squeeze(allData(:, trace, :));
        data = [data(:, 1:T), data(:, T+1) .* data(:, T+3), data(:, T+4) .* data(:, T+6)];
        for k = 1:endIndex
            indexes = k:(k + waveSize - 1);
            inputData = reshape(data(indexes, 1:end-1), 1, []);
            trainData(k + starts(i) - 1, :) = [inputData, data(indexes, end)'];
        end
    end

    ends = cumsum(traceSizes(testTraces) - waveSize + 1);
    starts = ends - (traceSizes(testTraces) - waveSize + 1) + 1;

    targets = [];
    testData = zeros(sum(ends - starts), I + waveSize);
    noisyTestData = {};
    for i = 1:numel(testTraces)
        trace = testTraces(i);
        S = traceSizes(trace);
        endIndex = S - waveSize + 1;
        data = squeeze(allData(:, trace, :));
        data = [data(:, 1:T), data(:, T+1) .* data(:, T+3), data(:, T+4) .* data(:, T+6), data(:, T+4:T+11)];
        targets = [targets ; data(1:S, end)]; %#ok<AGROW>
        for k = 1:endIndex
            indexes = k:(k + waveSize - 1);
            inputData = reshape(data(indexes, 1:T+1), 1, []);
            testData(k + starts(i) - 1, :) = [inputData, data(indexes, T+2)'];
        end
        noisyTestDataCell = {};
        for m = 1:length(noiseMultipliers)
            nm = noiseMultipliers(m);
            noisyData = data(1:S, 1:T) + nm .* data(1:S, end-2:end);
            noisyData = [noisyData, data(1:S, T+3:T+7)]; %#ok<AGROW>
            noisyBaggedData = zeros(endIndex, I + waveSize);
            for k = 1:endIndex
                indexes = k:(k + waveSize - 1);
                inputData = reshape(noisyData(indexes, 1:T), 1, []);
                noisyBaggedData(k, :) = [inputData, reshape(data(indexes, T+1:T+2), 1, [])];
            end
            noisyTestDataCell = [noisyTestDataCell, {{noisyBaggedData, noisyData}}];%#ok<AGROW>
        end 
        noisyTestData = [noisyTestData, {noisyTestDataCell}]; %#ok<AGROW>
    end
    trainData = trainData(randperm(size(trainData, 1)), :);
end

function [allData, traceSizes] = genSyntheticData(VpTraces, VsTraces, RhoTraces, initDeth, theta)
    frequency = 45;

    S = size(VpTraces, 2);

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
    PB = ProgressBar(S, 'Generating Synthetic Data', 'cli');

    NCoef = 110;
    Ts = 4;
    lowFreqFilter = @(x) lowPassFilter(x, Ts, NCoef, 8); % 6 a 8

    %% Wavelet
    wavelet = RickerWavelet(frequency, dt, ntw);
    allData = genSyntheticDataFor(theta, traceSize, ...
        Times, VpTraces, VsTraces, RhoTraces, TimeLog, timeSeis, wavelet, lowFreqFilter, PB);
    
    save('data/processedSynthFreq45.mat', 'allData' , 'traceSizes');
end

function data = genSyntheticDataFor(theta, traceSize, Times, ...
    VpTraces, VsTraces, RhoTraces, TimeLog, timeSeis, wavelet, lowFreqFilter,  PB)
    T = size(VpTraces, 2);
    data = nan(traceSize, T, numel(theta) + 11);
    
    for i = 1:T
        Time = Times{i};
        Vp =  VpTraces(:, i);
        Vs = VsTraces(:, i);
        Rho = RhoTraces(:, i);
        timeLog = TimeLog(:, i);
        data(:, i, :) = genSyntheticTrace(theta, ...
            traceSize, Time, timeLog, Vp, Vs, Rho, timeSeis{i}, wavelet, lowFreqFilter);
        pause(0.0001*rand);
        count(PB);
    end
end
