function rocktypeandfluid = importRockTypeAndFluidData()
    opts = delimitedTextImportOptions("NumVariables", 5);

    % Specify range and delimiter
    opts.DataLines = [2, Inf];
    opts.Delimiter = "\t";
    
    % Specify column names and types
    opts.VariableNames = ["RockType", "Fluid", "Vp", "Vs", "Rho"];
    opts.VariableTypes = ["categorical", "categorical", "double", "double", "double"];
    
    % Specify file level properties
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";
    
    % Specify variable properties
    opts = setvaropts(opts, ["RockType", "Fluid"], "EmptyFieldRule", "auto");
    opts = setvaropts(opts, ["Vp", "Vs"], "TrimNonNumeric", true);
    opts = setvaropts(opts, ["Vp", "Vs", "Rho"], "DecimalSeparator", ",");
    opts = setvaropts(opts, ["Vp", "Vs"], "ThousandsSeparator", ".");
    
    % Import the data
    rocktypeandfluid = readtable("data/rocktype_and_fluid.csv", opts);
    rocktypeandfluid.Vp = rocktypeandfluid.Vp ./ 1000;
    rocktypeandfluid.Vs = rocktypeandfluid.Vs ./ 1000;
        
end
