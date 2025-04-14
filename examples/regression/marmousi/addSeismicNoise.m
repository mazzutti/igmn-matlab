% addSeismicNoise Adds seismic noise to input data.
%
%   noiseData = addSeismicNoise(data, theta, noise, waveSize, traces, 
%                               traceSizes, starts, noiseMultiplier)
%
%   This function adds seismic noise to the input data based on the provided
%   parameters. The noise is applied to specific traces and adjusted by a 
%   noise multiplier.
%
%   Inputs:
%       data            - Matrix containing the original seismic data.
%       theta           - Array of parameters related to seismic input variables.
%       noise           - Struct containing noise data, including a field 'traces'
%                         which holds the noise values.
%       waveSize        - Integer specifying the size of the wave window.
%       traces          - Array of trace indices to which noise will be added.
%       traceSizes      - Array specifying the size of each trace.
%       starts          - Array specifying the starting indices for each trace.
%       noiseMultiplier - Scalar value to scale the noise before adding it to the data.
%
%   Outputs:
%       noiseData       - Matrix containing the seismic data with added noise.
%
%   Example:
%       noiseData = addSeismicNoise(data, theta, noise, 10, [1, 2], [100, 200], [1, 101], 0.5);
%
%   Notes:
%       - The function assumes that the input data and noise have compatible
%         dimensions.
%       - The noise is scaled by the noiseMultiplier before being added to the data.
%       - The seismic input variables are determined by the product of the number
%         of elements in 'theta' and 'waveSize'.
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