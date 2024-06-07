classdef igmn %#codegen

    properties (Constant)
        minimum = double(realmin('single'));
        maximum = double(realmax('single'));
        minTau = 1.0e-5;
        defaultTau = 0.1;
        defaultDelta = 0.01;
        defaultGamma = 1;
        defaultPhi = 0.35;
        defaultSPMin = 3;
        defaultVMin = 4;
        defaultRegValue = 0;
        defaultMaxNc = 100;
        defaultUseRankOne = 0;
    end
    
    properties
        %% Configuration params
        name = mfilename;
        dimension;
        maxDistance;
        initialCov;
        initialInvCov;
        initialLogDet;

        minCov;
        useRankOne;

        %% Configuration params
        range;
        nc;
        maxNc;
        delta;
        gamma;
        phi;
        tau;
        spMin;
        vMin;
        
        %% Components params
        priors;
        means;
        covs;
        invCovs;
        logDets;
        sp;
        spu;
        vs;

        % Mahalanobis distance
        distances;

        % Components outputs
        logLikes;
        posteriors;

        % sample seen
        numSamples;

        converged;
    end

    methods
    
        %Constructor
        function self = igmn(options) %#codegen
            % IGMN Incremental Gaussian Mixture Network Builder.
            %
            % Inputs:
            %   options: The igmn options as described in igmnoptions. 
            %
            % Output:
            %   self:    The IGMN handle for the new instance.
            arguments
                options (1, 1) {mustBeA(options, 'igmnoptions')};
            end
            self.range = options.range;
            self.dimension = size(self.range, 2);
            self.nc = 0;
            self.maxNc = options.MaxNc;
            self.vMin = options.VMin;
            self.spMin = options.SPMin;
            self.tau = options.Tau;
            self.phi = options.Phi;
            self.delta = options.Delta;
            self.gamma = options.Gamma;
            self.useRankOne = logical(options.UseRankOne);
            sigma = ((self.delta * (self.range(2, :) - self.range(1, :))) .^ 2);
            self.initialCov = diag(sigma);
            self.initialInvCov = diag(1.0 ./ sigma);
            self.initialLogDet = prod(sigma);
            self.maxDistance = chi2inv(1 - self.tau, double(self.dimension));
            minSigma = igmn.minimum + options.RegValue;
            self.minCov = eye(self.dimension) * minSigma;
            self.numSamples = 0;
            self.converged = true;

            % to make coder happy.
            self.means = 1; self.priors = 1; self.covs = 1; self.invCovs = 1;
            self.logDets = 1; self.sp = 1; self.spu = 1; self.vs = 1; 
            self.distances = 1; self.posteriors = 1;  self.logLikes = 1;

            self.covs = zeros(0, 0, 0);
            self.invCovs = zeros(0, 0, 0);
            self.logDets = zeros(0, 0);
            self.means = zeros(0, 0);
            self.priors = zeros(1, 0);
            self.sp = zeros(1, 0);
            self.spu = zeros(1, 0);
            self.vs = zeros(1, 0);
            self.distances = zeros(1, 0);
            self.logLikes = zeros(1, 0);
            self.posteriors = zeros(1, 0);
        end
    end
end
