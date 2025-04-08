% IGMNBUILDER Incremental Gaussian Mixture Network Builder.
%
%   self = igmnBuilder(options) creates a new instance of an Incremental
%   Gaussian Mixture Network (IGMN) using the specified options.
%
%   Inputs:
%       options - An instance of the igmnoptions class that specifies
%                 the configuration for the IGMN. If not provided, a
%                 default igmnoptions instance is used.
%
%   Outputs:
%       self - A handle to the newly created IGMN instance.
%
%   Example:
%       opts = igmnoptions('MaxComponents', 10, 'LearningRate', 0.1);
%       igmnInstance = igmnBuilder(opts);
%
%   See also: igmnoptions, igmn
function self = igmnBuilder(options) %#codegen
    arguments
        options (1, 1) {mustBeA(options, 'igmnoptions')} = igmnoptions();
    end
    self = igmn(options);
end
