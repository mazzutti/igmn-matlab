% loadData - Load and process data for UNISIM Time-Lapse analysis.
% 
% This function loads reference data, generates plots for visualization, and
% prepares training data for regression models. It also simulates observed
% elastic properties with noise and organizes the data into training and
% well datasets.
% 
% Inputs:
%     nSim        - Number of simulations for prior sampling.
%     showPlots   - Boolean flag to indicate whether to display plots.
%     exportPlots - Boolean flag to indicate whether to export plots as files.
% 
% Outputs:
%     modelData   - Combined training data matrix containing elastic properties
%                   and petrophysical properties.
%     wellData    - Well data matrix containing reference elastic and
%                   petrophysical properties.
%     WELLS       - Structure containing well information (coordinates and names).
%     I           - Number of rows in the reference property grid.
%     J           - Number of columns in the reference property grid.
%     refFig      - Figure handle for the reference petrophysical properties plot.
% 
% Notes:
%     - The function reads data from 'data/data_CAGEO.mat'.
%     - If 'showPlots' is true, it generates and optionally exports plots for
%       reference models, elastic properties, and training data histograms.
%     - The function uses a rock physics model (RPM_unisim) to simulate elastic
%       properties based on porosity and water saturation.
%     - Training data includes both porous and non-porous samples, as well as
%       shale samples.
%     - Noise is added to the simulated elastic properties to mimic observed data.
% 
% Dependencies:
%     - Requires the 'data/data_CAGEO.mat' file for input data.
%     - Uses external functions such as 'RPM_unisim', 'plot_wells', and
%       'generate_histograms'.
% 
% Example:
%     [modelData, wellData, WELLS, I, J, refFig] = loadData(1000, true, false);
function [modelData, wellData, WELLS, I, J, refFig] = loadData(nSim, showPlots, exportPlots) %#ok<*STOUT>
   
    %% read UNISIM
    dataPath = 'data/UNISIM-TimeLapse/data_CAGEO.mat';
    assertFileAvailable(dataPath)
    load(dataPath); %#ok<LOAD>

    if showPlots
        % figure;
        % imagesc(Sw24);
        % hold all;
        % for well=1:length(WELLS) %#ok<*NODEF>
        %     % Cropping
        %     plot(WELLS(well).j,WELLS(well).i,'r+','LineWidth',2);
        %     text(WELLS(well).j,WELLS(well).i,WELLS(well).name);
        % end
        % hold off;

        % generate_histograms(referece_variables)
        % generate_histograms([Phi(:) Sw13(:) Sw24(:) Ip13(:) VPVS13(:) Ip24(:) VPVS24(:)]); %#ok<*USENS>
        % sgtitle('Joint distribution of the reference models');

        Phi(Phi < 0.01) = 0.01;
        Sw13(Sw13 < 0.01) = 0.01;
        Sw24(Sw24 < 0.01) = 0.01;
    
        %%%% FIGURE - Reference petrophysical properties
        set(0, 'DefaultAxesFontSize', 12, 'defaultTextInterpreter', 'none') 
        refFig = figure('units', 'normalized', 'outerposition', [0.225 0.1 0.55 0.8]);
        tiledlayout(refFig, 3, 3, 'Padding', 'compact', 'TileSpacing', 'compact');
        ax = nexttile;
        imagesc(Phi);
        clim(ax, [0 0.35]);
        hold all;
        plot_wells(WELLS);
        title('\textbf{(a) - \boldmath{$\phi$} - Reference}', 'Interpreter', 'latex');
        ylabel('I', 'FontWeight', 'bold');
        xticks([]);
        % xlabel('J', 'FontWeight', 'bold');
        % grid;
        colorbar('XTick', 0:0.05:0.35);
        colormap([1, 1, 1; parula]);
        nexttile;
        imagesc(Sw13);
        clim([0 0.8]);
        hold all;
        plot_wells(WELLS);
        title('\textbf{(b) - \boldmath{$S_{w~(2013)}$} - Reference}', 'Interpreter', 'latex');
        yticks([]);
        xticks([]);
        % xlabel('J', 'FontWeight', 'bold');
        % grid;
        colorbar('XTick', 0:0.1:0.8);
        colormap([1, 1, 1; parula]);
        nexttile;
        imagesc(Sw24);
        clim([0 0.8]);
        hold all;
        plot_wells(WELLS);
        title('\textbf{(c) - \boldmath{$S_{w~(2024)}$} - Reference}', 'Interpreter', 'latex');
        yticks([]);
        xticks([]);
        % xlabel('J', 'FontWeight', 'bold');
        % grid;
        colorbar('XTick', 0:0.1:0.8);
        colormap([1, 1, 1; parula]);
        % if exportPlots
        %     exportgraphics(f, 'figs/reference_models.pdf', 'BackgroundColor', 'none', 'Resolution', 1000);
        % else
        %     sgtitle('Reference models', 'FontWeight', 'bold');
        % end
        % 
        % FIGURE - Elastic properties
        f = figure('units', 'normalized', 'outerposition', [0.28 0.26 0.38 0.62]);
        tiledlayout(f, 2, 2, 'Padding', 'compact', 'TileSpacing', 'compact');
        nexttile;
        imagesc(Ip13);
        % clim([0 0.35])
        hold all;
        plot_wells(WELLS); %#ok<*NODEF>
        title('\textbf{(a) - \boldmath{$I_{p{~(2013)}}$}}', 'Interpreter', 'latex');
        ylabel('I', 'FontWeight', 'bold');
        % grid;
        colorbar;
        colormap([1, 1, 1; parula]);
        nexttile;
        imagesc(VPVS13);
        clim([1.35 1.7]);
        hold all;
        plot_wells(WELLS);
        title('\textbf{(b) - \boldmath{$\alpha/\beta_{~(2013)}$}}', 'Interpreter', 'latex');
        yticks([]);
        % grid;
        colorbar('XTick', 1.35:0.05:1.7);
        colormap([1, 1, 1; parula]);
        nexttile;
        imagesc(Ip24);
        hold all;
        plot_wells(WELLS);
        title('\textbf{(c) - \boldmath{$I_{p{~(2024)}}$}}', 'Interpreter', 'latex');
        ylabel('I', 'FontWeight', 'bold');
        xlabel('J', 'FontWeight', 'bold');
        colorbar;
        colormap([1, 1, 1; parula]);
        nexttile;
        imagesc(VPVS24);
        clim([1.35 1.7]);
        hold all;
        plot_wells(WELLS);
        title('\textbf{(d) - \boldmath{$\alpha/\beta_{~(2024)}$}}', 'Interpreter', 'latex');
        xlabel('J', 'FontWeight', 'bold');
        yticks([]);
        colorbar('XTick', 1.35:0.05:1.7);
        colormap([1, 1, 1; parula]);
        if exportPlots
            if ~exist('./figs', 'dir')
                mkdir('./figs')
            end
            exportgraphics(f, 'figs/elastic_properties.pdf', 'BackgroundColor', 'none', 'Resolution', 1000);
        else
            sgtitle('Elastic properties', 'FontWeight', 'bold');
        end
    end

    %% PRIOR SAMPLING
    %Porous and no porous
    Phi_train = 0.1 + 0.05 * randn(nSim/2,1);
    Phi_train = [Phi_train ; 0.25 + 0.05 * randn(nSim/2,1)];
    sw_train13 = rand(nSim,1);
    sw_train24 = rand(nSim,1);
    
    % Include Shale
    Phi_train = [Phi_train ; 0.02 + 0.005*randn(nSim/2,1)];
    sw_train13 = [sw_train13 ; 0.9 + 0.02*randn(nSim/2,1)];
    sw_train24 = [sw_train24 ; 0.9 + 0.02*randn(nSim/2,1)];
    Phi_train(Phi_train < 0) = -Phi_train(Phi_train < 0);
    Phi_train(Phi_train > 0.4) = Phi_train(Phi_train > 0.4) - (Phi_train(Phi_train > 0.4) - 0.4);
    sw_train13(sw_train13 > 1) = sw_train13(sw_train13 > 1) - (sw_train13(sw_train13 > 1) - 1);
    sw_train24(sw_train24 > 1) = sw_train24(sw_train24 > 1) - (sw_train24(sw_train24 > 1) - 1);
    
    % Simulate observed data (elastic properties) with noise
    [Vp, Vs, Rho] = RPM_unisim(Phi_train, sw_train13, criticalporo);
    Vp = Vp + std_vp * randn(size(Vp));
    Vs = Vs + std_vs * randn(size(Vs));
    Rho = Rho + std_rho * randn(size(Rho));
    Ip_train13 = Vp .* Rho;
    VPVS_train13 = Vp ./ Vs;
    
    % Simulate observed data (elastic properties) with noise
    [Vp, Vs, Rho] = RPM_unisim(Phi_train, sw_train24, criticalporo);
    Vp = Vp + std_vp * randn(size(Vp));
    Vs = Vs + std_vs * randn(size(Vs));
    Rho = Rho + std_rho * randn(size(Rho));
    Ip_train24 = Vp .* Rho;
    VPVS_train24 = Vp ./ Vs;
    
    % Final training data:
    mtrain = [Phi_train, sw_train13, sw_train24];
    dtrain = [Ip_train13, VPVS_train13, Ip_train24, VPVS_train24];
    if showPlots
        variableRanges = [3860, 1, 3810, 1, 0, 0, 0; 16950, 2, 17265, 2, 0.4, 1, 1];
        variableNames = {'\boldmath{I$_{p~(2013)}$}     ', '\boldmath{$\alpha/\beta_{~(2013)}$}',  ....
            '\boldmath{I$_{p~(2024)}$}     ', '\boldmath{$\alpha/\beta_{~(2024)}$}', '\boldmath{$\phi$}', ...
            '\boldmath{S$_{w~(2013)}$}' , '\boldmath{S$_{w~(2024)}$}'};
        f = generate_histograms([dtrain, mtrain], variableNames, [0 16], variableRanges);
        if exportPlots
            exportgraphics(f, 'figs/traindata_timelapse_histogram.pdf', 'BackgroundColor', 'none', 'Resolution', 1000);
        end
    end
    
    modelData = [dtrain, mtrain];
    wellData = [Ip13(:), VPVS13(:), Ip24(:), VPVS24(:), Phi(:), Sw13(:), Sw24(:)]; %#ok<*USENS>
    [I, J] = size(Phi);
end