% COMPILEOPTIONS Class
% 
% The `compileoptions` class is used to configure various options for code
% generation and compilation processes. It provides properties to specify
% dataset sizes, enable profiling and reporting, and define problem-specific
% parameters such as the number of variables and output variables.
%
% Properties:
%   trainSize (double): 
%       The size of the training dataset. Default is `inf`.
%   testSize (double): 
%       The size of the testing dataset. Default is `inf`.
%   allDataSize (double): 
%       The total size of the dataset, calculated as `trainSize + testSize`.
%   EnableProfile (logical): 
%       Indicates whether profiling instrumentation is included in the 
%       generated code. Default is `false`.
%   EnableReport (logical): 
%       Indicates whether a code generation report is produced. Default is `false`.
%   EnableRecompile (logical): 
%       Forces the generation/compilation process to be redone if set to `true`.
%       Default is `false`.
%   IsClassification (logical): 
%       Specifies if the problem is a classification problem. Default is `false`.
%   IsOptimization (logical): 
%       Specifies if the problem is an optimization problem. Default is `false`.
%   NumberOfVariables (double): 
%       The number of problem variables to consider during code generation.
%       Must be a positive integer. Default is `2`.
%   NumberOfOutputVars (double): 
%       The number of problem output variables to consider during code generation.
%       Must be a positive integer. Default is `1`.
%
% Methods:
%   compileoptions(trainSize, testSize, allDataSize, options):
%       Constructor method to initialize the `compileoptions` object.
%
%       Arguments:
%           trainSize (double): 
%               The size of the training dataset. Default is `inf`.
%           testSize (double): 
%               The size of the testing dataset. Default is `inf`.
%           allDataSize (double): 
%               The total size of the dataset, calculated as `trainSize + testSize`.
%               Default is `trainSize + testSize`.
%           options (struct): 
%               A structure containing the following optional fields:
%               - NumberOfVariables (double): 
%                   Number of problem variables. Default is `2`.
%               - NumberOfOutputVars (double): 
%                   Number of output variables. Default is `1`.
%               - MaxNc (double): 
%                   Maximum number of clusters. Default is `trainSize + 1`.
%               - EnableProfile (logical): 
%                   Enable profiling instrumentation. Default is `false`.
%               - EnableReport (logical): 
%                   Enable code generation report. Default is `false`.
%               - IsClassification (logical): 
%                   Specify if it is a classification problem. Default is `false`.
%               - IsOptimization (logical): 
%                   Specify if it is an optimization problem. Default is `false`.
%               - EnableRecompile (logical): 
%                   Force recompilation. Default is `false`.
classdef compileoptions
    
    properties
        trainSize
        testSize
        allDataSize
        EnableProfile
        EnableReport
        EnableRecompile
        IsClassification
        IsOptimization
        NumberOfVariables
        NumberOfOutputVars
    end
    
    methods
        function self = compileoptions(trainSize, testSize, allDataSize, options)
            %   options.EnableProfile:      Informes code generator to include the instrumentation for 
            %                               profiling in the generated code. The default value is false.
            %   options.EnableReport:       Informes the code generator produces a code generation report.
            %                               The default value is false.
            %   options.EnableRecompile:    If true, forces the generation/compilation process to be 
            %                               redone. The default value is false.
            %   options.IsClassification:   Is it a classification problem? The default value is false.
            %   options.IsOptimization:     Is it an optiomization problem? The default value is false.
            %   options.NumberOfFeatures:   Informes the code generator the number of problem variables to 
            %                               be considered during the coding generation/compilation. The 
            %                               default value is 2.
            %   options.NumberOfOutputVars: Informes the code generator the number of problem output 
            %                               variables to be considered during the coding generation/compilation. 
            %                               The default value is 1.
            arguments
                trainSize (1, 1) double = inf,
                testSize (1, 1) double = inf,
                allDataSize (1, 1) double = trainSize + testSize,
                options.NumberOfVariables (1,1) double { ...
                    mustBeInteger, ...
                    mustBeNonNan, ...
                    mustBePositive, ...
                    mustBeFinite ...
                } = 2,
                options.NumberOfOutputVars (1,1) double { ...
                    mustBeInteger, ...
                    mustBeNonNan, ...
                    mustBePositive, ...
                    mustBeFinite ...
                } = 1,
                options.MaxNc (1, 1) double = trainSize + 1,
                options.EnableProfile (1,1) logical = false,
                options.EnableReport (1,1) logical = false,
                options.IsClassification (1,1) logical = false,
                options.IsOptimization (1,1) logical = false,
                options.EnableRecompile (1,1) logical = false,
            end
            self.trainSize = trainSize;
            self.testSize = testSize;
            self.allDataSize = allDataSize;
            self.EnableReport = options.EnableReport;
            self.EnableRecompile = options.EnableRecompile;
            self.EnableProfile = options.EnableProfile;
            self.IsClassification = options.IsClassification;
            self.IsOptimization = options.IsOptimization;
            self.NumberOfVariables = options.NumberOfVariables;
            self.NumberOfOutputVars = options.NumberOfOutputVars;
        end
    end
end
