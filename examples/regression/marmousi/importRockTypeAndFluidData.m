%{
IMPORTROCKTYPEANDFLUIDDATA Imports rock type and fluid data from a CSV file.

This function reads a tab-delimited CSV file containing information about 
rock types, fluid types, and their associated properties (Vp, Vs, and Rho). 
The data is processed and returned as a MATLAB table.

OUTPUT:
    rocktypeandfluid - A table containing the following columns:
        - RockType: Categorical variable representing the rock type.
        - Fluid: Categorical variable representing the fluid type.
        - Vp: Double variable representing the P-wave velocity (in km/s).
        - Vs: Double variable representing the S-wave velocity (in km/s).
        - Rho: Double variable representing the density (in g/cm³).

NOTES:
    - The input CSV file is expected to be located at "data/rocktype_and_fluid.csv".
    - The file should have a tab delimiter and use a comma as the decimal separator.
    - The first row of the file is assumed to contain column headers.
    - Vp and Vs values are converted from m/s to km/s during processing.

EXAMPLE USAGE:
    rocktypeandfluid = importRockTypeAndFluidData();
%}
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
