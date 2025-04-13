% tight_subplot creates a grid of subplot axes with adjustable gaps and margins.
%
% Syntax:
%   [ha, pos] = tight_subplot(Nh, Nw, gap, marg_h, marg_w)
%
% Inputs:
%   Nh      - Number of axes in the vertical direction (rows).
%   Nw      - Number of axes in the horizontal direction (columns).
%   gap     - Gaps between the axes in normalized units (0 to 1). 
%             Can be a scalar for uniform gaps or a two-element vector [gap_h gap_w] 
%             for different gaps in height and width.
%   marg_h  - Margins in the vertical direction in normalized units (0 to 1). 
%             Can be a scalar for uniform margins or a two-element vector [lower upper] 
%             for different lower and upper margins.
%   marg_w  - Margins in the horizontal direction in normalized units (0 to 1). 
%             Can be a scalar for uniform margins or a two-element vector [left right] 
%             for different left and right margins.
%
% Outputs:
%   ha      - Array of handles to the axes objects, arranged row-wise starting 
%             from the upper-left corner.
%   pos     - Positions of the axes objects as an array of position vectors.
%
% Example:
%   ha = tight_subplot(3, 2, [.01 .03], [.1 .01], [.01 .01]);
%   for ii = 1:6
%       axes(ha(ii));
%       plot(randn(10, ii));
%   end
%   set(ha(1:4), 'XTickLabel', '');
%   set(ha, 'YTickLabel', '');
%
% Notes:
%   - This function is useful for creating subplot layouts with precise control 
%     over spacing and margins.
%   - The function was created by Pekka Kumpulainen on 21.5.2012 at Tampere 
%     University of Technology, Automation Science and Engineering.
function [ha, pos] = tight_subplot(Nh, Nw, gap, marg_h, marg_w)
    if nargin<3; gap = .02; end
    if nargin<4 || isempty(marg_h); marg_h = .05; end
    if nargin<5; marg_w = .05; end
    if isscalar(gap)
        gap = [gap gap];
    end
    if isscalar(marg_w)
        marg_w = [marg_w marg_w];
    end
    if isscalar(marg_h)
        marg_h = [marg_h marg_h];
    end
    axh = (1-sum(marg_h)-(Nh-1)*gap(1))/Nh; 
    axw = (1-sum(marg_w)-(Nw-1)*gap(2))/Nw;
    py = 1-marg_h(2)-axh; 
    % ha = zeros(Nh*Nw,1);
    ii = 0;
    for ih = 1:Nh
        px = marg_w(1);
        
        for ix = 1:Nw
            ii = ii+1;
            ha(ii) = axes('Units','normalized', ...
                'Position',[px py axw axh], ...
                'XTickLabel','', ...
                'YTickLabel',''); %#ok<AGROW>
            px = px+axw+gap(2);
        end
        py = py-axh-gap(1);
    end
    if nargout > 1
        pos = get(ha,'Position');
    end
    ha = ha(:);
end
