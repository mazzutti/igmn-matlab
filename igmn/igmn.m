% IGMN Class
% 
% The `igmn` class implements an Incremental Gaussian Mixture Network (IGMN).
% It provides methods and properties for building and managing a Gaussian 
% Mixture Model incrementally.
%
% Properties:
%   Constant:
%     - minimum: Minimum value for single-precision floating-point numbers.
%     - maximum: Maximum value for single-precision floating-point numbers.
%     - minTau: Minimum value for the tau parameter.
%     - defaultTau: Default value for the tau parameter.
%     - defaultDelta: Default value for the delta parameter.
%     - defaultGamma: Default value for the gamma parameter.
%     - defaultPhi: Default value for the phi parameter.
%     - defaultSPMin: Default minimum value for spMin.
%     - defaultVMin: Default minimum value for vMin.
%     - defaultRegValue: Default regularization value.
%     - defaultMaxNc: Default maximum number of components.
%     - defaultUseRankOne: Default flag for using rank-one updates.
%
%   Instance:
%     - name: Name of the current instance (default: filename).
%     - dimension: Dimensionality of the data.
%     - maxDistance: Maximum Mahalanobis distance for component assignment.
%     - initialCov: Initial covariance matrix.
%     - initialInvCov: Initial inverse covariance matrix.
%     - initialLogDet: Initial log determinant of the covariance matrix.
%     - minCov: Minimum covariance matrix for regularization.
%     - useRankOne: Flag indicating whether to use rank-one updates.
%     - range: Range of the data.
%     - nc: Current number of components.
%     - maxNc: Maximum number of components.
%     - delta: Delta parameter for covariance initialization.
%     - gamma: Gamma parameter for component updates.
%     - phi: Phi parameter for component updates.
%     - tau: Tau parameter for component assignment.
%     - spMin: Minimum value for sp.
%     - vMin: Minimum value for v.
%     - priors: Prior probabilities of the components.
%     - means: Means of the components.
%     - covs: Covariance matrices of the components.
%     - invCovs: Inverse covariance matrices of the components.
%     - logDets: Log determinants of the covariance matrices.
%     - sp: Sufficient statistics for sp.
%     - spu: Sufficient statistics for spu.
%     - vs: Sufficient statistics for v.
%     - distances: Mahalanobis distances for component assignment.
%     - logLikes: Log-likelihoods of the components.
%     - posteriors: Posterior probabilities of the components.
%     - numSamples: Number of samples processed.
%     - converged: Flag indicating whether the model has converged.
%
% Methods:
%   - igmn(options): Constructor for the `igmn` class. Initializes the 
%     IGMN instance with the specified options.
%
% Constructor Inputs:
%   - options: An instance of the `igmnoptions` class containing configuration 
%     parameters for the IGMN instance.
%
% Constructor Outputs:
%   - self: The handle to the newly created `igmn` instance.
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
