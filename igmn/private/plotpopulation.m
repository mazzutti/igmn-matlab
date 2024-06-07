function plotpopulation(optimValues, flag, ijk)
    % Plots the positions of individuals.
    %
    % ijk is an additional parameter, in the form of a 1x3 vector. It lists the
    % dimension of the problem to be plotted, for a multidimensional problem.

    labels = optimValues.hpNames;

    if nargin < 3
        ijk = 1:min(3, length(labels));
    else % Robust input check
        ijk = reshape(ijk, 1, []);
    end
    
    % Input checking
    if size(ijk, 2) > 3
        warning('Unable to plot %g dimensions. Plotting first 3 only', length(ijk))
    end % if length
    
    if strcmpi(flag(1:4), 'init') % Initialize
        delete(findobj(gca, '-regexp', 'Tag', '*Locations'))
        if size(ijk, 2) == 1 % One dimensional
            initLoc = plot(optimValues.population(:, ijk(1)),...
                zeros(size(optimValues.population, 1), 1),...
                'Color', 0.75 * ones(1, 3),...
                'Marker', '.',...
                'LineStyle', 'none',...
                'Tag', 'Initial Locations');
            xlabel(labels{ijk(1)});
        elseif size(ijk, 2) == 2 % Two dimensional
            initLoc = plot(optimValues.population(:, ijk(1)),...
                optimValues.population(:, ijk(2)),...
                'Color', 0.75 * ones(1, 3),...
                'Marker', '.',...
                'LineStyle', 'none',...
                'Tag', 'Initial Locations');
            xlabel(labels{ijk(1)});
            ylabel(labels{ijk(2)});
        elseif size(ijk, 2) == 3 % Three dimensional
            initLoc = plot3(optimValues.population(:, ijk(1)),...
                optimValues.population(:, ijk(2)),...
                optimValues.population(:, ijk(3)),...
                'Color', 0.75 * ones(1, 3),...
                'Marker', '.',...
                'LineStyle', 'none',...
                'Tag', 'Initial Locations');
            xlabel(labels{ijk(1)});
            ylabel(labels{ijk(2)});
            zlabel(labels{ijk(3)});
        end
    
        % Set reasonable axes limits
        % ---------------------------------------------------------------------
        xlim([optimValues.populationRange(1, ijk(1)) - eps, ...
            optimValues.populationRange(2, ijk(1)) + eps])
        if size(ijk, 2) > 1
            ylim([optimValues.populationRange(1, ijk(2)) - eps, ...
                optimValues.populationRange(2, ijk(2))]  + eps)
            if size(ijk, 2) > 2
                zlim([optimValues.populationRange(1, ijk(3)) - eps, ...
                    optimValues.populationRange(2, ijk(3))   + eps])
            end % if size
        end % if size
        % ---------------------------------------------------------------------
    
        title('Population positions')
        set(gca, 'Tag', 'Population Plot', 'NextPlot', 'add')
    
        % Initialize plots
        % ---------------------------------------------------------------------
        if size(ijk, 2) == 1 %  One dimensional
            currentLoc = plot(optimValues.population(:, ijk(1)),...
                zeros(size(optimValues.population, 1), 1));
        elseif size(ijk, 2) == 2 % Two dimensional
            currentLoc = plot(optimValues.population(:, ijk(1)),...
                optimValues.population(:, ijk(2)));
        elseif size(ijk, 2) == 3 % Three dimensional
            currentLoc = plot3(optimValues.population(:, ijk(1)),...
                optimValues.population(:, ijk(2)),...
                optimValues.population(:, ijk(3)));
            hold on;
        end % if size
        set(currentLoc,...
                'LineStyle', 'none',...
                'Marker', '.',...
                'Color', 'blue',...
                'Tag', 'Population Locations');
        % ---------------------------------------------------------------------
    elseif strcmpi(flag(1:4), 'iter') % Iterate
        currentLoc = findobj(gca, 'Tag', 'Population Locations', 'Type', 'line');
        if size(ijk, 2) == 1 %  One dimensional
            set(currentLoc, 'XData', optimValues.population(:, ijk(1)))
        elseif size(ijk, 2) == 2 % Two dimensional
            set(currentLoc,...
                'XData', optimValues.population(:, ijk(1)),...
                'YData', optimValues.population(:, ijk(2)))
        elseif size(ijk, 2) == 3 % Three dimensional
            set(currentLoc,...
                'XData', optimValues.population(:, ijk(1)),...
                'YData', optimValues.population(:, ijk(2)),...
                'ZData', optimValues.population(:, ijk(3)))
        end
    end
    
    if strcmpi(flag(1:4), 'init')
        legend([initLoc, currentLoc], {'Initial Positions', 'Current Positions'}, 'Location', 'northeast')
    end
end
