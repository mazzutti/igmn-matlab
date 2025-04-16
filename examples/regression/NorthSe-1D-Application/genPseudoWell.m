% genPseudoWell - Generates synthetic pseudo-well data for regression analysis.
%
% Syntax:
%   [modelData, wellData] = genPseudoWell(nSim, showPlots, useFacies, exportPlots)
%
% Inputs:
%   nSim       - Array specifying the number of simulations for each facies.
%   showPlots  - Logical flag to indicate whether to display plots (true/false).
%   useFacies  - Logical flag to include facies information in the output (true/false).
%   exportPlots - Logical flag to export generated plots as PDF files (true/false).
%
% Outputs:
%   modelData  - Matrix containing the generated model data. If `useFacies` is true,
%                facies information is included as the first column.
%   wellData   - Matrix containing the original well data, including depth, facies,
%                and petrophysical properties (Vp, Vs, Rho, Phi, Clay, Sw).
%
% Description:
%   This function generates synthetic pseudo-well data by sampling petrophysical
%   properties and applying a rock-physics model. It supports visualization of
%   the generated data through scatter plots and histograms, and optionally
%   exports the plots as PDF files. The function also allows for Monte Carlo
%   sampling of the joint distribution of petrophysical properties for different
%   facies.
%
% Example:
%   % Generate pseudo-well data with 100 simulations per facies, display plots,
%   % include facies information, and export plots as PDFs.
%   nSim = [100, 100, 100];
%   showPlots = true;
%   useFacies = true;
%   exportPlots = true;
%   [modelData, wellData] = genPseudoWell(nSim, showPlots, useFacies, exportPlots);
%
% Notes:
%   - The function requires the input data file 'data/data4.mat' to be present
%     in the specified path.
%   - The function uses a linearized rock-physics model to compute elastic
%     properties (Vp, Vs, Rho) from petrophysical properties (Phi, Clay, Sw).
%   - The generated plots include scatter plots and histograms for visualizing
%     the relationships between petrophysical and elastic properties.
%
% See also:
%   mvnrnd, regress, clusterdata, exportgraphics
function [modelData, wellData] = genPseudoWell(nSim, showPlots, useFacies, exportPlots)

    % Synthetic data configs
    dataPath =  'data/NorthSe-1D-Application/data4.mat';
    assertFileAvailable(dataPath)
    load(dataPath); %#ok<LOAD>

    Vp = Vp .* 1000; %#ok<*NODEF>
    Vs = Vs .* 1000;

    HeightScaleFactor = 0.9;

    legs = [];

    if showPlots
        set(0, 'DefaultAxesFontSize', 22, 'defaultTextInterpreter', 'latex');
        f = figure('units', 'normalized', 'outerposition', [0.26 0.27 0.48 0.62]);
        tiledlayout(f, 2, 3, 'Padding', 'tight', 'TileSpacing', 'tight');
        AI = Vp.*Rho;
        ax = nexttile;
        gscatter(Phi, Vp, Facies, [], '+');
        xlabel('\boldmath{$\phi$}', 'FontSize', 22); 
        ylabel('\boldmath{$\alpha$}', 'FontSize', 22);
        leg = legend('\emph{Oil Sand}', '\emph{Shale}', 'Location', 'southwest', 'Interpreter', 'latex', 'FontSize', 12);
        leg.ItemTokenSize = [leg.ItemTokenSize(2)/2, leg.ItemTokenSize(2)/2];
        legs = [legs, leg];
        ax.YAxis.Exponent = 3;
        title('(a)', 'FontWeight', 'bold', 'Interpreter', 'none', 'FontSize', 22);
        ax = nexttile;
        gscatter(Phi, Vs, Facies, [], '+');
        xlabel('\boldmath{$\phi$}', 'FontSize', 22)
        ylabel('\boldmath{$\beta$}', 'FontSize', 22);
        leg = legend('\emph{Oil Sand}', '\emph{Shale}', 'Location', 'northeast', 'Interpreter', 'latex',  'FontSize', 12);
        leg.ItemTokenSize = [leg.ItemTokenSize(2)/2, leg.ItemTokenSize(2)/2];
        legs = [legs, leg];
        ax.YAxis.Exponent = 3;
        title('(b)', 'FontWeight','bold', 'Interpreter', 'none', 'FontSize', 22);
        ax = nexttile;
        plot_histogram(AI, Facies, '\boldmath{$Frequency$}');
        leg = legend('\emph{Oil Sand}', '\emph{Shale}', 'Location', 'northeast', 'Interpreter', 'latex',  'FontSize', 12);
        leg.ItemTokenSize = [leg.ItemTokenSize(2)/2, leg.ItemTokenSize(2)/2];
        legs = [legs, leg];
        xlabel('\boldmath{$AI$}', 'FontSize', 22);
        title('(c)', 'FontWeight', 'bold', 'Interpreter', 'none', 'FontSize', 22); 
        ax.XAxis.Exponent = 4;
        ax = nexttile;
        gscatter(AI, Vp./Vs, clusterdata(Sw, 2), [], '+');
        xlabel('\boldmath{$AI$}', 'FontSize', 22); 
        ylabel('\boldmath{$\alpha/\beta$}', 'FontSize', 22);
        leg = legend('\boldmath{$S_w$} (\emph{Oil Sand})', ...
            '\boldmath{$S_w$} (\emph{Shale})', 'Location', 'southwest', 'Interpreter', 'latex',  'FontSize', 12);
        leg.ItemTokenSize = [leg.ItemTokenSize(2)/2 *  HeightScaleFactor, leg.ItemTokenSize(2)/2];
        legs = [legs, leg];
        ax.XAxis.Exponent = 4;
        title('(d)', 'FontWeight','bold', 'Interpreter', 'none', 'FontSize', 22);
        nexttile;
        gscatter(Clay, Rho, Facies, [], '+');
        xlabel('\boldmath{$V_c$}', 'FontSize', 22); 
        ylabel('\boldmath{$\rho$}', 'FontSize', 22);
        leg = legend('\emph{Oil Sand}', '\emph{Shale}', 'Location', 'southeast', 'Interpreter', 'latex',  'FontSize', 12);
        leg.ItemTokenSize = [leg.ItemTokenSize(2)/2, leg.ItemTokenSize(2)/2];
        legs = [legs, leg];
        title('(e)', 'FontWeight', 'bold', 'Interpreter', 'none', 'FontSize', 22);
        nexttile;
        plot_histogram(Vp./Vs, Facies, '\boldmath{$Frequency$}');
        leg = legend('\emph{Oil Sand}', '\emph{Shale}', 'Location', 'best', 'Interpreter', 'latex',  'FontSize', 12,  'Location', 'northwest');
        leg.ItemTokenSize = [leg.ItemTokenSize(2)/2 *  HeightScaleFactor, leg.ItemTokenSize(2)/2];
        legs = [legs, leg];
        xlabel('\boldmath{$\alpha/\beta$}', 'FontSize', 22);
        title('(f)', 'FontWeight', 'bold', 'Interpreter', 'none', 'FontSize', 22);
        colormap('parula');

        for l = 1:length(legs)
            NewHeight = legs(l).Position(4) * HeightScaleFactor;
            legs(l).Position(2) = legs(l).Position(2) - (NewHeight - legs(l).Position(4));
            legs(l).Position(4) = NewHeight;
        end

        if exportPlots
            if ~exist('./figs', 'dir')
                mkdir('./figs')
            end
            exportgraphics(f, 'figs/testdata.pdf', 'BackgroundColor', 'none', 'Resolution', 1000);
        end
        % set(gca,'FontName','Helvica')
    end

    %% Monte carlo sampling of the joint distribution
    % Prior of petrophysical properties p(r) with 2 facies:
    petroSim = [];
    for facie = 1:length(unique(Facies))
        MU = mean([Phi(Facies==facie) Clay(Facies==facie) Sw(Facies==facie)]);
        COV = diag(diag(cov([Phi(Facies==facie) Clay(Facies==facie) Sw(Facies==facie)])));
        if facie == 1
            MU(3) = 0.2;
        end
        facie_train = zeros(nSim(facie), 1) + facie;
        points = mvnrnd(MU, COV, nSim(facie));
        indexes = any(points(:, 1) < 0 | points(:, 1) > 0.4 | ...
            points(:, 2) < 0 | points(:, 2) > 0.8 | points(:, 3) < 0 | points(:, 3) > 1, 2);
        n = sum(indexes);
        total_n = size(points, 1) + n;
        while n > 0
            values = mvnrnd(MU, COV, total_n);
            points(indexes, :) = values(total_n-n+1:end, :);
            indexes = any(points(:, 1) < 0 | points(:, 1) > 0.4 | ...
                points(:, 2) < 0 | points(:, 2) > 0.8 | points(:, 3) < 0 | points(:, 3) > 1, 2);
            n = sum(indexes);
            total_n = total_n + n;
        end
        petroSim = [petroSim; points, facie_train];    %#ok<AGROW>
    end
    % Additional facies for brine sand
    MU = [0.24 0.07 0.95];
    COV = [0.017 0.06 0.02] .^ 2;
    points = mvnrnd(MU, COV, nSim(3));
    indexes = any(points(:, 1) < 0 | points(:, 1) > 0.4 | ...
        points(:, 2) < 0 | points(:, 2) > 0.8 | points(:, 3) < 0 | points(:, 3) > 1, 2);
    n = sum(indexes);
    total_n = size(points, 1) + n;
    while n > 0
        values = mvnrnd(MU, COV, total_n);
        points(indexes, :) = values(total_n-n+1:end, :);
        indexes = any(points(:, 1) < 0 | points(:, 1) > 0.4 | ...
            points(:, 2) < 0 | points(:, 2) > 0.8 | points(:, 3) < 0 | points(:, 3) > 1, 2);
        n = sum(indexes);
        total_n = total_n + n;
    end
    petroSim = [petroSim; points, zeros(nSim(3), 1) + 3];
    Phi_sim = petroSim(:,1);
    Clay_sim = petroSim(:,2);
    Sw_sim = petroSim(:,3);
    
    %% Rock-physics model
    % Sampling elastic properties from p(m|r):
    nd = size(Phi,2);
    nv = 3;
    R = zeros(nd,nv+1);
    X = [Phi Clay Sw, ones(size(Phi))];
    R(1,:) = regress(Vp, X); 
    R(2,:) = regress(Vs, X); 
    R(3,:) = regress(Rho, X);
    [Vpsim, Vssim, Rhosim] = LinearizedRockPhysicsModel(Phi_sim, Clay_sim, Sw_sim, R);
    
    noise_perc = 0.05;
    Vpsim = Vpsim + noise_perc * std(Vpsim) * randn(size(Vpsim));
    Vssim = Vssim + noise_perc * std(Vssim) * randn(size(Vssim));
    Rhosim = Rhosim + noise_perc * std(Rhosim) * randn(size(Rhosim));
    
    % training dataset
    mtrain = [Phi_sim, Clay_sim, Sw_sim, petroSim(:, 4)];
    dtrain = [Vpsim, Vssim, Rhosim];

    legs = [];

    if showPlots
        variableNames = {'\boldmath{$\alpha$}', ...
        '\boldmath{$\beta$}', '\boldmath{$\rho$}', ...
        '\boldmath{$\phi$}', '\boldmath{$V_c$}', ...
        '\boldmath{$S_w$}'};
        variableRanges = [3040, 1630, 2, 0, 0, 0 ; 4880, 3125, 2.6, 0.4, 0.8, 1];
        f = generate_histograms([dtrain, mtrain(:, 1:end-1)], variableNames, [0, 8], variableRanges);
        sgtitle(f, '(a)', 'FontWeight', 'bold', 'FontSize', 22, 'Interpreter', 'none');
        if exportPlots
            exportgraphics(f, 'figs/traindata_2D_histogram.pdf', 'BackgroundColor', 'none', 'Resolution', 1000)
        end
        set(0, 'DefaultAxesFontSize', 22)
        f = figure('units', 'normalized', 'outerposition', [0.26 0.24 0.48 0.60]);
        tiledlayout(f, 2, 3, 'Padding', 'tight', 'TileSpacing', 'tight');
        AI = dtrain(:, 1) .* dtrain(:, 3);
        ax = nexttile;
        gscatter(mtrain(:, 1), dtrain(:, 1), mtrain(:, end), [], '+');
        xlabel('\boldmath{$\phi$}'); 
        ylabel('\boldmath{$\alpha$}');
        leg = legend('\emph{Oil Sand}', '\emph{Shale}', '\emph{Brine Sand}', 'Interpreter', 'latex', 'FontSize', 12);
        leg.ItemTokenSize = [leg.ItemTokenSize(2)/2, leg.ItemTokenSize(2)/2];
        legs = [legs, leg];
        ax.YAxis.Exponent = 3;
        title('(a)', 'FontWeight', 'bold', 'Interpreter', 'none');
        ax = nexttile;
        gscatter(mtrain(:, 1), dtrain(:, 2), mtrain(:, end), [], '+');
        xlabel('\boldmath{$\phi$}'); 
        ylabel('\boldmath{$\beta$}');
        leg = legend('\emph{Oil Sand}', '\emph{Shale}', '\emph{Brine Sand}', 'Interpreter', 'latex', 'FontSize', 12);
        leg.ItemTokenSize = [leg.ItemTokenSize(2)/2, leg.ItemTokenSize(2)/2];
        legs = [legs, leg];
        ax.YAxis.Exponent = 3;
        title('(b)', 'FontWeight', 'bold', 'Interpreter', 'none');
        ax = nexttile;
        plot_histogram(AI, mtrain(:, end), '\boldmath{$Frequency$}');
        leg = legend('\emph{Oil Sand}', '\emph{Shale}', '\emph{Brine Sand}', 'Interpreter', 'latex', 'FontSize', 12);
        leg.ItemTokenSize = [leg.ItemTokenSize(2)/2, leg.ItemTokenSize(2)/2];
        legs = [legs, leg];
        xlabel('\boldmath{$AI$}');
        title('(c)', 'FontWeight', 'bold', 'Interpreter', 'none');
        ax.YAxis.Exponent = 2;
        ax.XAxis.Exponent = 4;
        ax = nexttile;
        gscatter(AI, dtrain(:, 1) ./ dtrain(:, 2), clusterdata(mtrain(:, end), 3), [], '+');
        xlabel('\boldmath{$AI$}'); 
        ylabel('\boldmath{$\alpha/\beta$}', 'FontWeight','bold');
        leg = legend('\boldmath{$S_w$} (\emph{Oil Sand})', ...
            '\boldmath{$S_w$} (\emph{Shale})',  ...
            '\boldmath{$S_w$} (\emph{Brine Sand})', 'Interpreter', 'latex', 'FontSize', 12);
        leg.ItemTokenSize = [leg.ItemTokenSize(2)/2 *  HeightScaleFactor, leg.ItemTokenSize(2)/2];
        legs = [legs, leg];
        title('(d)', 'FontWeight', 'bold', 'Interpreter', 'none');
        ax.XAxis.Exponent = 4; 
        nexttile;
        gscatter(mtrain(:, 2), dtrain(:, 3), mtrain(:, end), [], '+');
        xlabel('\boldmath{$V_c$}'); 
        ylabel('\boldmath{$\rho$}');
        leg = legend('\emph{Oil Sand}', '\emph{Shale}', '\emph{Brine Sand}', 'Interpreter', 'latex', 'FontSize', 12);
        leg.ItemTokenSize = [leg.ItemTokenSize(2)/2, leg.ItemTokenSize(2)/2];
        legs = [legs, leg];
        title('(e)', 'FontWeight', 'bold', 'Interpreter', 'none');
        ax = nexttile;
        plot_histogram(dtrain(:, 1) ./ dtrain(:, 2), mtrain(:, end), '\boldmath{$Frequency$}');
        leg = legend('\emph{Oil Sand}', '\emph{Shale}', '\emph{Brine Sand}', 'Interpreter', 'latex', 'FontSize', 12);
        leg.ItemTokenSize = [leg.ItemTokenSize(2)/2  *  HeightScaleFactor, (leg.ItemTokenSize(2)/2)];
        legs = [legs, leg];
        xlabel('\boldmath{$\alpha/\beta$}', 'FontWeight', 'bold');
        title('(f)', 'FontWeight', 'bold', 'Interpreter', 'none');
        ax.YAxis.Exponent = 2;
        colormap('parula');

        for l = 1:length(legs)
            NewHeight = legs(l).Position(4) * HeightScaleFactor;
            legs(l).Position(2) = legs(l).Position(2) - (NewHeight - legs(l).Position(4));
            legs(l).Position(4) = NewHeight;
        end

        if exportPlots
            exportgraphics(f, 'figs/traindata.pdf', 'BackgroundColor', 'none', 'Resolution', 1000);
        end
    end

    if useFacies
        modelData = [mtrain(:, end), dtrain, mtrain(:, 1:end-1)];
    else
        modelData = [dtrain, mtrain(:, 1:end-1)];
    end
    wellData = [Depth, Facies, Vp, Vs, Rho, Phi, Clay, Sw];
end

