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
