function rockTypeAndFluid = extractRockTypeAndFluid(rockTypeAndFluidData, data) %#codegen
    rows = table2array(rockTypeAndFluidData(:, 3:end));
    [R, C, ~] = size(data);
    rockTypeAndFluid = nan(R, C, 2);
    rockTypeAndFluidArray = table2array(rockTypeAndFluidData(:, 1:2));
    coder.extrinsic('ProgressBar');
    PB = ProgressBar(R, 'Generating Rock Type and Fluid Data', 'cli');
    for i = 1:R
        for j = 1:C
            if ~any(isnan(data(i, j, :)))
                [~, index] = min(sqrt(sum(((rows - squeeze(data(i, j, :))') .^ 2), 2)), [], 'all');
                rockTypeAndFluid(i, j, :) = rockTypeAndFluidArray(index, :);
            end
        end
        pause(0.001*rand);
        count(PB);
    end
end
