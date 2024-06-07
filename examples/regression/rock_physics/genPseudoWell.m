function [modelData, wellData] = genPseudoWell(nSim, useFacies, showPlots, exportPlots)


    % Synthetic data configs
    dataPath = 'data/pseudowell_2856667402688.las';
    inputsStdMultiplyier = 5;
    stdVp = 100 * inputsStdMultiplyier;
    stdVs = 50 * inputsStdMultiplyier;
    stdRho = 0.05 * inputsStdMultiplyier;
   
    
    outputsStdMultiplyier = 0;
    stdPhi = 0.01 * outputsStdMultiplyier;
    stdClay = 0.01 * outputsStdMultiplyier;
    stdSw = 0.01 * outputsStdMultiplyier;
    
    well = read_las_file(dataPath);

    Depth = well.curves(:, 1);
    facies = well.curves(:, 2);
    Phi = well.curves(:, 3); Phi(Phi <= 0.001) = 0.001;
    v_clay = well.curves(:, 5); v_clay(v_clay <= 0.001) = 0.001;
    sw = well.curves(:, 4); sw (sw <= 0.001) = 0.001;

    correlation_function = construct_correlation_function_beta(30, 1, Phi, 2);

    Phi = Phi + stdPhi * FFT_MA_3D(correlation_function, randn(size(Phi)));
    v_clay = v_clay + stdClay * FFT_MA_3D(correlation_function, randn(size(v_clay)));
    sw = sw + stdSw  *FFT_MA_3D(correlation_function, randn(size(sw)));

    Phi(Phi <= 0.001) = 0.001;
    v_clay(v_clay <= 0.001) = 0.001;
    sw (sw <= 0.001) = 0.001;

    Phi(Phi >= 0.4) = 0.4;
    v_clay(v_clay >= 0.8) = 0.8;
    sw (sw >= 1) = 0.99;
    
    [Vp, Vs, Rho] = RPM(Phi ,v_clay, sw); 
    Vp = 1000 * Vp; 
    Vs = 1000 * Vs;
    
    Vp = Vp + stdVp * FFT_MA_3D(correlation_function, randn(size(Vp)));
    Vs = Vs + stdVs * FFT_MA_3D(correlation_function, randn(size(Vp)));
    Rho = Rho + stdRho * FFT_MA_3D(correlation_function, randn(size(Vp)));

    
    if showPlots
        colormap('jet');
        f = tiledlayout('horizontal', 'Padding', 'none', 'TileSpacing', 'tight');
        AI = Vp.*Rho;
        nexttile;
        gscatter(Phi, Vp, facies, [], '+');
        xlabel('Porosity'); ylabel('Vp');
        legend('Facie I', 'Facie II', 'Facie III');
        nexttile;
        gscatter(AI, Vp./Vs, clusterdata(sw, 2), [], '+');
        xlabel('AI'); ylabel('Vp/Vs');
        legend('Water Sat. I', 'Water Sat. II');
        nexttile;
        gscatter(v_clay, Rho, facies, [], '+');
        xlabel('Clay Vol.'); ylabel('Rho');
        legend('Facie I', 'Facie II', 'Facie III');
        
        if exportPlots
            exportgraphics(f, 'toy_welldata.pdf', 'BackgroundColor', 'none', 'Resolution', 1000);
        end
        figure;
        f = tiledlayout('horizontal', 'Padding', 'none', 'TileSpacing', 'tight');
        nexttile;
        plot_histogram(AI, facies);
        legend('Facie I', 'Facie II', 'Facie III');
        xlabel('AI');
        title('');
        nexttile;
        plot_histogram(Vp./Vs, facies);
        legend('Facie I', 'Facie II', 'Facie III');
        xlabel('Vp/Vs');
        title('');
        if exportPlots
            exportgraphics(f, 'toy_welldata_histogram.pdf', 'BackgroundColor', 'none', 'Resolution', 1000)
        end
    end

    %% PRIOR SAMPLING
    mtrain = [];
    dtrain = [];
    for facie = 1:length(unique(facies))    
        idx_facie = (facies==facie);
        Phi_train = mean(Phi(idx_facie)) + std(Phi(idx_facie))*randn(nSim,1);
        v_clay_train = mean(v_clay(idx_facie)) + std(v_clay(idx_facie))*randn(nSim,1);
        sw_train = mean(sw(idx_facie)) + std(sw(idx_facie))*randn(nSim,1);        
        mtrain = [mtrain; Phi_train, v_clay_train, sw_train]; %#ok<*AGROW>
        [Vp_train, Vs_train, Rho_train] = RPM(Phi_train, v_clay_train, sw_train); 
        Vp_train = 1000*Vp_train; 
        Vs_train = 1000*Vs_train;
        if useFacies
            facie_train = zeros(nSim, 1) + facie;
            dtrain = [dtrain; facie_train, Vp_train, Vs_train, Rho_train];   
        else
            dtrain = [dtrain; Vp_train, Vs_train, Rho_train]; 
        end
    end
    modelData = [dtrain,  mtrain];
    wellData = [Depth, facies, Vp, Vs, Rho, Phi, v_clay, sw];
end



