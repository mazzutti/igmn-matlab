%{
getGlobals - A function to retrieve global configuration parameters.

Outputs:
    theta (array): An array of angles in degrees, ranging from 15 to 45 with a step of 15.
    genSynthData (logical): A flag indicating whether to generate synthetic data (false by default).
    discretizationSize (integer): The size of the discretization grid (default is 20).
    initDeth (integer): The initial depth value (default is 396).
    numTrainTraces (integer): The number of training traces (default is 20).
    waveSize (integer): The size of the wave (default is 5).

Usage:
    [theta, genSynthData, discretizationSize, initDeth, numTrainTraces, waveSize] = getGlobals();
%}
function [theta, genSynthData, discretizationSize, ...
        initDeth, numTrainTraces, waveSize] = getGlobals()
    theta = 15:15:45;
    genSynthData = false;
    discretizationSize = 20;
    initDeth = 396;
    numTrainTraces = 20;
    waveSize = 5;
end

