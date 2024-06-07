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

