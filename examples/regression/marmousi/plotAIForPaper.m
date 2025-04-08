%{
% plotAIForPaper - Plots an Acoustic Impedance (AI) image with annotations for 
%                  training and testing traces, and optionally exports the plot.
%
% Syntax:
%   plotAIForPaper(AI, trainTraces, testTrace, initDepth, exportFileName)
%
% Inputs:
%   AI              - 2D matrix representing the Acoustic Impedance (AI) image.
%   trainTraces     - Array of integers specifying the indices of training traces.
%   testTrace       - Integer specifying the index of the testing trace.
%   initDepth       - Initial depth value (used for potential y-axis labeling).
%   exportFileName  - String specifying the file name for exporting the plot 
%                     (without extension). If empty, the plot is not exported.
%
% Description:
%   This function visualizes the Acoustic Impedance (AI) data as an image and 
%   overlays vertical lines and annotations for the specified training and 
%   testing traces. The plot is formatted for publication purposes, with 
%   customizable font sizes and colors. If a file name is provided, the plot 
%   is exported as a PDF with a specified background color and resolution.
%
% Outputs:
%   None (the function generates a plot and optionally exports it).
%
% Example:
%   AI = rand(100, 50); % Example AI data
%   trainTraces = [10, 20, 30];
%   testTrace = 25;
%   initDepth = 0;
%   exportFileName = 'AI_plot';
%   plotAIForPaper(AI, trainTraces, testTrace, initDepth, exportFileName);
%
% Notes:
%   - The function uses normalized units for figure positioning.
%   - The y-axis labels and x-axis labels are commented out but can be 
%     customized as needed.
%   - The background color for exported files is set to a specific RGB value.
%}
function plotAIForPaper(AI, trainTraces, testTrace, initDepth, exportFileName)
    set(0, 'DefaultAxesFontSize', 38);
    f = figure('units','normalized', 'outerposition', [0 0 1 1.4]);
    im = imagesc(AI);
    hold('on');
    ax = get(get(im, 'Parent'));
    xnorm = @(x)((x-ax.XLim(1))./(ax.XLim(2)-ax.XLim(1))).*ax.InnerPosition(3)+ax.InnerPosition(1);
    ynorm = @(y)((y-ax.YLim(1))./(ax.YLim(2)-ax.YLim(1))).*ax.InnerPosition(4)+ax.InnerPosition(2);
    ylim([0, size(AI, 1)]);
    % tickLabels = round(linspace(initDepth, initDepth+ size(AI, 1), 7));
    % yticklabels(tickLabels);
    line([testTrace, testTrace], [0, size(AI, 1)], 'Color', 'g', 'LineWidth', 2);
    xconv = [xnorm(testTrace - 150), xnorm(testTrace)];
    yconv = [ynorm(ceil(size(AI, 1) * 0.6)), ynorm(ceil(size(AI, 1) * 0.6) + 20)];
    annotation('textarrow', xconv, yconv,'String', num2str(testTrace), ...
        'Color', 'w', 'FontSize', 38, 'HeadLength', 5, 'HeadWidth', 5, 'TextMargin', 0.001, 'FontWeight', 'bold');
    for trace = trainTraces
        line([trace,trace], [0, size(AI, 1)], 'Color', 'r', 'LineWidth', 1.5);
        xconv = [xnorm(trace - 150), xnorm(trace)];
        yconv = [ynorm(ceil(size(AI, 1) * 0.8)), ynorm(ceil(size(AI, 1) * 0.8) + 20)];
        annotation('textarrow', xconv, yconv,'String', num2str(trace), ...
            'Color', 'w', 'FontSize', 38, 'HeadLength', 5, 'HeadWidth', 5, 'TextMargin', 0.001, 'FontWeight', 'bold');
    end
    
    ylabel('Time(ms)', 'FontSize', 38);
    % xlabel('Trace #')
    % set(gcf, 'Position',  [613, 549, 1359, 691])
    hold('off'); 
    if exportFileName
        exportgraphics(f, sprintf('%s.pdf', exportFileName), 'BackgroundColor', [254/255 252/255 246/255], 'Resolution', 300)
    end
end

