% LOWPASSFILTER Applies a low-pass FIR filter to a given signal.
%
% Syntax:
%   [filteredSignal, h] = lowPassFilter(signal, Ts, Ncoef, cutFreq)
%
% Description:
%   This function applies a low-pass FIR filter to a 2D signal (e.g., an 
%   impedance matrix). Each column of the input signal is filtered 
%   independently. The filter is designed using the `fir1` function.
%
% Inputs:
%   signal   - Input signal, either a matrix or a column vector. Each 
%              column of the matrix will be filtered independently.
%   Ts       - Sampling interval in milliseconds (ms).
%   Ncoef    - Number of filter coefficients (analogous to overlap in Jason).
%   cutFreq  - Cutoff frequency in Hertz (Hz).
%
% Outputs:
%   filteredSignal - The filtered signal, with the same dimensions as the 
%                    input signal.
%   h              - The FIR filter coefficients.
%
% Example:
%   % Apply a low-pass filter to a signal with a sampling interval of 4 ms,
%   % 110 filter coefficients, and a cutoff frequency of 8 Hz.
%   filteredSignal = lowPassFilter(signal, 4, 110, 8);
%
% Notes:
%   - The input signal is extended at the beginning and end to reduce 
%     boundary effects during filtering.
%   - The sampling interval `Ts` is converted from milliseconds to seconds 
%     internally.
%   - The normalized cutoff frequency is calculated as `cutFreq * 2 * Ts`.
function[filteredSignal, h] = lowPassFilter(signal, Ts, Ncoef, cutFreq)
    Ts = Ts*1e-3;
   
    Fnorm = cutFreq*2*Ts;
    
    h=fir1(Ncoef,Fnorm)';
    
    signalMod(1:Ncoef) = signal(1);
    signalMod(Ncoef+1:Ncoef+length(signal)) = signal(1:end);
    signalMod(Ncoef+length(signal)+1:2*Ncoef+length(signal)+1) = signal(end);
    
    filteredSignal = filter(h,1,signalMod);
    filteredSignal = filteredSignal((3*Ncoef/2+1):(length(signal)+(3*Ncoef/2)));
end