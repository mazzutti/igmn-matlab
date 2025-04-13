%{
PLOT_WELLS Plots well locations on a 2D grid.

This function visualizes the locations of wells on a 2D grid. It can either
plot the wells as simple markers or use a specified property to color the
markers.

Usage:
    plot_wells(WELLS)
    plot_wells(WELLS, property)

Inputs:
    WELLS    - A struct array where each element represents a well. Each
               struct must have the following fields:
               - i: The row index of the well on the grid.
               - j: The column index of the well on the grid.
               - name: A string representing the name of the well.
               - (optional) property: A field representing a numeric value
                 associated with the well, used for coloring the markers.
    property - (Optional) A string specifying the name of the field in the
               WELLS struct to be used for coloring the markers.

Behavior:
    - If the `property` argument is provided, the function uses the values
      of the specified property to color the markers and displays the well
      names near their locations.
    - If the `property` argument is not provided, the function plots the
      wells as black '+' markers and displays the well names near their
      locations.

Notes:
    - The function uses `scatter` for colored markers and `plot` for simple
      markers.
    - The well names are displayed with a small offset for better visibility.

Example:
    % Define a struct array for wells
    WELLS(1).i = 10; WELLS(1).j = 20; WELLS(1).name = 'Well A'; WELLS(1).pressure = 100;
    WELLS(2).i = 15; WELLS(2).j = 25; WELLS(2).name = 'Well B'; WELLS(2).pressure = 120;

    % Plot wells with pressure as the property
    plot_wells(WELLS, 'pressure');

    % Plot wells without specifying a property
    plot_wells(WELLS);
%}
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

