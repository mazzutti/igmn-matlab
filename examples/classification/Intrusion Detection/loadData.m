function [taggedData, opts] = loadData(filename, dataLines)

    %% Input handling
    
    % If dataLines is not specified, define defaults
    if nargin < 2
        dataLines = [2, Inf];
    end
    
    %% Set up the Import Options and import the data
    opts = delimitedTextImportOptions("NumVariables", 29);
    
    % Specify range and delimiter
    opts.DataLines = dataLines;
    opts.Delimiter = ",";
    
    % Specify column names and types
    opts.VariableNames = ["Duration", "Protocol", "Service", "Connection_Flag", "SourceToDest", "DestToSource", "Land", "Wrong", "Urgent", "STTL", "DTTL", "SourceToDestPkts", "DestToSourcePkts", "CountSameHost", "CountSameService", "Serror_rate", "Srv_serror_rate", "Same_srv_rate", "Diff_srv_rate", "Srv_diff_host_rate", "Count", "Srv_count", "Same_srv_rate1", "Diff_srv_rate1", "Same_src_port_rate", "Srv_diff_host_rate1", "Serror_rate1", "Srv_serror_rate1", "Class"];
    opts.VariableTypes = ["double", "categorical", "categorical", "categorical", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "categorical"];
    
    % Specify file level properties
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";
    
    % Specify variable properties
    opts = setvaropts(opts, ["Protocol", "Service", "Connection_Flag", "Class"], "EmptyFieldRule", "auto");
    
    % Import the data
    taggedData = readtable(filename, opts);

end