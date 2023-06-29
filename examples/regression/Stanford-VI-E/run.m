%% Cleanning up the workspace
dbstop if error
clear all; %#ok<CLALL> 
close all;
clc;

%% Add some external dependencies
addpath('../../../igmn/');
addpath(genpath('../../../Seislab 3.02'));
addpath(genpath('../../../SeReM/'))

%% Do some configurations

% Synthetic data configs

opts = delimitedTextImportOptions("NumVariables", 1);
opts.DataLines = [4, Inf];
opts.VariableTypes = "double";

dataPaths = {
    'data/Facies/facies', ...
    'data/Porosity/porosity', ...
    'data/Saturation/saturation', ...
    'data/P-wave Velocity/Pvelocity', ...
    'data/S-wave Velocity/Svelocity', ...
    'data/Density/density', ...
};

Facies = table2array(readtable(dataPaths{1}, opts));
Phi = table2array(readtable(dataPaths{2}, opts));
Sw = table2array(readtable(dataPaths{3}, opts));
Vp = table2array(readtable(dataPaths{4}, opts));
Vs = table2array(readtable(dataPaths{5}, opts));
Rho = table2array(readtable(dataPaths{6}, opts));


