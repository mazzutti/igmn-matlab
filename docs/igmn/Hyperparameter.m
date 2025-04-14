% Hyperparameter Class
% 
% The `Hyperparameter` class represents a hyperparameter with associated
% properties such as its value, name, bounds, and whether it is discrete.
%
% Properties:
%   - value (double): 
%       The current or default value of the hyperparameter.
%   - name (char): 
%       The name of the hyperparameter.
%   - lb (double): 
%       The lower bound for the hyperparameter value. Default is -Inf.
%   - ub (double): 
%       The upper bound for the hyperparameter value. Default is Inf.
%   - isDiscrete (logical): 
%       Indicates whether the hyperparameter is discrete. Default is false.
%
% Methods:
%   - Hyperparameter(value, name, options):
%       Constructor to create a new `Hyperparameter` object.
%       Arguments:
%           - value (1,1 double): 
%               The hyperparameter default/current value. Must be numeric and non-NaN.
%           - name (1,: char): 
%               The hyperparameter name. Must be a finite text scalar.
%           - options.lb (1,1 double): 
%               The hyperparameter lower bound. Default is -Inf.
%           - options.ub (1,1 double): 
%               The hyperparameter upper bound. Default is Inf.
%           - options.isDiscrete (1,1 logical): 
%               Indicates whether the hyperparameter is discrete. Default is false.
%
% Static Private Methods:
%   - mustBeInRange(value, lb, ub):
%       Validates that the value is within the range [lb, ub].
%   - mustBeIntegerIfDiscrete(value, isDiscrete, argname):
%       Ensures that the value is an integer if the hyperparameter is discrete.
%   - mustBeValidBounds(lb, ub):
%       Validates that the lower bound (lb) is less than the upper bound (ub).
classdef Hyperparameter
    
    properties
        value
        name
        lb
        ub
        isDiscrete
    end

    methods(Static, Access=private)
    	function mustBeInRange(value, lb, ub)
            if ~(value >= lb && value <= ub)
                eidType = 'mustBeInRange:notInRange';
                msgType = 'value must be between in range [lb, ub]';
                error(eidType,msgType);
            end
        end

        function mustBeIntegerIfDiscrete(value, isDiscrete, argname)
            if isDiscrete && value ~= round(value)
                eidType = 'mustBeIntegerIfDiscrete:notIntegerWhenDiscrete';
                msgType = sprintf('%s must be integer in case of a discrete hyperparameter', argname);
                error(eidType,msgType, argname); %#ok<SPERR>
            end
        end

        function mustBeValidBounds(lb, ub)
            if lb >= ub
                eidType = 'mustBeValidBounds:notValidBounds';
                msgType = 'The lb value must be less than the ub value';
                error(eidType,msgType);
            end
        end
    end
    methods
        function self = Hyperparameter(value, name, options)
            %  value               The hyperparameter default/current value.
            %  name:               The hyperparameter name. 
            %  options.lb:         The hyperparameter lower bound.
            %  options.ub:         The hyperparameter upper bound.
            %  options.isDiscrete: Is it a discrete hyperparameter? The default value is false.
            arguments
                value (1,1) double {mustBeNumeric, mustBeNonNan}
                name (1,:) char {mustBeFinite, mustBeTextScalar}
                options.lb (1, 1) double {mustBeNumeric} = -Inf
                options.ub (1, 1) double {mustBeNumeric} = Inf
                options.isDiscrete (1, 1) logical = false
            end
            
            % Extra validations
            Hyperparameter.mustBeValidBounds(options.lb, options.ub);
            Hyperparameter.mustBeInRange(value, options.lb, options.ub);
            Hyperparameter.mustBeIntegerIfDiscrete(value, options.isDiscrete, 'value');
            Hyperparameter.mustBeIntegerIfDiscrete(options.lb, options.isDiscrete, 'lb');
            Hyperparameter.mustBeIntegerIfDiscrete(options.ub, options.isDiscrete, 'ub');
            
            self.value = value;
            self.name = name;
            self.lb = options.lb;
            self.ub = options.ub;
            self.isDiscrete = options.isDiscrete;
        end
    end
end



