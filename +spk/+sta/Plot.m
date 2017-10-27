function h = Plot(kernel,varargin)

% Plot
%
% Description: plot a STA kernel
%
% Syntax: h = Plot(kernel,<options>)
%
% In:
%       kernel - 16x16x16 array of STA frames
%   options:
%       colormap - ('usrey') the colormap to use
%       smooth   - (false) true to filter kernel with gaussian
%       size     - ([3,3]) size of gaussion filter in kernel units
%       sigma    - (.5) std of gaussian filter
%
% Out:
%       h - the handel to the figure
%
% See also:
%       spk.sta.Run
%
% Updated: 2015-02-24
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

opt = ParseOpts(varargin ,...
    'colormap' , 'usrey' ,...
    'smooth'   , false   ,...
    'size'     , [3,3]   ,...
    'sigma'    , .5       ...
    );

if opt.smooth
    f = fspecial('gaussian',opt.size,opt.sigma);
end

cmap = mseq_colormap(opt.colormap);

h = figure(...
    'NumberTitle', 'off'           ,...
    'Name'       , 'STA'           ,...
    'MenuBar'    , 'none'          ,...
    'Units'      , 'pixels'        ,...
    'Position'   , [240 10 800 740] ...
    );

kernel = scale_kernel(kernel);

if size(kernel,3) > 1
    %order the frames to be column-major (it looks nicer)
    order = transpose(reshape(1:16,4,4));
    for k = 1:size(kernel,3)
        ha = axesgrid(4,4,k,h,'pad',[.2 .3],'buffer',[.3 .2 .2 .2]); 
        PlotOne(kernel(:,:,order(k)));
        set(get(ha,'Title'),'String',sprintf('Frame %d',order(k)));
    end
else    
    ha = axesgrid(1,1,1,h,'pad',[.2 .3],'buffer',[.3 .2 .2 .2]);
    PlotOne(kernel);
    % set(get(ha,'Title'),'String','Gaussian Fit');
end

%-----------------------------------------------------------------------------%
function PlotOne(im)
    if opt.smooth
        im = imfilter(im,f,'replicate');
    end
    image(im);
    colormap(cmap);
    axis('square');
    set(ha,'Box','on','YTickLabel','','XTickLabel','','YTick',[],'XTick',[],'LineWidth',2);
end
%-----------------------------------------------------------------------------%
function x = scale_kernel(x)
    mx = max(x(:));
    mn = min(x(:));
    scl = max(abs([mx mn]));
    
    if scl == 0
        scl = 1;
    end

    sz = size(cmap,1);
    scl = 0.5*(sz - 1)/scl;
    
    x = round(x*scl + 0.5*(sz - 1));
end
%-----------------------------------------------------------------------------%
end