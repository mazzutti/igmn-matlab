% highPassFilter - Applies a high-pass FIR filter to a 2D signal or column vector.
%
% Syntax:
%   [filteredSignal, h] = highPassFilter(signal, Ts, Ncoef, cutFreq)
%
% Inputs:
%   signal   - 2D signal matrix or column vector (e.g., impedance matrix).
%              Each column of the matrix will be filtered independently.
%   Ts       - Sampling interval in milliseconds (ms).
%   Ncoef    - Number of filter coefficients (analogous to overlap in Jason).
%   cutFreq  - Cutoff frequency in Hertz (Hz).
%
% Outputs:
%   filteredSignal - The filtered signal after applying the high-pass filter.
%   h              - The FIR filter coefficients.
%
% Description:
%   This function applies a high-pass FIR filter to the input signal. The
%   signal can be a 2D matrix or a column vector. The function ensures that
%   the signal is padded appropriately to avoid edge effects during filtering.
%
% Example:
%   % Apply a high-pass filter to a signal with a sampling interval of 4 ms,
%   % 110 filter coefficients, and a cutoff frequency of 8 Hz.
%   filteredSignal = highPassFilter(signal, 4, 110, 8);
%
% Notes:
%   - The input signal should be a matrix or a column vector.
%   - The function pads the signal at the beginning and end to minimize
%     boundary effects during filtering.
%   - The cutoff frequency should be less than half the sampling frequency
%     (Nyquist frequency).
function[filteredSignal, h] =  highPassFilter(signal, Ts, Ncoef, cutFreq)
    Ts = Ts * 1e-3;
    Fnorm = cutFreq*2*Ts;
    
    h = fir1(Ncoef,Fnorm,'high')';
    
    signalMod(1:Ncoef) = signal(1);
    signalMod(Ncoef+1:Ncoef+length(signal)) = signal(1:end);
    signalMod(Ncoef+length(signal)+1:2*Ncoef+length(signal)+1) = signal(end);
    
    filteredSignal = filter(h, 1, signalMod);
    filteredSignal = filteredSignal((3*Ncoef/2+1):(length(signal)+(3*Ncoef/2)));
end
