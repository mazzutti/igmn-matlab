% assertFileAvailable - Ensures that a specified file is available locally.
%
% This function checks if a file exists at the given file path. If the file
% does not exist, it attempts to download the file from a Google Drive folder
% using a pre-built mapping of file names to their corresponding Google Drive
% file IDs. If the destination directory does not exist, it creates the
% directory before downloading the file.
%
% Syntax:
%   assertFileAvailable(filePath)
%
% Inputs:
%   filePath - (char) The full path to the file that needs to be checked or
%              downloaded.
%
% Notes:
%   - The function relies on a Google Drive folder ID ('folderId') and a
%     mapping of file names to their Google Drive file IDs, which is built
%     or loaded using the `loadOrBuildGDriveFileMap` function.
%   - The `downloadDrivePublicFile` function is used to download the file
%     from Google Drive.
%   - If the destination directory does not exist, it is created using the
%     `mkdir` function.
%
% See also:
%   loadOrBuildGDriveFileMap, downloadDrivePublicFile, mkdir
function assertFileAvailable(filePath)
    folderId = '1Fcau6yRfo0Dx3yzmlNbUrKTlW5iAIDsi';
    filesMap = loadOrBuildGDriveFileMap(folderId);
    if ~exist(filePath, 'file')
        [destinationPath, fileName, extension] = fileparts(filePath);
        if ~exist(destinationPath, 'dir')
            mkdir(destinationPath);
        end
        fileName = sprintf('%s%s', fileName, extension);
        downloadDrivePublicFile(filesMap(fileName), filePath)
    end
end

% listDriveFiles - Recursively lists files and folders from a Google Drive folder.
%
% Syntax:
%   listDriveFiles(folderId, apiKey)
%   listDriveFiles(folderId, apiKey, indent)
%
% Description:
%   This function retrieves and displays the contents of a specified Google Drive 
%   folder using the Google Drive API. It lists both files and subfolders, and 
%   recursively explores subfolders to display their contents as well.
%
% Inputs:
%   folderId - (char) The unique ID of the Google Drive folder to list.
%   apiKey   - (char) The API key for accessing the Google Drive API.
%   indent   - (char) [Optional] A string used for formatting the output to 
%              indicate folder hierarchy. Defaults to an empty string.
%
% Outputs:
%   The function does not return any variables. It prints the folder structure 
%   to the MATLAB command window, including file and folder names, IDs, and 
%   icons to indicate whether an item is a file or folder.
%
% Notes:
%   - The function uses the Google Drive API v3 to fetch folder contents.
%   - Ensure that the API key provided has sufficient permissions to access 
%     the specified folder and its contents.
%   - If the folder is empty or inaccessible, a warning message is displayed.
%
% Example:
%   % List the contents of a Google Drive folder with ID 'abc123' using an API key
%   folderId = 'abc123';
%   apiKey = 'your_api_key_here';
%   listDriveFiles(folderId, apiKey);
%
% See also:
%   webread, weboptions
function listDriveFiles(folderId, apiKey, indent)
    if nargin < 3
        indent = '';
    end

    % Base URL
    baseUrl = 'https://www.googleapis.com/drive/v3/files';

    % Query to get items in this folder
    q = sprintf("'%s' in parents and trashed=false", folderId);
    q = urlencode(q);

    % API URL
    url = sprintf('%s?q=%s&fields=files(id,name,mimeType)&key=%s', baseUrl, q, apiKey);
    options = weboptions("ContentType", "json");

    % Fetch the data
    try
        data = webread(url, options);
    catch ME
        fprintf('%s❌ Error accessing folder: %s\n', indent, ME.message);
        return;
    end

    % Process the items
    if isfield(data, 'files') && ~isempty(data.files)
        for i = 1:length(data.files)
            file = data.files(i);
            isFolder = strcmp(file.mimeType, "application/vnd.google-apps.folder");

            % Print item
            if isFolder
                prefix = "📁";
            else
                prefix = "📄";
            end
            fprintf('%s%s %s (ID: %s)\n', indent, prefix, file.name, file.id);

            % If it's a folder, recurse into it
            if isFolder
                listDriveFiles(file.id, apiKey, [indent '    ']);
            end
        end
    else
        fprintf('%s⚠️ (Empty or inaccessible folder)\n', indent);
    end
end
