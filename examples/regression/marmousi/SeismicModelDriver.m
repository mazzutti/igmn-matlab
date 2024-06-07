dbstop if error
clear all; %#ok<CLALL> 
close all;
clc;

%% Seismic Model Driver %%
% In this script we apply the convolutional model of a wavelet and the
% linearized approximation of Zoeppritz equations to compute synthetic
% seismograms for different reflection angles
% The model parameterization is expressed in terms of P- and S-wave
% velocity and density.

%% Available data and parameters
% Load data (elastic properties and depth)
rng('default');
rng(42);

addpath('../../../SeRem/');
addpath(genpath('../../../Seislab 3.02'));

%% Initial parameters
% number of variables
nv = 3;
% reflection angles 
theta = [15, 30, 45];
initDeth = 362;
well = 4000;

VpTraces = read_segy_file('data/model/MODEL_P-WAVE_VELOCITY_1.25m.segy').traces(initDeth:end, :);
VsTraces = read_segy_file('data/model/MODEL_S-WAVE_VELOCITY_1.25m.segy').traces(initDeth:end, :);
RhoTraces = read_segy_file('data/model/MODEL_DENSITY_1.25m.segy').traces(initDeth:end , :);
% 
% syn_time = read_segy_file('data/processed_data/SEGY-Time/SYNTHETIC_time.segy').traces(initDeth:end , :);
% s_plot(syn_time);

% travel time
dt = 0.00318;
t0 = dt * initDeth;
TimeLog = [t0; t0 + 2*cumsum(1 ./ (VpTraces(2:end, 8000)))];
Time = (TimeLog(1):dt:TimeLog(end))'; 

T = size(VpTraces, 2);
VpInterp = zeros(length(Time), T);
VsInterp = zeros(length(Time), T);
RhoInterp = zeros(length(Time), T);

% time-interpolated and filtered elastic log
nfilt = 3;
cutofffr = 0.04;
[b, a] = butter(nfilt, cutofffr);
for i = 1:T
    VpInterp(:, i) = filtfilt(b, a, interp1(TimeLog, VpTraces(:, i), Time));
    VsInterp(:, i) = filtfilt(b, a, interp1(TimeLog, VsTraces(:, i), Time));
    RhoInterp(:, i) = filtfilt(b, a, interp1(TimeLog, RhoTraces(:, i), Time));
end


% number of samples (seismic properties)
nd = length(VpInterp(:, well))-1;

%% Wavelet
% wavelet 
freq = 45;
ntw = 64;
[wavelet, tw] = RickerWavelet(freq, dt, ntw);


%% Plot elastic data
figure(1)
subplot(131)
plot(VpInterp(:, well), Time, 'k', 'LineWidth', 2);
axis tight; grid on; box on; set(gca, 'YDir', 'reverse');
xlabel('P-wave velocity (km/s)'); ylabel('Time (s)');
subplot(132)
plot(VsInterp(:, well), Time, 'k', 'LineWidth', 2);
axis tight; grid on; box on; set(gca, 'YDir', 'reverse');
xlabel('S-wave velocity (km/s)'); 
subplot(133)
plot(RhoInterp(:, well), Time, 'k', 'LineWidth', 2);
axis tight; grid on; box on; set(gca, 'YDir', 'reverse');
xlabel('Density (g/cm^3)'); 

Snear = zeros(length(Time)-1, T);
Smid = zeros(length(Time)-1, T);
Sfar = zeros(length(Time)-1, T);
TimeSeis = zeros(length(Time)-1, T);

%% Synthetic seismic data
for i = 1:T
    [Seis, TimeSeis(:, i)] = SeismicModel(VpInterp(:, i), VsInterp(:, i), RhoInterp(:, i), Time, theta, wavelet);
    Snear(:, i) = Seis(1:nd);
    Smid(:, i) = Seis(nd+1:2*nd);
    Sfar(:, i) = Seis(2*nd+1:end);
end


%% Plot seismic data
figure(2)
subplot(131)
plot(Snear(:, well), TimeSeis(:, well), 'k', 'LineWidth', 2);
axis tight; grid on; box on; set(gca, 'YDir', 'reverse');
xlabel('Near'); ylabel('Time (s)');
subplot(132)
plot(Smid(:, well), TimeSeis(:, well), 'k', 'LineWidth', 2);
axis tight; grid on; box on; set(gca, 'YDir', 'reverse');
xlabel('Mid'); 
subplot(133)
plot(Sfar(:, well), TimeSeis(:, well), 'k', 'LineWidth', 2);
axis tight; grid on; box on; set(gca, 'YDir', 'reverse');
xlabel('Far'); 

s_plot(Snear);
