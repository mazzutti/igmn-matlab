% This script configures and invokes MATLAB Coder to generate C++ code 
% from the MATLAB function `run_native`. The generated code is intended 
% to be compiled as a library with specific settings for namespace, 
% interface style, memory allocation, and debugging. Below is a summary 
% of the configuration options used:
%
% - `coder.config('lib', 'ecoder', true)`: Configures the code generation 
%   for a library with Embedded Coder enabled.
% - `cfg.TargetLang`: Specifies the target language as C++.
% - `cfg.CppNamespace`: Sets the namespace for the generated C++ code.
% - `cfg.CppNamespaceForMathworksCode`: Sets the namespace for MathWorks 
%   generated code.
% - `cfg.CppInterfaceClassName`: Defines the name of the C++ interface class.
% - `cfg.CppInterfaceStyle`: Specifies the interface style as "Methods".
% - `cfg.DynamicMemoryAllocationInterface`: Configures dynamic memory 
%   allocation to use C-style allocation.
% - `cfg.GenerateMakefile`: Enables the generation of a Makefile.
% - `cfg.GenerateReport`: Enables the generation of a code generation report.
% - `cfg.MATLABFcnDesc`: Disables the inclusion of MATLAB function 
%   descriptions in the generated code.
% - `cfg.MaxIdLength`: Sets the maximum identifier length to 1024.
% - `cfg.PreserveUnusedStructFields`: Preserves unused structure fields 
%   in the generated code.
% - `cfg.PreserveVariableNames`: Preserves all variable names in the 
%   generated code.
% - `cfg.ReportPotentialDifferences`: Disables reporting of potential 
%   differences in generated code.
% - `cfg.TargetLangStandard`: Specifies the C++ language standard as C++11.
% - `cfg.Toolchain`: Sets the toolchain to "Microsoft Visual Studio Project 
%   2019 | CMake (64-bit Windows)".
% - `cfg.SILPILDebugging`: Enables debugging for SIL/PIL simulations.
% - `cfg.EnableAutoParallelization`: Enables automatic parallelization 
%   in the generated code.
% - `cfg.BuildConfiguration`: Sets the build configuration to "Debug".
%
% Finally, the `codegen` command is used to generate the C++ code based 
% on the specified configuration and the MATLAB function `run_native`.
cfg = coder.config('lib', 'ecoder', true);
cfg.TargetLang = 'C++';
cfg.CppNamespace = 'igmnplugin';
cfg.CppNamespaceForMathworksCode = 'igmnplugin';
cfg.CppInterfaceClassName = 'IgmnPlugin';
cfg.CppInterfaceStyle = 'Methods';
cfg.DynamicMemoryAllocationInterface = 'C';
cfg.GenerateMakefile = true;
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

