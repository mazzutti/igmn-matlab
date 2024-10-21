function [Snear, Smid, Sfar, Vp, Vs, Rho, timeSeis, time] = prepareDataSeReM(theta, traceNumber, genSynthData, initDeth)

    allTheta = 15:3:45;
    VpTraces = read_segy_file('data/model/MODEL_P-WAVE_VELOCITY_1.25m.segy').traces(initDeth:end, :) ./ 1000;
    if genSynthData
        VsTraces = read_segy_file('data/model/MODEL_S-WAVE_VELOCITY_1.25m.segy').traces(initDeth:end, :) ./ 1000;
        RhoTraces = read_segy_file('data/model/MODEL_DENSITY_1.25m.segy').traces(initDeth:end , :);
        [allData, timeSeis, traceSizes] = genSyntheticData(VpTraces, VsTraces, RhoTraces, initDeth, allTheta);
    else
        structData = load('data/processedSynthAIForSeReM.mat');
        allData = structData.allData;
        timeSeis = structData.timeSeis;
        traceSizes = structData.traceSizes;

        % traceSizes = traceSizes - 310;
        % for i = 1:length(timeSeis); timeSeis{i} = timeSeis{i}(310:end); end
        % allData = allData(310:end, :, :);
    end

    outIndexes = size(allData, 3)-2:size(allData, 3);
    varIndexes = [arrayfun(@(x) find(allTheta == x), theta), outIndexes];

    endIndex = traceSizes(traceNumber);
    data = squeeze(allData(1:endIndex, traceNumber, varIndexes));


    dt = 0.004;
    t0 = zeros(1, length(traceSizes));
    t0(:) = dt * initDeth;
    TimeLog = [t0; t0 + 2 * cumsum(0.00125 ./ (VpTraces(2:end, :)), 1)];
    Times = cell(1, size(TimeLog, 2));
    for i = 1:size(TimeLog, 2)
        Time = (TimeLog(1, i):dt:TimeLog(end, i))';
        Times{i} = Time;
    end
    
    Snear = data(1:end-1, 1);
    Smid = data(1:end-1, 2);
    Sfar = data(1:end-1, 3);
    Vp = data(:, 4); 
    Vs = data(:, 5);
    Vs(:) = 1;
    Rho = data(:, 6);
    timeSeis = timeSeis{traceNumber}(1:endIndex-1);
    time = Times{traceNumber}(1:endIndex);
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
    data = zeros(traceSize, S, T + 3);
    PB = ProgressBar(F * S, 'Generating Synthetic Data', 'cli');

    for f = 1:F
        %% Wavelet
        wavelet = RickerWavelet(frequencies(f), dt, ntw);
        data = data + genSyntheticDataFor(theta, traceSize, ...
            Times, VpTraces, VsTraces, RhoTraces, TimeLog, wavelet, PB);
    end

    tempData = data ./ F;

    allData = cat(3, cat(3, tempData(:, :, 1:T), tempData(:, :, T+1:T+3)));
    
    save('data/processedSynthAIForSeReM.mat', 'allData' , 'timeSeis', 'traceSizes');
end

function data = genSyntheticDataFor(theta, traceSize, Times, ...
    VpTraces, VsTraces, RhoTraces, TimeLog, wavelet, PB)
    T = size(VpTraces, 2);
    data = nan(traceSize, T, numel(theta) + 3);
    
    parfor i = 1:T
        Time = Times{i};
        Vp =  VpTraces(:, i);
        Vs = VsTraces(:, i);
        Rho = RhoTraces(:, i);
        timeLog = TimeLog(:, i);
        data(:, i, :) = genSyntheticTrace(theta, ...
            traceSize, Time, timeLog, Vp, Vs, Rho, wavelet);
        pause(0.0001*rand);
        count(PB);
    end
end

function trace = genSyntheticTrace(theta, traceSize, Time, tl, Vp, Vs, Rho, wavelet)
    
    VpInterp = interp1(tl, Vp, Time);
    VsInterp =  interp1(tl, Vs, Time);
    RhoInterp = interp1(tl, Rho, Time);
    Seis = SeismicModel(VpInterp, VsInterp, RhoInterp, Time, theta, wavelet);
    Vp =  VpInterp(2:end, :);
    Vs = VsInterp(2:end, :);
    Rho = RhoInterp(2:end, :); 

    nd = length(Time)-1;
    trace = nan(traceSize, 1, numel(theta) + 3);
    trace(1:nd, 1, :) = [reshape(Seis, nd, []), Vp, Vs, Rho];
end

