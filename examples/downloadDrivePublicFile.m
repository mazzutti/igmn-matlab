% downloadDrivePublicFile - Downloads a large public Google Drive file using MATLAB
%
% Syntax:
%   downloadDrivePublicFile(fileId, destination)
%
% Description:
%   This function downloads a large public file from Google Drive using its file ID.
%   It handles the "virus scan warning" confirmation redirect by extracting the
%   confirmation token from the HTML response and constructing the final download URL.
%
% Inputs:
%   fileId      - (char) The unique identifier of the file on Google Drive.
%   destination - (char) The local file path where the downloaded file will be saved.
%
% Outputs:
%   None. The file is saved directly to the specified destination.
%
% Example:
%   % Download a file from Google Drive
%   fileId = '1A2B3C4D5E6F7G8H9I0J';
%   destination = 'myfile.zip';
%   downloadDrivePublicFile(fileId, destination);
%
% Notes:
%   - This function requires an active internet connection.
%   - The function uses MATLAB's webread and websave functions for HTTP requests.
%   - Ensure the file ID corresponds to a publicly accessible file on Google Drive.
%
% Errors:
%   - Throws an error if the confirmation token cannot be extracted from the HTML response.
%   - Throws an error if the download fails or the destination path is invalid.
function downloadDrivePublicFile(fileId, destination)
    import matlab.net.*
    import matlab.net.http.*

    baseUrl = sprintf('https://drive.google.com/uc?export=download&id=%s', fileId);

    options = weboptions('Timeout', 60, 'HeaderFields', {'User-Agent', 'Mozilla/5.0'});

    % Initial request
    response = webread(baseUrl, options);
    if isa(response,'uint8')
        response = char(response');
    end

    % Search for the confirmation token and final download URL
    tokenExpr = 'name="confirm"\s+value="([a-zA-Z0-9_-]+)"';
    tokenMatch = regexp(response, tokenExpr, 'tokens');

    if ~isempty(tokenMatch)
        confirmToken = tokenMatch{1}{1};
        fprintf('🔐 Found confirmation token: %s\n', confirmToken);
        % Construct the final download URL
        finalUrl = sprintf(['https://drive.usercontent.google.com/download?' ...
            'export=download&confirm=%s&id=%s'], confirmToken, fileId);
    else 
        finalUrl = sprintf(['https://drive.usercontent.google.com/download?' ...
            'export=download&id=%s'],fileId);
    end

    fprintf('⬇️  Downloading from:\n%s\n', finalUrl);

    % Download the actual file
    destinationDir = fileparts(destination);
    if ~exist(destinationDir, 'dir')
        mkdir(destinationDir);
    end
    websave(destination, finalUrl, options);
    fprintf('✅ File downloaded to: %s\n', destination);
end