% plotResults - Function to visualize and export results of predictions and uncertainties.
%
% Syntax:
%   plotResults(net, WELLS, targets, outputs, unconditioned_outputs, ...
%               targetsIndexes, I, J, probabilities, minMaxProportion, ...
%               plotTitle, exportFileName, refFig)
%
% Inputs:
%   net                  - Neural network or model object containing prediction parameters.
%   WELLS                - Struct or data containing well locations for plotting.
%   targets              - Cell array of target values for different variables.
%   outputs              - Matrix of conditioned outputs (predictions).
%   unconditioned_outputs- Matrix of unconditioned outputs (predictions).
%   targetsIndexes       - Linear indices of target locations in the grid.
%   I                    - Number of rows in the grid.
%   J                    - Number of columns in the grid.
%   probabilities        - Cell array of probability distributions for each variable.
%   minMaxProportion     - Normalization range for denormalizing data.
%   plotTitle            - Title for the plot (string).
%   exportFileName       - (Optional) File name for exporting the plot as a PDF.
%   refFig               - Reference figure handle for plotting.
%
% Outputs:
%   None. The function generates plots and optionally exports them as PDF files.
%
% Description:
%   This function generates a series of plots to visualize the results of 
%   predictions and their uncertainties. It includes:
%     - Unconditioned predictions for porosity (Phi) and water saturation (Sw).
%     - Conditioned predictions for porosity (Phi) and water saturation (Sw).
%     - Standard deviations of predictions for each variable.
%   The function also supports exporting the plots to PDF files if a file name 
%   is provided.
%
% Notes:
%   - The function uses MATLAB's tiledlayout and imagesc for plotting.
%   - Color limits and colormaps are set for better visualization.
%   - Well locations are overlaid on the plots using the plot_wells function.
%   - If probabilities are provided, standard deviation plots are generated.
%
% Example:
%   plotResults(net, WELLS, targets, outputs, unconditioned_outputs, ...
%               targetsIndexes, 100, 100, probabilities, [0, 1], ...
%               'Prediction Results', 'results', figure(1));
%
% See also:
%   plot_wells, exportgraphics, imagesc, tiledlayout
function plotResults(net, WELLS, targets, outputs, unconditioned_outputs, ...
    targetsIndexes, I, J, probabilities, minMaxProportion, plotTitle, exportFileName, refFig)

    targets{1}(targets{1} < 0.01) = 0.01;
    targets{2}(targets{2} < 0.01) = 0.01;
    targets{3}(targets{3} < 0.01) = 0.01;

    outputs(outputs(:, 1) < 0.01, 1) = 0.01;
    outputs(outputs(:, 2) < 0.01, 2) = 0.01;
    outputs(outputs(:, 3) < 0.01, 3) = 0.01;

    unconditioned_outputs(unconditioned_outputs(:, 1) < 0.01, 1) = 0.01;
    unconditioned_outputs(unconditioned_outputs(:, 2) < 0.01, 2) = 0.01;
    unconditioned_outputs(unconditioned_outputs(:, 3) < 0.01, 3) = 0.01;

    set(0, 'currentfigure', refFig);
    set(0, 'DefaultAxesFontSize', 12, 'defaultTextInterpreter', 'none');
    % f = figure('units','normalized','outerposition', [0.2 0.18 0.6 0.64]);
    % tiledlayout(refFig, 2, 3, 'Padding', 'tight', 'TileSpacing', 'loose');
    
    
    ax = nexttile();
    predPhi = nan(I * J, 1);
    predPhi(targetsIndexes) = unconditioned_outputs(:, 1);
    predPhi = reshape(predPhi, I, J);
    imagesc(reshape(predPhi, I, J));
    clim([0 0.35]);
    hold all;
    plot_wells(WELLS, 'Phi');
    title(ax, '\textbf{(d) - \boldmath{$\phi$} (uncond.)}', 'Interpreter', 'latex');
    ylabel('I', 'FontWeight','bold');
    % xlabel('J', 'FontWeight','bold');
    xticks([]);
    % grid;
    colorbar('XTick', 0:0.05:0.35);
    colormap([1,1,1;parula]);
    ax = nexttile();
    predSw13 = nan(I * J, 1);
    predSw13(targetsIndexes) = unconditioned_outputs(:, 2);
    predSw13  = reshape(predSw13, I, J);
    imagesc(predSw13);
    clim([0, 0.8]);
    hold all;
    plot_wells(WELLS, 'Sw13');
    title(ax, '\textbf{(e) - \boldmath{$S_{w~(2013)}$} (uncond.)}', 'Interpreter', 'latex');
    % xlabel('J', 'FontWeight','bold');
    xticks([]);
    yticks([]);
    % grid;
    colorbar('XTick', 0:0.1:0.8);
    colormap([1,1,1;parula]);
    ax = nexttile();
    predSw24 = nan(I * J, 1);
    predSw24(targetsIndexes) = unconditioned_outputs(:, 3);
    predSw24 = reshape(predSw24, I, J);
    imagesc(predSw24);
    clim([0, 0.8]);
    hold all;
    plot_wells(WELLS, 'Sw24');
    title(ax, '\textbf{(f) - \boldmath{$S_{w~(2024)}$} (uncond.)}', 'Interpreter', 'latex');
    xticks([]);
    yticks([]);
    % xlabel('J', 'FontWeight','bold');
    % grid;
    colorbar('XTick', 0:0.1:0.8);
    hold all;
    colormap([1,1,1;parula]);

    ax = nexttile();
    predPhi = nan(I * J, 1);
    predPhi(targetsIndexes) = outputs(:, 1);
    predPhi = reshape(predPhi, I, J);
    imagesc(reshape(predPhi, I, J));
    clim([0, 0.35]);
    hold all;
    plot_wells(WELLS, 'Phi');
    title(ax, '\textbf{(g) - \boldmath{$\phi$}}', 'Interpreter', 'latex');
    ylabel('I', 'FontWeight','bold');
    xlabel('J', 'FontWeight','bold');
    % grid;
    colorbar('XTick', 0:0.05:0.35);
    colormap([1,1,1;parula]);
    ax = nexttile();
    predSw13 = nan(I * J, 1);
    predSw13(targetsIndexes) = outputs(:, 2);
    predSw13  = reshape(predSw13, I, J);
    imagesc(predSw13);
    clim([0, 0.8]);
    hold all;
    plot_wells(WELLS, 'Sw13');
    title(ax, '\textbf{(h) - \boldmath{$S_{w~(2013)}$}}', 'Interpreter', 'latex');
    xlabel('J', 'FontWeight','bold');
    yticks([]);
    % grid;
    colorbar('XTick', 0:0.1:0.8);
    colormap([1,1,1;parula]);
    ax = nexttile();
    predSw24 = nan(I * J, 1);
    predSw24(targetsIndexes) = outputs(:, 3);
    predSw24 = reshape(predSw24, I, J);
    imagesc(predSw24);
    clim([0, 0.8]);
    hold all;
    plot_wells(WELLS, 'Sw24');
    title(ax, '\textbf{(i) - \boldmath{$S_{w~(2024)}$}}', 'Interpreter', 'latex');
    xlabel('J', 'FontWeight','bold');
    yticks([]);
    % grid;
    colorbar('XTick', 0:0.1:0.8);
    hold all;
    colormap([1,1,1;parula]);

    if ~exist('exportFileName', 'var')
        sgtitle(plotTitle);
    else
        exportgraphics(refFig, sprintf('%s.pdf', exportFileName), 'BackgroundColor', 'none', 'Resolution', 1000)
    end

    if (size(probabilities{1}, 2) ~= 0)
    
        set(0, 'DefaultAxesFontSize', 12, 'defaultTextInterpreter', 'none') 
        f = figure('units', 'normalized', 'outerposition', [0.225 0.3 0.55 0.36]);
        tiledlayout(f, 'horizontal', 'Padding', 'compact', 'TileSpacing', 'compact');
    
        domain = repmat(0:0.35/(size(probabilities{1}, 2) - 1):0.35, size(probabilities{1}, 1), 1);
    
        ax = nexttile;
        Phi_std = nan(I * J, 1);
        % Phi_std(targetsIndexes) = sqrt(sum(probabilities{1} .* (domain - targets{1}(targetsIndexes)) .^ 2, 2));
        % Phi_std(targetsIndexes) = sqrt(sum(probabilities{1} .* (domain - unconditioned_outputs(:, 1)) .^ 2, 2));
        Phi_std(targetsIndexes) = sqrt(sum(probabilities{1} .* (domain - outputs(:, 1)) .^ 2, 2));
        Phi_std = reshape(Phi_std, I, J);
        Phi_std(Phi_std < 0.01) = 0.01;
        imagesc(Phi_std);
        clim([0, 0.35]);
        % clim([0, max(Phi_std, [], 'all')])
        hold all;
        plot_wells(WELLS);
        title(ax, '\textbf{(a) - \boldmath{$\phi$} (Std. Dev.)}',  'Interpreter', 'latex');
        ylabel('I', 'FontWeight', 'bold');
        xlabel('J', 'FontWeight', 'bold');
        colorbar('XTick', 0:0.05:0.35);
        colormap([1,1,1; parula]);
    
        domain = repmat(0:0.8/(size(probabilities{2}, 2) - 1):0.8, size(probabilities{2}, 1), 1);
    
        ax = nexttile;
        Sw13_std = nan(I * J, 1);
        % Sw13_std(targetsIndexes) = sqrt(sum(probabilities{2} .* (domain - targets{2}(targetsIndexes)) .^ 2, 2));
        % Sw13_std(targetsIndexes) =  sqrt(sum(probabilities{2} .* (domain -  unconditioned_outputs(:, 2)) .^ 2, 2));
        Sw13_std(targetsIndexes) =  sqrt(sum(probabilities{2} .* (domain -  outputs(:, 2)) .^ 2, 2));
        Sw13_std = reshape(Sw13_std, I, J);
        Sw13_std(Sw13_std < 0.01) = 0.01;
        imagesc(Sw13_std)
        clim([0, 0.35]);
        % clim([0, max(Sw13_std, [], 'all')])
        hold all;
        plot_wells(WELLS);
        title(ax, '\textbf{(b) - \boldmath{$S_{w~(2023)}$} (Std. Dev.)}',  'Interpreter', 'latex');
        yticks([]);
        xlabel('J', 'FontWeight', 'bold');
        colorbar('XTick', 0:0.05:0.35);
        colormap([1,1,1; parula]);
    
        domain = repmat(0:0.8/(size(probabilities{3}, 2) - 1):0.8, size(probabilities{3}, 1), 1);
    
        ax = nexttile;
        Sw24_std = nan(I * J, 1);
        % Sw24_std(targetsIndexes) = sqrt(sum(probabilities{3} .* (domain - targets{3}(targetsIndexes)) .^ 2, 2));
        % Sw24_std(targetsIndexes) = sqrt(sum(probabilities{3} .* (domain -  unconditioned_outputs(:, 3)) .^ 2, 2));
        Sw24_std(targetsIndexes) = sqrt(sum(probabilities{3} .* (domain -  outputs(:, 3)) .^ 2, 2));
        Sw24_std = reshape(Sw24_std, I, J);
        Sw24_std(Sw24_std < 0.01) = 0.01;
        imagesc(Sw24_std);
        % m = max(Sw24_std, [], 'all');
        clim([0, 0.35]);
        % clim([0, max(Sw24_std, [], 'all')])
        hold all;
        plot_wells(WELLS);
        title(ax, '\textbf{(c) - \boldmath{$S_{w~(2024)}$} (Std. Dev.)}', 'Interpreter', 'latex');
        yticks([]);
        xlabel('J', 'FontWeight', 'bold');
        colorbar('XTick', 0:0.05:0.35);
        colormap([1,1,1; parula]);

        if ~exist('exportFileName', 'var')
            sgtitle('Predictions Standard Deviations');
        else
            exportgraphics(f, sprintf('%s_std.pdf', exportFileName), 'BackgroundColor', 'none', 'Resolution', 1000)
        end
    end

    % means = net.means;
    % covs = pageinv(net.invCovs);
    % gm = gmdistribution(net.means, pageinv(net.invCovs), net.priors);
    % logs = random(gm, 30000);
    % 
    % variableRanges = [3860, 1, 3810, 1, 0, 0, 0; 16950, 2, 17265, 2, 0.4, 1, 1];
    % variableNames = {'\boldmath{I$_{p_{_{(2013)}}}$}     ', '\boldmath{$\alpha/\beta_{_{(2013)}}$}',  ....
    %         '\boldmath{I$_{p_{_{(2024)}}}$}     ', '\boldmath{$\alpha/\beta_{_{(2024)}}$}', '\boldmath{$\phi$}', ...
    %         '\boldmath{S$_{w_{_{(2013)}}}$}' , '\boldmath{S$_{w_{_{(2024)}}}$}'};
    % logs = denormalizeData(logs, minMaxProportion, 1:length(variableNames));
    % f = generate_histograms(logs, variableNames, [0 24], variableRanges, means, covs, net.priors, minMaxProportion);
    % sgtitle(f, '(b)', 'FontWeight', 'bold', 'FontSize', 22, 'Interpreter', 'none');
    % if exist('exportFileName', 'var')
    %      exportgraphics(f, 'figs/igmn_histogram.pdf', 'BackgroundColor', 'none', 'Resolution', 1000)
    % end
end

