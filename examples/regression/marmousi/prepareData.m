%{
prepareData - Prepares training and testing data for regression tasks using Marmousi II data.

Syntax:
    [trainData, testData, allData, traceSizes, targets, noisyTestData] = prepareData(genSynthData, trainTraces, testTraces, initDeth, waveSize, noiseMultipliers, plotData)

Inputs:
    genSynthData      - Logical flag indicating whether to generate synthetic data (true) or load preprocessed data (false).
    trainTraces       - Array of indices specifying the training traces.
    testTraces        - Array of indices specifying the testing traces.
    initDeth          - Initial depth index for data extraction.
    waveSize          - Size of the wavelet window for data segmentation.
    noiseMultipliers  - Array of noise multipliers for generating noisy test data.
    plotData          - Logical flag indicating whether to plot the data (currently commented out).

Outputs:
    trainData         - Matrix containing the prepared training data.
    testData          - Matrix containing the prepared testing data.
    allData           - 3D matrix containing all synthetic or loaded data.
    traceSizes        - Array containing the sizes of each trace.
    targets           - Array of target values for the test data.
    noisyTestData     - Cell array containing noisy versions of the test data.

Description:
    This function prepares the data for regression tasks by either generating synthetic data from the Marmousi II model or loading preprocessed data. It processes the data into training and testing sets, optionally adds noise to the test data, and organizes the data into a format suitable for machine learning models.

    The function also includes commented-out code for plotting the data, which can be enabled for visualization purposes.

Dependencies:
    - read_segy_file: Reads SEGY files to extract traces from the Marmousi II model.
    - genSyntheticData: Generates synthetic data based on input traces and parameters.
    - genBaggingData: Prepares bagged training and testing data from the input data.

Example:
    [trainData, testData, allData, traceSizes, targets, noisyTestData] = prepareData(true, [1, 2, 3], [4, 5], 10, 64, [0.1, 0.2], false);

See Also:
    genSyntheticData, genBaggingData
%}
function [trainData, testData, allData, traceSizes, ... 
    targets, noisyTestData] = prepareData(genSynthData, ...
    trainTraces, testTraces, initDeth, waveSize, noiseMultipliers, plotData)
    
    allTheta = 15:15:45;
    if genSynthData
        assertFileAvailable('data/marmousi/model/MODEL_P-WAVE_VELOCITY_1.25m.segy')
        VpTraces = read_segy_file('data/marmousi/model/MODEL_P-WAVE_VELOCITY_1.25m.segy').traces(initDeth:end, :) ./ 1000;
        assertFileAvailable('data/marmousi/model/MODEL_S-WAVE_VELOCITY_1.25m.segy')
        VsTraces = read_segy_file('data/marmousi/model/MODEL_S-WAVE_VELOCITY_1.25m.segy').traces(initDeth:end, :) ./ 1000;
        assertFileAvailable('data/marmousi/model/MODEL_DENSITY_1.25m.segy')
        RhoTraces = read_segy_file('data/marmousi/model/MODEL_DENSITY_1.25m.segy').traces(initDeth:end , :);
        [allData, traceSizes] = genSyntheticData(VpTraces, VsTraces, RhoTraces, initDeth, allTheta);
    else
        assertFileAvailable('data/marmousi/processedSynthFreq45.mat')
        structData = load('data/marmousi/processedSynthFreq45.mat');
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

%{
GENSYNTHETICDATA Generates synthetic seismic data based on input traces and parameters.

This function generates synthetic seismic data using input Vp, Vs, and density traces,
along with initial depth and angle parameters. The generated data is saved to a file
for further processing.

Inputs:
    - VpTraces: Matrix of P-wave velocity traces (rows represent depth, columns represent traces).
    - VsTraces: Matrix of S-wave velocity traces (rows represent depth, columns represent traces).
    - RhoTraces: Matrix of density traces (rows represent depth, columns represent traces).
    - initDeth: Initial depth (scalar) used to calculate time logs.
    - theta: Angle parameter (scalar or vector) used in synthetic data generation.

Outputs:
    - allData: Struct containing the generated synthetic seismic data.
    - traceSizes: Vector containing the sizes of each trace.

Details:
    - The function calculates time logs based on the input velocity traces and initial depth.
    - A Ricker wavelet is generated and used for convolution to simulate seismic responses.
    - A low-pass filter is applied to the data to remove high-frequency noise.
    - The generated data is saved to 'data/processedSynthFreq45.mat'.

Dependencies:
    - RickerWavelet: Function to generate a Ricker wavelet.
    - lowPassFilter: Function to apply a low-pass filter to the data.
    - genSyntheticDataFor: Function to generate synthetic data for each trace.
    - ProgressBar: Utility for displaying progress in the command line.

Example Usage:
    [allData, traceSizes] = genSyntheticData(VpTraces, VsTraces, RhoTraces, initDeth, theta);

Note:
    Ensure that the required dependencies are available in the MATLAB path.
%}
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
    
    save('data/marmousi/processedSynthFreq45.mat', 'allData' , 'traceSizes');
end

%{
% genSyntheticDataFor - Generates synthetic data for a given set of parameters.
%
% Syntax:
%   data = genSyntheticDataFor(theta, traceSize, Times, ...
%       VpTraces, VsTraces, RhoTraces, TimeLog, timeSeis, wavelet, lowFreqFilter, PB)
%
% Inputs:
%   theta          - Array of parameters used for generating synthetic traces.
%   traceSize      - Integer specifying the size of each trace.
%   Times          - Cell array containing time vectors for each trace.
%   VpTraces       - Matrix of P-wave velocities (rows: depth, columns: traces).
%   VsTraces       - Matrix of S-wave velocities (rows: depth, columns: traces).
%   RhoTraces      - Matrix of densities (rows: depth, columns: traces).
%   TimeLog        - Matrix of time logs (rows: depth, columns: traces).
%   timeSeis       - Cell array containing seismic time vectors for each trace.
%   wavelet        - Wavelet used for generating synthetic traces.
%   lowFreqFilter  - Low-frequency filter applied to the synthetic traces.
%   PB             - Progress bar object for tracking progress.
%
% Outputs:
%   data           - 3D array containing the generated synthetic data.
%                    Dimensions: [traceSize, number of traces, numel(theta) + 11].
%
% Description:
%   This function generates synthetic seismic data for a given set of parameters.
%   For each trace, it computes synthetic traces using the provided velocity,
%   density, and time log information, along with a wavelet and low-frequency
%   filter. The function updates a progress bar during processing.
%
% See also:
%   genSyntheticTrace, count
%}
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
