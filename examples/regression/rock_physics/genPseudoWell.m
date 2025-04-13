% genPseudoWell - Generates synthetic pseudo-well data for rock physics analysis.
%
% Syntax:
%   [modelData, wellData] = genPseudoWell(nSim, useFacies, showPlots, exportPlots)
%
% Inputs:
%   nSim        - Number of simulations to generate for each facies.
%   useFacies   - Logical flag indicating whether to include facies information in the output.
%   showPlots   - Logical flag indicating whether to display plots of the generated data.
%   exportPlots - Logical flag indicating whether to export the generated plots as PDF files.
%
% Outputs:
%   modelData - Matrix containing the generated model data, including simulated inputs and outputs.
%               Columns include facies (if useFacies is true), Vp, Vs, Rho, Phi, v_clay, and sw.
%   wellData  - Matrix containing the original well data, including depth, facies, Vp, Vs, Rho, Phi, v_clay, and sw.
%
% Description:
%   This function generates synthetic pseudo-well data based on a given LAS file containing well log data.
%   It applies random perturbations to porosity (Phi), clay volume (v_clay), and water saturation (sw)
%   using a correlation function and FFT-based moving average. The function also computes Vp, Vs, and Rho
%   using a rock physics model (RPM). Optionally, it visualizes the generated data and exports the plots.
%
% Example:
%   [modelData, wellData] = genPseudoWell(100, true, true, false);
%
% Dependencies:
%   - read_las_file: Reads LAS file data.
%   - construct_correlation_function_beta: Constructs a correlation function for perturbations.
%   - FFT_MA_3D: Applies FFT-based moving average for random field generation.
%   - RPM: Computes Vp, Vs, and Rho using a rock physics model.
%   - clusterdata: Performs clustering on water saturation data.
%   - plot_histogram: Plots histograms for given data.
%
% Notes:
%   - The function assumes the LAS file is located at 'data/rock-physics/pseudowell_2856667402688.las'.
%   - The function applies constraints to Phi, v_clay, and sw to ensure realistic values.
%   - The generated plots include scatter plots and histograms for visualizing the data.
function [modelData, wellData] = genPseudoWell(nSim, useFacies, showPlots, exportPlots)


    % Synthetic data configs
    dataPath = 'data/rock-physics/pseudowell_2856667402688.las';
    assertFileAvailable(dataPath)
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
    facies = well.curves(:, 2); % 1 - shale
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
    
    [Vp, Vs, Rho] = RPM(Phi, v_clay, sw); 
    Vp = 1000 * Vp; 
    Vs = 1000 * Vs;
    
    Vp = Vp + stdVp * FFT_MA_3D(correlation_function, randn(size(Vp)));
    Vs = Vs + stdVs * FFT_MA_3D(correlation_function, randn(size(Vp)));
    Rho = Rho + stdRho * FFT_MA_3D(correlation_function, randn(size(Vp)));

    
    colors = parula(length(unique(facies)));
    facie_colors = nan(size(facies, 1), 3);
    facie_colors(facies == 1, :) = repmat(colors(1, :), sum(facies == 1), 1);
    facie_colors(facies == 2, :) = repmat(colors(2, :), sum(facies == 2), 1);
    facie_colors(facies == 3, :) = repmat(colors(3, :), sum(facies == 3), 1);

    colors = parula(2);
    sw_cluster = clusterdata(sw, 2);
    sw_colors = nan(size(sw_cluster, 1), 3);
    sw_colors(sw_cluster == 1, :) = repmat(colors(1, :), sum(sw_cluster == 1), 1);
    sw_colors(sw_cluster == 2, :) = repmat(colors(2, :), sum(sw_cluster == 2), 1);
    
    if showPlots
        % colormap(parula);
        f = tiledlayout('horizontal', 'Padding', 'none', 'TileSpacing', 'tight');
        AI = Vp.*Rho;
        nexttile;
        for i = unique(facies)'
            indexes = facies == i;
            scatter(Phi(indexes), Vp(indexes), 40, facies(indexes), 'Marker', '+');
            hold on;
        end
        hold off;
        xlabel('Porosity'); ylabel('Vp');
        legend('Shale', 'Water Sand', 'Oil Sand');
        nexttile;
        gscatter(AI, Vp./Vs, sw_colors, [], '+');
        xlabel('AI'); ylabel('Vp/Vs');
        legend('Water Sat. I', 'Water Sat. II');
        nexttile;
        for i = unique(facies)'
            indexes = facies == i;
            scatter(v_clay(indexes), Rho(indexes), 40, facies(indexes), 'Marker', '+');
            hold on;
        end
        xlabel('Clay Vol.'); ylabel('Rho');
        legend('Shale', 'Water Sand', 'Oil Sand');
        
        if exportPlots
            exportgraphics(f, 'toy_welldata.pdf', 'BackgroundColor', 'none', 'Resolution', 1000);
        end
        figure;
        f = tiledlayout('horizontal', 'Padding', 'none', 'TileSpacing', 'tight');
        nexttile;
        plot_histogram(AI, facies);
        legend('Shale', 'Water Sand', 'Oil Sand');
        xlabel('AI');
        title('');
        nexttile;
        plot_histogram(Vp./Vs, facies);
        legend('Shale', 'Water Sand', 'Oil Sand');
        xlabel('Vp/Vs');
        title('');
        if exportPlots
            exportgraphics(f, 'toy_welldata_histogram.pdf', 'BackgroundColor', 'none', 'Resolution', 1000)
        end
    end

    %% PRIOR SAMPLING
    mtrain = [];
    dtrain = [];

    % nv = 3;
    % R = zeros(1, nv+1);
    % X = [Phi v_clay sw, ones(size(Phi))];
    % R(1,:) = regress(Vp, X); 
    % R(2,:) = regress(Vs, X); 
    % R(3,:) = regress(Rho, X);

    for facie = 1:length(unique(facies))    
        idx_facie = (facies==facie);
        Phi_train = mean(Phi(idx_facie)) + std(Phi(idx_facie))*randn(nSim,1);
        v_clay_train = mean(v_clay(idx_facie)) + std(v_clay(idx_facie))*randn(nSim,1);
        sw_train = mean(sw(idx_facie)) + std(sw(idx_facie))*randn(nSim,1);        
        mtrain = [mtrain; Phi_train, v_clay_train, sw_train]; %#ok<*AGROW>

        % [Vp_train, Vs_train, Rho_train] = LinearizedRockPhysicsModel(Phi_train, v_clay_train, sw_train, R);

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



