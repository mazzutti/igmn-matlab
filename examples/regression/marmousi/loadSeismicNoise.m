function noise = loadSeismicNoise(filePath)
    IM = imread(filePath);
    noise = double(fliplr(IM(:, :, 1)'));
    noise = noise - mean(noise(:));
    noise = noise/std(noise);
end

