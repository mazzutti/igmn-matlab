% IGMNOPTIONS Class for configuring Incremental Gaussian Mixture Network (IGMN) options.
%
% This class defines the configuration options for the IGMN algorithm, which
% is used for incremental learning and clustering. The options include various
% thresholds, regularization parameters, and other settings that control the
% behavior of the algorithm.
%
% Properties:
%   range       - A two-row matrix representing the data range. Each column
%                 must be sorted in ascending order. This is a mandatory parameter.
%   Tau         - Threshold for creating new components. A component absorbs
%                 an input if its likelihood is greater than Tau. Must be in
%                 the range (0, 1).
%   Delta       - Fraction of the data range used to create initial covariance
%                 matrices. Must be in the range (0, 1).
%   Gamma       - Fractional part of the accumulators to maintain after a restart.
%                 Must be in the range (0, 1].
%   Phi         - Fractional parameter for controlling distribution updates.
%                 Must be in the range (0, 1].
%   SPMin       - Minimum activation threshold for removing noisy components.
%                 Must be greater than or equal to 2.
%   VMin        - Minimum age threshold for removing noisy components. Must be
%                 an integer greater than or equal to 2.
%   RegValue    - Regularization value for numerical stability. Must be greater
%                 than or equal to 0.
%   MaxNc       - Maximum number of Gaussian components allowed. Must be in the
%                 range [3, 10000].
%   UseRankOne  - Experimental flag to enable Rank-One updates in IGMN. Must be
%                 either 0 (disabled) or 1 (enabled).
%
% Methods:
%   igmnoptions(range, options) - Constructor to initialize the IGMN options.
%                                 The `range` parameter is mandatory, while
%                                 other parameters are optional and have default
%                                 values.
%   from(options, names, values) - Static method to create a copy of an
%                                  igmnoptions object with updated properties
%                                  based on the provided names and values.
%
% Static Private Methods:
%   extractValue(propName, options, names, values) - Helper method to extract
%                                                    property values from the
%                                                    provided names and values.
%
% Validation Functions:
%   mustBeSortedInAscendingOrder(range) - Ensures that the `range` matrix is
%                                         sorted in ascending order for each
%                                         column.
classdef igmnoptions
    
    properties
        range
        Tau
        Delta
        Gamma
        Phi
        SPMin
        VMin
        RegValue
        MaxNc
        UseRankOne
    end

    methods(Static, Access=private)
        function value = extractValue(propName, options, names, values)
            indexes = strcmp(names, propName);
            if any(indexes)
                value = values{indexes};
            else
                value = options.(propName);
            end
        end
    end

    methods(Static)
        function copy = from(options, names, values)
            arguments
                options (1, 1) igmnoptions,
                names (1, :) { mustBeACellArrayOf(names, 'char') } = {},
                values (1, :) {  mustBeACellArrayOf(values, 'double') } = {}
            end
            assert(size(names, 2) == size(values, 2));
            copy = igmnoptions(options.range, ...
                'Tau', igmnoptions.extractValue('Tau', options, names, values), ...
                'Delta', igmnoptions.extractValue('Delta', options, names, values), ...
                'Gamma', igmnoptions.extractValue('Gamma', options, names, values), ...
                'Phi', igmnoptions.extractValue('Phi', options, names, values), ...
                'SPMin', igmnoptions.extractValue('SPMin', options, names, values), ...
                'VMin', igmnoptions.extractValue('VMin', options, names, values), ...
                'RegValue', igmnoptions.extractValue('RegValue', options, names, values), ...
                'MaxNc', igmnoptions.extractValue('MaxNc', options, names, values), ...
                'UseRankOne', igmnoptions.extractValue('UseRankOne', options, names, values));
        end
    end
    
    methods
        function self = igmnoptions(range, options)
            %   range:                       This is the only mandatory parameter in this
            %                                method.This parameter represents the data 
            %   options.Tau:                 The tau is a are threshold which inform 
            %                                IGMN when to create new components. When a 
            %                                new input pattern is presented to this model, 
            %                                the likelihood  relative to the input and all 
            %                                components is computed. A given component can 
            %                                "absorbs" the input if it represents well 
            %                                enough the pattern,  i.e., if its likelihood 
            %                                is greater than tau. 
            %   options.Delta:               The delta parameter is a fraction of the data 
            %                                range which will be used to create the initial 
            %                                covariance matrices. In a practical view, this
            %   options.Gamma                a fractional part of the accumulators that should 
            %                                be maintained after a restart.
            %                                parameter defines the size of the distributions.
            %   options.SPMin|options.VMin:  The SPMin and VMin parameters are used to 
            %                                remove noisy components. When a new input 
            %                                pattern is presented to the model, it verifies 
            %                                if some component is older than vMin and have 
            %                                less activation than spMin, if it is the case, 
            %                                the component is removed.
            %   options.RegValue             The regularization value.
            %   options.MaxNc                The maximum number of gaussian components to be accepted. 
            %                                The default value is inf.
            %   options.UseRankOne           Exeperimental flag to enable Rank one updates in IGMN.
            arguments
                range (2,:) double { ...
                    mustBeNumeric, ...
                    mustBeNonempty, ...
                    mustBeNonNan, ...
                    mustBeFinite, ...
                    mustBeReal, ...
                    mustBeSortedInAscendingOrder(range) ...
                },
                options.Tau (1,1) double { ...
                    mustBeReal, ...
                    mustBeGreaterThan(options.Tau, 0), ...
                    mustBeLessThan(options.Tau, 1) ...
                } = igmn.defaultTau,
                options.Delta (1,1) double { ...
                    mustBeReal, ...
                    mustBeGreaterThan(options.Delta, 0), ...
                    mustBeLessThan(options.Delta, 1) ...
                } = igmn.defaultDelta,
                options.Gamma (1,1) double { ...
                    mustBeReal, ...
                    mustBeGreaterThan(options.Gamma, 0), ...
                    mustBeLessThanOrEqual(options.Gamma, 1) ...
                } = igmn.defaultGamma,
                options.Phi (1,1) double { ...
                    mustBeReal, ...
                    mustBeGreaterThan(options.Phi, 0), ...
                    mustBeLessThanOrEqual(options.Phi, 1) ...
                } = igmn.defaultPhi,
                options.SPMin (1,1) double { ...
                    mustBeGreaterThanOrEqual(options.SPMin, 2) ...
                } = igmn.defaultSPMin,
                options.VMin (1,1) double { ...
                    mustBeInteger, ...
                    mustBeGreaterThanOrEqual(options.VMin, 2) ...
                } = min(igmn.defaultVMin, 2 * size(range, 2)),
                options.RegValue (1,1) double { ...
                    mustBeReal, ...
                    mustBeGreaterThanOrEqual(options.RegValue, 0) ...
                } = igmn.defaultRegValue,
                options.MaxNc (1,1) double { ...
                    mustBeGreaterThanOrEqual(options.MaxNc, 3), ...
                    mustBeLessThanOrEqual(options.MaxNc, 10000) ...
                } = igmn.defaultMaxNc,
                options.UseRankOne (1, 1) double { ...
                    mustBeMember(options.UseRankOne, [0, 1]) ...
                } = igmn.defaultUseRankOne;
            end
            self.range = range;
            self.Tau = options.Tau;
            self.Delta = options.Delta;
            self.Gamma = options.Gamma;
            self.Phi = options.Phi;
            self.SPMin = options.SPMin; 
            self.VMin = options.VMin;
            self.RegValue = options.RegValue;
            self.MaxNc = options.MaxNc;
            self.UseRankOne = options.UseRankOne;
        end
    end
end

function mustBeSortedInAscendingOrder(range)
    if ~all(range(1, :) < range(2, :))
        eidType = 'mustBeSortedInAscendingOrder:notSortedInAscendingOrder';
        msgType = ['range must be a two row real-valued matrix, ' ...
            'where each column must be sorted in ascending order.'];
        error(eidType,msgType);
    end
end

