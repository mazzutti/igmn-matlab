function [modelData, wellData] = genPseudoWell(nSim, showPlots, exportPlots)


    % Synthetic data configs
    load 'data/data4.mat'; %#ok<LOAD>

    if showPlots
        colormap('jet');
        f = tiledlayout('horizontal', 'Padding', 'none', 'TileSpacing', 'tight');
        AI = Vp.*Rho;
        nexttile;
        gscatter(Phi, Vp, Facies, [], '+');
        xlabel('Porosity'); ylabel('Vp');
        legend('Facie I', 'Facie II');
        nexttile;
        gscatter(AI, Vp./Vs, clusterdata(Sw, 2), [], '+');
        xlabel('AI'); ylabel('Vp/Vs');
        legend('Water Sat. I', 'Water Sat. II');
        nexttile;
        gscatter(Clay, Rho, Facies, [], '+');
        xlabel('Clay Vol.'); ylabel('Rho');
        legend('Facie I', 'Facie II');
        
        if exportPlots
            exportgraphics(f, 'figs/welldata.pdf', 'BackgroundColor', 'none', 'Resolution', 1000);
        end
        figure;
        f = tiledlayout('horizontal', 'Padding', 'none', 'TileSpacing', 'tight');
        nexttile;
        plot_histogram(AI, Facies);
        legend('Facie I', 'Facie II');
        xlabel('AI');
        title('');
        nexttile;
        plot_histogram(Vp./Vs, Facies);
        legend('Facie I', 'Facie II');
        xlabel('Vp/Vs');
        title('');
        if exportPlots
            exportgraphics(f, 'figs/welldata_histogram.pdf', 'BackgroundColor', 'none', 'Resolution', 1000)
        end
    end

    
    %% Monte carlo sampling of the joint distribution
    % Prior of petrophysical properties p(r) with 2 facies:
    petroSim = [];
    for facie = 1:length(unique(Facies))
        MU = mean([Phi(Facies==facie) Clay(Facies==facie) Sw(Facies==facie) ]) ;
        COV = cov([Phi(Facies==facie) Clay(Facies==facie) Sw(Facies==facie) ]);
        if facie == 1
            MU(3) = 0.2;
        end
        facie_train = zeros(nSim(facie), 1) + facie;
        petroSim = [petroSim; mvnrnd(MU, COV, nSim(facie)), facie_train];    %#ok<AGROW>
    end
    % Additional facies for brine sand
    MU = [0.24 0.07 0.95];
    COV = diag([ 0.017 0.06 0.02 ]).^2;
    petroSim = [ petroSim; mvnrnd(MU, COV, nSim(3)), zeros(nSim(3), 1) + 3];
    Phi_sim = petroSim(:,1);
    Clay_sim = petroSim(:,2);
    Sw_sim = petroSim(:,3);
    Phi_sim(Phi_sim<0)=0; Phi_sim(Phi_sim>0.4)=0.4;
    Clay_sim(Clay_sim<0)=0; Clay_sim(Clay_sim>0.8)=0.8;
    Sw_sim(Sw_sim<0)=0.02; Sw_sim(Sw_sim>1)=0.98;
    
    %% Rock-physics model - Linearization base on the logs
    % Sampling elastic properties from p(m|r):
    nd = size(Phi,1);
    nv = 3;
    R = zeros(nd,nv+1);
    X = [Phi Clay Sw ones(size(Phi))];
    R(1,:) = regress(Vp,X); 
    R(2,:) = regress(Vs,X); 
    R(3,:) = regress(Rho,X); 
    [Vpsim, Vssim, Rhosim] = LinearizedRockPhysicsModel(Phi_sim, Clay_sim, Sw_sim, R);
    
    noise_perc = 0.05;
    Vpsim = Vpsim + noise_perc * std(Vpsim) * randn(size(Vpsim));
    Vssim = Vssim + noise_perc * std(Vssim) * randn(size(Vssim));
    Rhosim = Rhosim + noise_perc * std(Rhosim) * randn(size(Rhosim));
    
    % training dataset
    mtrain = [Phi_sim Clay_sim Sw_sim, petroSim(:, 4)];
    dtrain = [Vpsim Vssim Rhosim];
    
    if showPlots
        generate_histograms([mtrain dtrain])
    end

    NCoef = 110;
    Ts = 4;
    lowFreqFilter = @(x) lowPassFilter(x, Ts, NCoef, 8); % 6 a 8
    lowFreqWellData = [lowFreqFilter(Vp)', lowFreqFilter(Vs)', lowFreqFilter(Rho)'];
    lowFreqTrainData = [lowFreqFilter(dtrain(:, 1))', ...
        lowFreqFilter(dtrain(:, 2))', lowFreqFilter(dtrain(:, 3))'];

    modelData = [mtrain(:, end), dtrain, lowFreqTrainData, mtrain(:, 1:end-1)];
    wellData = [Depth, Facies, Vp, Vs, Rho, lowFreqWellData, Phi, Clay, Sw];
end



