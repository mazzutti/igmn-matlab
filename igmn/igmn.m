classdef igmn

    properties (Constant)
        eta = realmin('double');
        minTau = 1.0e-5;
        defaultTau = 0.1;
        defaultDelta = 0.01;
    end
    
    properties
        %% Configuration params
        name = mfilename;
        dimension;
        maxDistance;
        initialCov;
        minCov;  

        %% Configuration params
        range;
        nc;
        sampleSize;
        delta;
        tau;
        spMin;
        vMin;
        
        %% Components params
        priors;
        means;
        covs;
        sps;
        vs;

        % Mahalanobis distance
        distances;

        % components outputs
        logLikes;
        posteriors;
    end

    methods
    
        %Constructor
        function self = igmn(range, options) %#codegen
            % IGMN Incremental Gaussian Mixture Network.
            %
            % Inputs:
            %   range:       This is the only mandatory parameter in this 
            %                method.This parameter represents the data 
            %                range, i.e., [min(data), max(data)].
            %   tau:         The tau is a are threshold which inform 
            %                IGMN when to create new components. When a 
            %                new input pattern is presented to this model, 
            %                the likelihood  relative to the input and all 
            %                components is computed. A given component can 
            %                "absorbs" the input if it represents well 
            %                enough the pattern,  i.e., if its likelihood 
            %                is greater than tau. 
            %   delta:       The delta parameter is a fraction of the data 
            %                range which will be used to create the initial 
            %                covariance matrices. In a practical view, this 
            %                parameter defines the size of the distributions.
            %   spMin|vMin:  The spMin and vMin parameters are used to 
            %                remove noisy components. When a new input 
            %                pattern is presented to the model, it verifies 
            %                if some component is older than vMin and have 
            %                less activation than spMin, if it is the case, 
            %                the component is removed.
            %
            % Output:
            %   self:        The IGMN handle for the new instance.
            arguments
                range (2,:) {mustBeNumeric, mustBeNonempty};
                options struct = struct();
            end
            self.range = range;
            self.dimension = int32(size(self.range, 2));
            defaults = struct(...                     
                'tau', igmn.defaultTau, ...
                'delta', igmn.defaultDelta, ...
                'spMin', 2 * int32(self.dimension), ...
                'vMin', int32(self.dimension  + 1), ...
                'regValue', 0);
            options = mergeOptions(defaults, options);
            self.nc = int32(0);
            self.sampleSize = int32(0);
            self.vMin = options.vMin;
            self.spMin = options.spMin;
            self.tau = options.tau;
            self.delta = options.delta;
            self.initialCov = diag((self.delta * (self.range(2, :) - self.range(1, :))) .^ 2);
            self.maxDistance = chi2inv(1 - self.tau, double(self.dimension));
            self.minCov = eye(self.dimension) * (igmn.eta + options.regValue);
            self.covs = [];
            self.means = [];
            self.priors = [];
            self.sps = [];
            self.vs = [];
            self.distances = [];
            self.logLikes = [];
            self.posteriors = [];
        end
    end
end
