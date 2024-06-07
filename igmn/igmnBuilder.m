function self = igmnBuilder(options) %#codegen
    % IGMN Incremental Gaussian Mixture Network Builder.
    %
    % Inputs:
    %   options: The igmn options as described in igmnoptions.
    %
    % Output:
    %   self:    The IGMN handle for the new instance.
    arguments
        options (1, 1) {mustBeA(options, 'igmnoptions')} = igmnoptions();
    end
    self = igmn(options);
end
