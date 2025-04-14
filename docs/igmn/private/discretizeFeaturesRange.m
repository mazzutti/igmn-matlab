% discretizeFeaturesRange Discretizes feature ranges into specified intervals
%
%   domain = discretizeFeaturesRange(intervals, numPoints) takes a matrix of 
%   intervals and the number of points per interval (numPoints) and returns a 
%   cell array where each cell contains a linearly spaced vector 
%   representing the discretized range for the corresponding feature.
%
%   Inputs:
%       intervals  - A 2-by-N matrix where each column represents the 
%                    [min; max] range of a feature.
%       numPoints  - An integer specifying the number of points to 
%                    discretize each interval into.
%
%   Outputs:
%       domain     - A 1-by-N cell array where each cell contains a 
%                    linearly spaced vector representing the discretized 
%                    range for the corresponding feature.
%
%   Example:
%       intervals = [0 10; 5 20];
%       numPoints = 5;
%       domain = discretizeFeaturesRange(intervals, numPoints);
%       % domain = {[0, 2.5, 5, 7.5, 10], [5, 8.75, 12.5, 16.25, 20]}
function domain = discretizeFeaturesRange(intervals, numPoints)
    howMany = size(intervals, 2);
    domain = cell(1, howMany);
    for i = 1:howMany
        interval = intervals(:, i);
        domain{i} = linspace(interval(1), interval(2), numPoints);
    end
end
