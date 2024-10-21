function stds_esmda = runSeReM(waveSize, theta, reRun, noisyTestData)

    if reRun
        
        presets;
        nsim = waveSize;
        stds_esmda = zeros(size(noisyTestData{1}{2}, 1) - 2*nsim + 1, nsim * numel(noisyTestData));
        noisyMultipliers = [0, 0.1, 0.5, 1];
        for i = 1:numel(noisyTestData)

            noisyData = noisyTestData{i}{2};
            Snear = noisyData(1:end-1, 1);
            Smid = noisyData(1:end-1, 2);
            Sfar = noisyData(1:end-1, 3);
            Vp = noisyData(:, 4);
            Vs = noisyData(:, 5); 
            Vs(:, :) = 1;
            Rho = noisyData(:, 6); 
            Time = noisyData(:, 7);
            TimeSeis = noisyData(1:end-1, 8); 
            
        
            %% Initial parameters
            % number of samples (elastic properties)
            nm = size(Snear,1)+1;
            % number of samples (seismic data)
            nd = size(Snear,1);
            % number of variables
            % reflection angles 
            ntheta = length(theta);
            % time sampling
            dt = TimeSeis(2)-TimeSeis(1);
            % error variance
            varerr = 10^-4;
            % varerr = varerr + 10 * varerr * noisyMultipliers(i);
            sigmaerr = varerr*eye(ntheta*(nm-1));
            % number of realizations
            
            %% Wavelet
            % wavelet 
            freq = 45;
            ntw = 64;
            [wavelet, ~] = RickerWavelet(freq, dt, ntw);
        
            %% Prior model (filtered well logs)
            nfilt = 3;
            cutofffr = 0.04;
            [b, a] = butter(nfilt, cutofffr);
            Vpprior = filtfilt(b, a, Vp);
            Vsprior = filtfilt(b, a, Vs);
            Rhoprior = filtfilt(b, a, Rho);
            mprior = [Vpprior Vsprior Rhoprior];
        
            %% Spatial correlation matrix
            corrlength = 5*dt;
            trow = repmat(0:dt:(nm-1)*dt,nm,1);
            tcol = repmat((0:dt:(nm-1)*dt)',1,nm);
            tdis = trow-tcol;
            sigmatime = exp(-(tdis./corrlength).^2);
            sigma0 = cov([Vp,Vs,Rho]);
        
        
            %% Prior realizations
            Vpsim = zeros(nm, nsim);
            Vssim = zeros(nm, nsim);
            Rhosim = zeros(nm, nsim);
            SeisPred = zeros(nd*ntheta, nsim);
            for j=1:nsim  
                msim = CorrelatedSimulation(mprior, sigma0, sigmatime);
                Vpsim(:,j) = msim(:, 1);
                Vssim(:,j) = msim(:, 2);
                Rhosim(:,j) = msim(:, 3);  
                [SeisPred(:,j), ~] = SeismicModel(Vpsim(:,j), Vssim(:,j), Rhosim(:,j), Time, theta, wavelet);
            end
        
            %% ESMDA seismic inversion
            niter = 4;
            alpha = niter;  % sum 1/alpha = 1
            PriorModels = [Vpsim; Vssim; Rhosim];
            SeisData = [Snear; Smid; Sfar];
            PostModels = PriorModels;
            for j=1:niter
                [PostModels, ~] = EnsembleSmootherMDA(PostModels, SeisData, SeisPred, alpha, sigmaerr);
                Vppost = PostModels(1:nm,:);
                Vspost = PostModels(nm+1:2*nm,:);
                Rhopost = PostModels(2*nm+1:end,:); 
                for k=1:nsim 
                    [SeisPred(:,k), ~] = SeismicModel(Vppost(:,k), Vspost(:,k), Rhopost(:,k), Time, theta, wavelet);
                end
            end
        
            ESMDA_DATA = real(PostModels(1:nm, :) .* PostModels(2*nm+1:end, :));
            stds_esmda(:, (i -1) * nsim + 1:i*nsim) = ESMDA_DATA(nsim:end-nsim, :);
    
        end
        save('stds_esmda', 'stds_esmda');
    else 
        stds_esmda = load('stds_esmda.mat').stds_esmda;
    end
end

