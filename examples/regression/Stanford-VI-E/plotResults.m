function plotResults(targets, outputs, cubeSize, titles, climits, figTitleText)
    index = 1;
    T = size(targets, 2);
    O = size(outputs, 2);
    f = figure;
    f.Position = [100 100 1500 1000];
    hold on;
    for i = 1:T
        subplot(str2double(sprintf('%d%d%d', 2, T, index)));
        imagesc(reshape(targets(:, i), cubeSize));
        clim(climits{i});
        title(sprintf('Reference %s', titles{i}));
        index = index + 1;
    end

    for i = 1:O
        subplot(str2double(sprintf('%d%d%d', 2, O, index)));
        imagesc(reshape(outputs(:, i), cubeSize));
        clim(climits{i});
        title(sprintf('Estimated %s', titles{i}));
        index = index + 1;
    end
    figTitle = annotation("textbox");
    figTitle.FontSize = 14;
    figTitle.FontWeight = "bold";
    figTitle.String = figTitleText;
    figTitle.LineStyle = "none";
    pos = gca().Position;
    figTitle.Position = [
        (pos(1) + pos(3))/2, ...
        0.9, ...
        0.32, ...
        0.09 ...
    ];
    hold off;
end

