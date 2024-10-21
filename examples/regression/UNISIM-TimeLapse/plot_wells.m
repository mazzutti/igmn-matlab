function [] = plot_wells(WELLS, property)
    hold all
    shift_name = 5;
    for well=1:length(WELLS)
        if nargin > 1
            scatter(WELLS(well).j, WELLS(well).i, 65, WELLS(well).(property), 'filled');
            text(WELLS(well).j + shift_name, WELLS(well).i + shift_name, WELLS(well).name, 'FontSize', 8);
        else
            plot(WELLS(well).j, WELLS(well).i, 'k+', 'LineWidth', 2)
            text(WELLS(well).j + shift_name,WELLS(well).i + shift_name, WELLS(well).name, 'FontSize', 8)
        end
    end
end

