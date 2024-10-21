function f = generate_histograms(logs, names, coloraxis, variableRanges, means, covs, priors, minMaxProportion)
    plot_size_x = size(logs, 2);
    set(0, 'DefaultAxesFontSize', 22, 'defaultTextInterpreter', 'latex');
    f = figure('units', 'normalized', 'outerposition', [0.22, 0.025, 0.56, 0.99], 'MenuBar','none', 'ToolBar','none');
    
    ha = tight_subplot(plot_size_x, plot_size_x, [.055 .045], [0.069 .04],[.07 .01]);
    colormap('parula');
    for i = 1:1:plot_size_x
        for j = 1:1:plot_size_x
            ii = (i - 1) * plot_size_x + j;
            ax = ha(ii);
            axes(ax); %#ok<*LAXES>
            if i == j
                histogram(logs(:, i), 100, 'EdgeAlpha', 0);
            else
                if nargin == 8; face_alpha = 0.5; else; face_alpha = 1; end
                histogram2(logs(:, j), logs(:, i), 100, 'FaceColor','flat', 'EdgeAlpha', 0, 'FaceAlpha', face_alpha);
                if nargin > 2
                    clim(coloraxis)
                end
            end 
           
            view([0 90]);
            if nargin == 8
                if i ~= j
                    [X1Grid, X2Grid] = meshgrid(0:1/499:1, 0:1/499:1);
                    colors = distinguishableColors(length(priors), 'w');
                    hold on;
                    for k = 1:size(means, 1)
                        gm = gmdistribution(means(k, [j, i]), covs([j, i], [j, i],  k), priors(k)); %#ok<*PFBNS>
                        data = pdf(gm, [X1Grid(:) X2Grid(:)]);
                        X = denormalizeData([X1Grid(:), X2Grid(:)], minMaxProportion, [j, i]);
                        contour(ax, reshape(X(:, 1), size(X1Grid, 1), size(X1Grid,2)), ...
                            reshape(X(:, 2), size(X1Grid,1), size(X1Grid,2)), ...
                            reshape(data, size(X1Grid, 1), size(X1Grid,2)), 5, 'EdgeColor', colors(k, :));
                    end
                end
            end
            if i == j
                xlim(variableRanges(:, j));
            else
                xlim(variableRanges(:, j));
                ylim(variableRanges(:, i));
            end

            if max(ax.YAxis.TickValues) >= 10000 
                ax.YAxis.Exponent = 4;
                sl = ax.YRuler.SecondaryLabel;
                sl.Units = 'normalized';
                sl.FontSize = 14;
                sl.Position(2) = sl.Position(2) * 0.99;
            elseif max(ax.YAxis.TickValues) >= 1000 
                ax.YAxis.Exponent = 3;
                sl = ax.YRuler.SecondaryLabel;
                sl.Units = 'normalized';
                sl.FontSize = 14;
                sl.Position(2) = sl.Position(2) * 0.99;
            elseif max(ax.YAxis.TickValues) >= 100
                ax.YAxis.Exponent = 2;
                sl = ax.YRuler.SecondaryLabel;
                sl.Units = 'normalized';
                sl.FontSize = 14;
                sl.Position(2) = sl.Position(2) * 0.98;
            end

            if max(ax.XAxis.TickValues) >= 10000
                ax.XAxis.Exponent = 4;
                sl = ax.XRuler.SecondaryLabel;
                sl.Units = 'normalized';
                sl.FontSize = 14;
                sl.Position(2) = sl.Position(2) + abs(sl.Position(2)) * 0.35;
                sl.Position(1) = sl.Position(1) + abs(sl.Position(2)) * 0.35;
                if i == plot_size_x
                    sl.Position(2) = sl.Position(2) + abs(sl.Position(2)) * 0.05;
                end
            elseif max(ax.XAxis.TickValues) >= 1000
                ax.XAxis.Exponent = 3;
                sl = ax.XRuler.SecondaryLabel;
                sl.Units = 'normalized';
                sl.FontSize = 14;
                sl.Position(2) = sl.Position(2) + abs(sl.Position(2)) * 0.35;
                sl.Position(1) = sl.Position(1) + abs(sl.Position(2)) * 0.35;
                if i == plot_size_x
                    sl.Position(2) = sl.Position(2) + abs(sl.Position(2)) * 0.05;
                end
            elseif max(ax.XAxis.TickValues) >= 100
                ax.XAxis.Exponent = 2;
                sl = ax.XRuler.SecondaryLabel;
                sl.Units = 'normalized';
                sl.FontSize = 14;
                sl.Position(2) = sl.Position(2) + abs(sl.Position(2)) * 0.35;
                sl.Position(1) = sl.Position(1) + abs(sl.Position(2)) * 0.35;
                if i == plot_size_x
                    sl.Position(2) = sl.Position(2) + abs(sl.Position(2)) * 0.05;
                end

            end

            if  i == plot_size_x
                if nargin > 1
                    xlabel(names{j}, 'FontWeight','bold');
                else
                    xlabel({'Z_', j})
                end
            end
            if j == 1
                if nargin > 1
                    ylabel(names{i}, 'FontWeight','bold');
                else
                    ylabel({'Z_', i})
                end
            end
        end
    end
end


