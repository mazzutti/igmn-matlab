% loadOrBuildGDriveFileMap - Load or build a Google Drive file map
%
% This function attempts to load a cached file map from a MAT file. If the
% MAT file is not found, it generates the file map by recursively querying
% the Google Drive API for the specified folder ID. The resulting map is
% saved to a MAT file for future use.
%
% Syntax:
%   filesMap = loadOrBuildGDriveFileMap(folderId)
%
% Inputs:
%   folderId - (string) The Google Drive folder ID for which the file map
%              should be generated.
%
% Outputs:
%   filesMap - (containers.Map) A map with file/folder names as keys and
%              their corresponding Google Drive IDs as values.
%
% Notes:
%   - The function requires a valid Google Drive API key to be set in the
%     environment variable 'GOOGLE_DRIVE_API_KEY'.
%   - If the MAT file ('google_drive_file_map.mat') exists, the function
%     loads the file map from it and skips the API call.
%   - If the MAT file does not exist, the function generates the file map
%     by querying the Google Drive API and saves it to the MAT file.
%
% Example:
%   folderId = 'your-google-drive-folder-id';
%   filesMap = loadOrBuildGDriveFileMap(folderId);
%
% Dependencies:
%   - Requires the 'loadenv' function to load environment variables from
%     an '.env' file.
%   - Requires access to the Google Drive API.
%
% Errors:
%   - Throws an error if the 'GOOGLE_DRIVE_API_KEY' environment variable
%     is not set or is empty.
function filesMap = loadOrBuildGDriveFileMap(folderId)

    % Name of MAT file to cache the map
    matFile = 'google_drive_file_map.mat';

    % Try loading from MAT file
    if exist(matFile, 'file')
        load(matFile, 'filesMap');
        return;
    end

    % Get API key from environment
    loadenv('examples.env');
    apiKey = getenv("GOOGLE_DRIVE_API_KEY");
    if isempty(apiKey)
        error("❌ API key not found. Please set the 'GOOGLE_DRIVE_API_KEY' environment variable.");
    end

    fprintf('🔍 MAT file not found. Generating file map from Google Drive...\n');

    % Build the map recursively
    filesMap = containers.Map;
    filesMap = recurseFolder(folderId, apiKey, '', filesMap);

    % Save for future reuse
    save(matFile, 'filesMap');
    fprintf('✅ File map saved to: %s\n', matFile);
end
%{
recurseFolder - Recursively populates a map of file names to file IDs from a Google Drive folder.

This function uses the Google Drive API to retrieve the contents of a specified folder
and its subfolders. It builds a map (containers.Map) where the keys are file or folder
names and the values are their corresponding Google Drive IDs. If there are name
collisions, unique keys are generated by appending a portion of the file ID.

Inputs:
    folderId - (string) The ID of the Google Drive folder to start the recursion.
    apiKey   - (string) The API key for accessing the Google Drive API.
    indent   - (string) A string used for indentation in debug messages (e.g., for recursion depth).
    fileMap  - (containers.Map) A map object to store the file name-to-ID mappings.

Outputs:
    fileMap  - (containers.Map) The updated map containing file name-to-ID mappings.

Notes:
    - The function uses the Google Drive API v3 to fetch folder contents.
    - Only non-trashed files are included in the map.
    - If a name collision occurs, a unique key is generated by appending the first
      six characters of the file ID to the name.

Example:
    % Initialize an empty map
    fileMap = containers.Map();

    % Call the function with a folder ID and API key
    fileMap = recurseFolder('your-folder-id', 'your-api-key', '', fileMap);

    % Display the resulting map
    disp(fileMap);

Errors:
    - If the API request fails, an error message is printed, and the function returns
      without updating the map for the current folder.
%}
function fileMap = recurseFolder(folderId, apiKey, indent, fileMap)
    % Recursive helper to populate the fileMap from Google Drive

    baseUrl = 'https://www.googleapis.com/drive/v3/files';
    q = sprintf("'%s' in parents and trashed=false", folderId);
    q = urlencode(q);
    url = sprintf('%s?q=%s&fields=files(id,name,mimeType)&key=%s', baseUrl, q, apiKey);
    options = weboptions("ContentType", "json");

    try
        data = webread(url, options);
    catch ME
        fprintf('%s❌ Error accessing folder: %s\n', indent, ME.message);
        return;
    end

    if isfield(data, 'files') && ~isempty(data.files)
        for i = 1:length(data.files)
            file = data.files(i);
            name = file.name;
            id   = file.id;
            isFolder = strcmp(file.mimeType, "application/vnd.google-apps.folder");

            % Add to map, avoid key collisions
            try
                fileMap(name) = id;
            catch
                newKey = sprintf('%s_%s', name, id(1:6));
                disp(newKey);
                fileMap(newKey) = id;
            end

            % Recurse into subfolder
            if isFolder
                fileMap = recurseFolder(id, apiKey, [indent '    '], fileMap);
            end
        end
    end
end
