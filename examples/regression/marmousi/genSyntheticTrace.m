% genSyntheticTrace - Generates a synthetic seismic trace with added noise and low-frequency data.
%
% Syntax:
%   trace = genSyntheticTrace(theta, traceSize, Time, tl, Vp, Vs, Rho, timeSeis, wavelet, lowFreqFilter)
%
% Inputs:
%   theta          - Array of parameters for the seismic model.
%   traceSize      - Size of the output trace array.
%   Time           - Time vector for interpolation and seismic modeling.
%   tl             - Time levels corresponding to the input Vp, Vs, and Rho.
%   Vp             - P-wave velocity profile.
%   Vs             - S-wave velocity profile.
%   Rho            - Density profile.
%   timeSeis       - Time vector for the seismic data.
%   wavelet        - Wavelet used for seismic modeling.
%   lowFreqFilter  - Function handle for low-frequency filtering.
%
% Outputs:
%   trace - A 3D array containing the synthetic seismic trace, low-frequency data,
%           interpolated properties (Vp, Vs, Rho), time vectors, and noisy seismic data.
%
% Description:
%   This function generates a synthetic seismic trace by interpolating the input
%   velocity and density profiles, applying a seismic model, and adding noise to
%   the resulting seismic data. It also computes low-frequency filtered data and
%   organizes all outputs into a 3D array.
%
% Notes:
%   - The function assumes that the input profiles (Vp, Vs, Rho) are defined on
%     the time levels `tl` and interpolates them to the `Time` vector.
%   - The noise is added to the seismic data using a Gaussian distribution with
%     a specified amplitude.
%   - The output `trace` contains multiple components, including the seismic
%     data, low-frequency data, interpolated properties, and noisy seismic data.
function trace = genSyntheticTrace(theta, traceSize, Time, tl, Vp, Vs, Rho, timeSeis, wavelet, lowFreqFilter)
    
    VpInterp = interp1(tl, Vp, Time);
    VsInterp =  interp1(tl, Vs, Time);
    RhoInterp = interp1(tl, Rho, Time);
    Seis = SeismicModel(VpInterp, VsInterp, RhoInterp, Time, theta, wavelet);
    Vp =  VpInterp(2:end, :);
    Vs = VsInterp(2:end, :);
    Rho = RhoInterp(2:end, :);

    lowFreqData = [lowFreqFilter(Vp)', lowFreqFilter(Vs)', lowFreqFilter(Rho)']; 

    nd = length(Time)-1;
    Seis = reshape(Seis, nd, []);
    SeisNoisy = s_noise(Seis, {'ratio', 1}, {'type','gaussian'}, {'amplitude', 'median'}).traces;

    trace = nan(traceSize, 1, numel(theta) + 11);
    trace(1:nd, 1, :) = [reshape(Seis, nd, []), lowFreqData, Vp, Vs, Rho, Time(2:end), timeSeis, SeisNoisy];
end