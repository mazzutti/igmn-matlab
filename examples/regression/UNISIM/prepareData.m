function [trainData, testData, cubeSize] = prepareData(nSim, showPlots)
    %% Read models from petrel 
    addpath(genpath('utils'))
    addpath(genpath('SeReM'))

    criticalporo = 0.3;
    
    POR = readNPY('data/UNISIM/POR.npy');
    POR(POR>0.4) = 0.399;
    POR(POR<=0) = 0.02;
    SW13 = readNPY('data/UNISIM/SW_2013.npy');
    SW13(isnan(SW13)) = 0.9;
    SW13(isnan(POR)) = nan;
    SW24 = readNPY('data/UNISIM/SW_2024.npy');
    SW24(isnan(SW24)) = 0.9;
    SW24(isnan(POR)) = nan;
    
    % 3D CASE:
    %Phi = POR;
    %Sw13 = SW13;
    %Sw24 = SW24
    
    % 2D CASE:
    Phi = POR(:,:,20);
    Sw13 = SW13(:,:,20);
    Sw24 = SW24(:,:,20);
    
    %% Running RPM to simulate the observed data (elastic properties) for inversion 
    std_vp = 50;
    std_vs = 25;
    std_rho = 0.05;
    %correlation function to add an spatial correlated noise
    if length(size(Sw24)) == 2
        correlation_function = construct_correlation_function_beta(20, 10, Phi, 2);
    else
        correlation_function = construct_correlation_function_beta(2, 10, Phi, 2);
    end
    
    [Vp, Vs, Rho] = RPM_unisim(Phi, Sw13, criticalporo );
    % Adding noise
    Vp = Vp + std_vp*FFT_MA_3D(correlation_function, randn(size(Vp)));
    Vs = Vs + std_vs*FFT_MA_3D(correlation_function, randn(size(Vp)));
    Rho = Rho + std_rho*FFT_MA_3D(correlation_function, randn(size(Vp)));
    Ip13 = Vp.*Rho;
    VPVS13 = Vp./Vs;
    
    [Vp, Vs, Rho] = RPM_unisim(Phi, Sw24, criticalporo );
    
    % Adding noise
    Vp = Vp + std_vp*FFT_MA_3D(correlation_function, randn(size(Vp)));
    Vs = Vs + std_vs*FFT_MA_3D(correlation_function, randn(size(Vp)));
    Rho = Rho + std_rho*FFT_MA_3D(correlation_function, randn(size(Vp)));
    Ip24 = Vp.*Rho;
    VPVS24 = Vp./Vs;
    
    if showPlots
        %% FIGURES
        
        % data
        figure;
        ax1 = subplot(221);
        imagesc(Ip13);
        clim([4000 16000]);
        title('IP13');
        ax2 = subplot(222);
        imagesc(VPVS13);
        clim([1.35 1.75]);
        title('VPVS13');
        ax3 = subplot(223);
        imagesc(Ip24);
        clim([4000 16000]);
        title('IP24');
        ax4 = subplot(224);
        imagesc(VPVS24);
        clim([1.35 1.75]);
        title('VPVS24');
        linkaxes([ax1, ax2, ax3, ax4], 'xy');
        
        figure;
        subplot(131);
        scatter(Ip24(:), VPVS24(:), 25, Sw24(:), 'filled');
        grid;
        subplot(132);
        scatter(Phi(:), Ip24(:), 25, Sw24(:), 'filled');
        grid;
        subplot(133);
        scatter(Sw24(:), VPVS24(:), 25, Phi(:), 'filled');
        grid;
        
        figure;
        subplot(121);
        imagesc(Sw24);
        subplot(122);
        imagesc(VPVS24 - VPVS13);
    end

    
    %% PRIOR SAMPLING
    % Porous and no porous
    
    Phi_train = 0.1 + 0.05*randn(nSim/2,1);
    Phi_train = [Phi_train ; 0.25 + 0.05*randn(nSim/2,1)];
    sw_train13 = rand(nSim,1);
    sw_train24 = rand(nSim,1);
    
    % Include Shale
    Phi_train = [ Phi_train ; 0.02 + 0.005*randn(nSim/2,1) ];
    sw_train13 = [ sw_train13 ; 0.9 + 0.02*randn(nSim/2,1) ];
    sw_train24 = [ sw_train24 ; 0.9 + 0.02*randn(nSim/2,1) ];
    Phi_train(Phi_train<0) = 0.001;
    Phi_train(Phi_train>0.4) = 0.4;
    sw_train13(sw_train13>1) = 0.999;
    sw_train24(sw_train24>1) = 0.999;
    
    % Simulate observed data (elastic properties) with noise
    [Vp, Vs, Rho] = RPM_unisim(Phi_train, sw_train13, criticalporo );
    Vp = Vp + std_vp*randn(size(Vp));
    Vs = Vs + std_vs*randn(size(Vs));
    Rho = Rho + std_rho*randn(size(Rho));
    Ip_train13 = Vp.*Rho;
    VPVS_train13 = Vp./Vs;
    
    % Simulate observed data (elastic properties) with noise
    [Vp, Vs, Rho] = RPM_unisim(Phi_train, sw_train24, criticalporo );
    Vp = Vp + std_vp*randn(size(Vp));
    Vs = Vs + std_vs*randn(size(Vs));
    Rho = Rho + std_rho*randn(size(Rho));
    Ip_train24 = Vp.*Rho;
    VPVS_train24 = Vp./Vs;
    
    % Final training data:
    mtrain = [Phi_train , sw_train13, sw_train24];
    dtrain = [Ip_train13, VPVS_train13, Ip_train24, VPVS_train24];

    %% INVERSION Train Data
    trainData = [dtrain, mtrain];
    
    if showPlots
        figure
        subplot(211)
        histogram(POR,'Normalization','probability')
        set(gca,'YScale','log')
        xlabel('Reference Porosity')
        title('Training vs reference')
        subplot(212)
        histogram(Phi_train,'Normalization','probability')
        set(gca,'YScale','log')
        xlabel('Training Porosity')
        
        
        figure
        subplot(121)
        plot(Ip_train13,VPVS_train13,'k.')
        hold all
        plot(Ip13, VPVS13,'b.')
        title('Training vs reference')
        subplot(122)
        plot(Ip_train24,VPVS_train24,'k.')
        hold all
        plot(Ip24, VPVS24,'b.')
        
        figure
        subplot(121)
        plot(Phi_train,sw_train13,'k.')
        hold all
        plot(Phi, Sw13,'b.')
        title('Training vs reference')
        subplot(122)
        plot(Phi_train, sw_train24,'k.')
        hold all
        plot(Phi, Sw24,'b.')
    end
    
    %% INVERSION Teste Data
    
    testData = [Ip13(:), VPVS13(:), Ip24(:), VPVS24(:), Phi(:), Sw13(:), Sw24(:)];
    cubeSize = size(Phi);
end

