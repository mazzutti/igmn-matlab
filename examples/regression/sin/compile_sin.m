clear all; %#ok<CLALL> 
close all;
clc;
rng('default');
rng(42);

addpath('../../../igmn/');

% cfg = coder.config('lib');
% cfg.RuntimeChecks = true;
% cfg.BuildConfiguration = 'Debug';
% cfg.GenerateExampleMain = 'GenerateCodeAndCompile';
% cfg.SILPILDebugging = true;
% cfg.Toolchain = 'Microsoft Visual Studio Project 2019 | CMake (64-bit Windows)';
% cfg.TargetLang = 'C++';
% cfg.NumberOfCpuThreads = 12;
% cfg.EnableAutoParallelization = true;
% cfg.OptimizeReductions = true;
% cfg.GenerateReport = false;
% cfg.ReportPotentialDifferences = false;
% cfg.EnableVariableSizing = true;


cfg = coder.config('lib', 'ecoder', true);
cfg.RuntimeChecks = false;
cfg.BuildConfiguration = 'Debug';
cfg.GenerateExampleMain = 'GenerateCodeAndCompile';
% cfg.SILPILDebugging = true;
cfg.Toolchain = 'Microsoft Visual Studio Project 2019 | CMake (64-bit Windows)';
cfg.TargetLang = 'C++';
cfg.TargetLangStandard = 'C++11 (ISO)';
cfg.CppInterfaceClassName = 'IgmnPlugin';
cfg.CppInterfaceStyle = 'Methods';
% cfg.DataTypeReplacement = 'CoderTypeDefs';
cfg.CppNamespace = 'igmnplugin';
cfg.CppNamespaceForMathworksCode = 'igmnplugin';    
cfg.InstructionSetExtensions = 'SSE2';
cfg.DynamicMemoryAllocationInterface = 'C++';
cfg.PreserveVariableNames = 'All';
cfg.GenerateMakefile = false;
% cfg.InlineBetweenMathWorksFunctions = 'Readability';
% cfg.InlineBetweenUserAndMathWorksFunctions = 'Readability';
% cfg.InlineBetweenUserFunctions = 'Readability';
cfg.NumberOfCpuThreads = 12;
cfg.EnableAutoParallelization = true;
cfg.OptimizeReductions = true;
cfg.GenerateReport = true;
cfg.ReportPotentialDifferences = true;
cfg.EnableVariableSizing = true;
codegen -config cfg run_native


