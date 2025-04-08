% Problem Class
% 
% This class defines a problem setup for training and testing an Incremental Gaussian Mixture Network (IGMN) model.
%
% Properties:
%   - trainData: A matrix containing the data used for training the IGMN model.
%   - testData: A matrix containing the data used for testing the IGMN model.
%   - ExecutionMode: Specifies the execution mode for the IGMN model. Possible values are:
%       - 'script': Runs the code in pure MATLAB (default).
%       - 'mex': Compiles and uses the IGMN and associated code as a Mex configuration/code.
%       - 'native': Compiles and uses the IGMN and associated code as native compiled code.
%   - DoParametersTuning: A logical value indicating whether to perform hyperparameter tuning for the IGMN model.
%       - true: Perform hyperparameter tuning.
%       - false: Use the default IGMN options instead (default).
%   - AllData: An optional matrix containing all available data, including training and testing data.
%       - Default value: [trainData; testData].
%   - InputVarIndexes: Column indexes of trainData and testData to be used as input variables for the IGMN model.
%       - Default value: 1:(size(trainData, 2) - 1).
%   - OutputVarIndexes: Column indexes of trainData and testData to be used as output variables for the IGMN model.
%       - Default value: The last column of trainData/testData.
%   - DefaultIgmnOptions: Default options for the IGMN model, obtained using getDefaultIgmnOptions([trainData; testData]).
%   - CompileOptions: Default compile options, obtained using getDefaultCompileOptions().
%   - OptimizeOptions: Default optimization options, obtained using getDefaultOptimizeOptions().
%
% Methods:
%   - getDefaultIgmnOptions(data): Static method to generate default IGMN options based on the provided data.
%   - getDefaultCompileOptions(): Static method to generate default compile options.
%   - getDefaultOptimizeOptions(): Static method to generate default optimization options, including hyperparameter definitions.
%   - Problem(trainData, testData, options): Constructor to initialize a Problem instance with the provided training data,
%       testing data, and optional configuration options.
%
% Constructor Arguments:
%   - trainData: A numeric, non-NaN, non-empty, finite matrix for training data.
%   - testData: A numeric, non-NaN, non-empty, finite matrix for testing data.
%   - options.ExecutionMode: (Optional) Execution mode ('script', 'mex', 'native'). Default is 'script'.
%   - options.DoParametersTuning: (Optional) Logical value for hyperparameter tuning. Default is false.
%   - options.AllData: (Optional) Matrix containing all data. Default is [trainData; testData].
%   - options.InputVarIndexes: (Optional) Column indexes for input variables. Default is 1:(size(trainData, 2) - 1).
%   - options.OutputVarIndexes: (Optional) Column indexes for output variables. Default is the last column.
%   - options.DefaultIgmnOptions: (Optional) Default IGMN options. Default is obtained using getDefaultIgmnOptions().
%   - options.CompileOptions: (Optional) Default compile options. Default is obtained using getDefaultCompileOptions().
%   - options.OptimizeOptions: (Optional) Default optimization options. Default is obtained using getDefaultOptimizeOptions().
%
% Notes:
%   - The constructor performs additional validations to ensure consistency between trainData, testData, and options.
%   - If the size of options.AllData does not match the combined size of trainData and testData, the default IGMN options
%     are recalculated using options.AllData.
classdef Problem
    
    properties
        trainData
        testData
        ExecutionMode
        DoParametersTuning
        AllData
        InputVarIndexes
        OutputVarIndexes
        DefaultIgmnOptions
        CompileOptions
        OptimizeOptions
    end

    methods(Static)
        function options = getDefaultIgmnOptions(data)
            options = igmnoptions([min(data); max(data)]);
        end

        function options = getDefaultCompileOptions()
            options = compileoptions();
        end

        function options = getDefaultOptimizeOptions()
            hyperparameters = { 
                Hyperparameter(igmn.defaultTau, 'Tau', 'lb', 1e-15, 'ub', 1 - 1e-15), ...
                Hyperparameter(igmn.defaultDelta, 'Delta', 'lb', 1e-15, 'ub', 1 - 1e-15), ...
                Hyperparameter(igmn.defaultGamma, 'Gamma', 'lb', 0.5, 'ub', 1), ...
                Hyperparameter(igmn.defaultPhi, 'Phi', 'lb', 0.01, 'ub', 1), ...
                Hyperparameter(igmn.defaultSPMin, 'SPMin', 'isdiscrete', true, 'lb', 3, 'ub', 6), ...
                Hyperparameter(igmn.defaultVMin, 'VMin', 'isdiscrete', true, 'lb', 4, 'ub', 20), ...
                Hyperparameter(igmn.defaultRegValue, 'RegValue', 'lb', 0, 'ub', 1e-4) ...
                Hyperparameter(igmn.defaultMaxNc, 'MaxNc', 'isdiscrete', true, 'lb', 3, 'ub', 1000) ...
                Hyperparameter(igmn.defaultUseRankOne, 'UseRankOne', 'isdiscrete', true, 'lb', 0, 'ub', 1) ...
            };
            options = optimizeoptions(hyperparameters);
        end
    end
    
    methods
        function self = Problem(trainData, testData, options)
            %   trainData:                  A matrix with the data to be used to train the igmn model.
            %   testData:                   A matrix with the data to be used to test the igmn model.
            %   options.ExecutionMode:      The execution mode
            %                               - 'script' runs the code in pure Matlab (default).
            %                               - 'mex' compiles and uses the igmn and associated code as a Mex config/code.
            %                               - 'native' compiles and uses the igmn and associated code as native compiled code.
            %   options.DoParametersTuning: Do the igmn hyperparameters tuning when true. When false, use
            %                               false, options.DefaultIgmnOptions will be used instead. The default
            %                               value is false.
            %   options.AllData:            An optional matrix containing all data available, including the 
            %                               training and testing data. The default value is [trainData; testData].
            %   options.InputVarIndexes:    Column indexes to be considered as indexes of trainData and testData
            %                               to be used as input variables for the igmn generated model. The default
            %                               value is 1:(size(trainData, 2) - 1).
            %   options.OutputVarIndexes:   Column indexes to be considered as indexes of trainData and testData
            %                               to be used as output variables for the igmn generated model. The default
            %                               value is the last column of trainData/testData.
            %   options.DefaultIgmnOptions: The default igmn options as getDefaultIgmnOptions([trainData; testData]), 
            %                               if not explicitily provided.
            %   options.CompileOptions:     The default compile options as getDefaultCompileOptions(), if not 
            %                               explicitily provided.
            %   options.OptimizeOptions:    The default optimize options as getDefaultOptimizeOptions(), if not 
            %                               explicitily provided.
            arguments
                trainData (:, :) double { ...
                    mustBeNumeric, ...
                    mustBeNonNan, ...
                    mustBeNonempty, ...
                    mustBeFinite ...
                },
                testData (:, :) double { ...
                    mustBeNumeric, ...
                    mustBeNonNan, ...
                    mustBeNonempty, ...
                    mustBeFinite ...
                },
                options.ExecutionMode (1, :) char { ...
                    mustBeMember(options.ExecutionMode, {'script', 'mex', 'native'}) ...
                }  = 'script',
                options.DoParametersTuning (1, 1) logical = false,
                options.AllData (:, :) double { ...
                    mustBeNumeric, ...
                    mustBeNonNan, ...
                    mustBeFinite ...
                } = [trainData; testData],
                options.InputVarIndexes (1, :) double { ...
                    mustBeInteger, ...
                    mustBeGreaterThan(options.InputVarIndexes, 0) ...
                } = 1:(size(trainData, 2) - 1),
                options.OutputVarIndexes (1, :) double { ...
                    mustBeInteger, ...
                    mustBeGreaterThan(options.OutputVarIndexes, 0) ...
                } = size(trainData, 2),
                options.DefaultIgmnOptions (1, 1) igmnoptions = Problem.getDefaultIgmnOptions([trainData; testData]),
                options.CompileOptions (1, 1) compileoptions = Problem.getDefaultCompileOptions(),
                options.OptimizeOptions (1, 1) optimizeoptions = Problem.getDefaultOptimizeOptions(),
            end

            % Extra validations
            mustHaveSameNumberOfColumns(trainData, testData);
            mustHaveSameNumberOfColumns(trainData, [options.InputVarIndexes, options.OutputVarIndexes]);
            mustHaveSameNumberOfColumns(trainData, options.AllData);

            if size(options.AllData, 1) ~= (size(trainData, 1) + size(testData, 1))
                options.DefaultIgmnOptions = Problem.getDefaultIgmnOptions(options.AllData);
            end

            self.trainData = trainData;
            self.testData = testData;
            self.ExecutionMode = options.ExecutionMode;
            self.DoParametersTuning = options.DoParametersTuning;
            self.AllData = options.AllData;
            self.InputVarIndexes = options.InputVarIndexes;
            self.OutputVarIndexes = options.OutputVarIndexes;
            self.DefaultIgmnOptions = options.DefaultIgmnOptions;
            self.CompileOptions = options.CompileOptions;
            self.OptimizeOptions = options.OptimizeOptions;
        end
    end
end

