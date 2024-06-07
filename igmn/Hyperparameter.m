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



