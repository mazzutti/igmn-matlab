% RUN_NATIVE_SCRIPT   Generate static library run_native from run_native.
% 
% Script generated from project 'run_native.prj' on 11-Apr-2024.
% 
% See also CODER, CODER.CONFIG, CODER.TYPEOF, CODEGEN.

%% Create configuration object of class 'coder.EmbeddedCodeConfig'.
cfg = coder.config('lib','ecoder',true);
cfg.TargetLang = 'C++';
cfg.CppNamespace = 'igmnplugin';
cfg.CppNamespaceForMathworksCode = 'igmnplugin';
cfg.CppInterfaceClassName = 'IgmnPlugin';
cfg.DynamicMemoryAllocationInterface = 'C';
cfg.GenerateMakefile = false;
cfg.GenerateReport = true;
cfg.MATLABFcnDesc = false;
cfg.MaxIdLength = 1024;
cfg.PreserveUnusedStructFields = true;
cfg.PreserveVariableNames = 'All';
cfg.ReportPotentialDifferences = false;
cfg.TargetLangStandard = 'C++11 (ISO)';
cfg.Toolchain = 'Microsoft Visual Studio Project 2019 | CMake (64-bit Windows)';
cfg.SILPILDebugging = true;
cfg.EnableAutoParallelization = true;
cfg.BuildConfiguration = 'Debug';

%% Invoke MATLAB Coder.
codegen -config cfg run_native

