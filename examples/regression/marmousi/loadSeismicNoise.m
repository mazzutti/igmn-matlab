% loadSeismicNoise - Loads and processes seismic noise data from an image file.
%
% Syntax:
%   noise = loadSeismicNoise(filePath)
%
% Description:
%   This function reads an image file specified by the input filePath, 
%   extracts the first channel of the image, flips it horizontally, 
%   and transposes it. The resulting matrix is converted to double 
%   precision, normalized by subtracting its mean and dividing by its 
%   standard deviation.
%
% Inputs:
%   filePath - A string specifying the path to the image file containing 
%              the seismic noise data.
%
% Outputs:
%   noise - A double-precision matrix representing the processed seismic 
%           noise data, normalized to have zero mean and unit variance.
%
% Example:
%   noise = loadSeismicNoise('seismic_image.png');
%
% Notes:
%   - The function assumes the input image is in a format supported by 
%     the imread function and contains at least one channel.
%   - The normalization ensures the output noise data has a mean of 0 
%     and a standard deviation of 1.
function noise = loadSeismicNoise(filePath)
    IM = imread(filePath);
    noise = double(fliplr(IM(:, :, 1)'));
    noise = noise - mean(noise(:));
    noise = noise/std(noise);
end

