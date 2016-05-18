function [h,ax] = Plot(xc,t,varargin)
% spk.scorr.Plot
%
% Description:
%
% Syntax: [h,ax] = spk.scorr.Plot(xc,t,<options>)
%
% In:
%       xc - results of cross-correlation (i.e. spk.xcorr.Run)
%       t  - vector of times associated with each sample in xc
%   options:
%       sp - ([]) shift-predictor, same size and shape as xc
%       color - ('black') xcorr bar color
%       sp_color - ('cyan') shift predictor line color
%
% Out:
%       h  - handle to the resultant plot
%       ax - handle to axes containing xcorr plot
%
% Updated: 2016-01-29
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

opt = ParseOpts(varargin,...
    'shift'   , []     ,...
    'color'   , 'black',...
    'sp_color', 'cyan'  ...
    );

LABEL_OFFSET = .5;

h = figure(...
    'Name'        , 'XCorr'           ,...
    'NumberTitle' , 'off'             ,...
    'Position'    , [100 100 800 600] ,...
    'Color'       , [1 1 1]            ...
    );

ax = axes();

hb = bar(ax,t,xc,'grouped');

if ischar(opt.color)
    col = mge.Color(opt.color);
elseif isnumeric(opt.color) && numel(opt.color) == 3
    col = opt.color;
else
    col = [0 0 0];
end
set(hb,'FaceColor',col,'EdgeColor',col);

%bar might be the worst function of all time, not only does it turn Box back
%on, but it also resets the axes LineWidth and FontSize
set(ax,...
    'Units'         , 'normalized' ,...
    'OuterPosition' , [0 0 1 1]    ,...
    'LineWidth'     , 4            ,...
    'FontSize'      , 14           ,...
    'Box'           , 'off'         ...
    );

if ~isempty(opt.shift)
    if ischar(opt.sp_color)
        col2 = mge.Color(opt.sp_color);
    elseif isnumeric(opt.sp_color) && numel(opt.sp_color) == 3
        col2 = opt.sp_color;
    else
        col2 = [0 1 1];
    end
    hl = line(t,opt.shift,'Color',col2,'LineWidth',3,'Parent',ax);
end

mn = min(t);
mx = max(t);
xr = abs(mx-mn)*.01;

set(ax,'XLim',[mn-xr mx+xr]);

xlabel(ax,'Time lag (sec)','FontSize',14);
ylabel(ax,'Response (spikes * sec^{-1})','FontSize',14);

FixLabel('x');
FixLabel('y');
set(ax,'TickDir','out');
set(ax,'TickLength',[.015 .025]);
%-----------------------------------------------------------------------------%
function FixLabel(typ)
    lim = 'XY';
    if strcmpi(typ,'x')
        kp = 2;
    else
        kp = 1;
    end
    typ = upper(typ);
    lim = get(ax,[lim(kp) 'Lim']);
    htmp = get(ax,[typ 'Label']);
    pos = get(htmp,'Position');
    inc = Inch2Data(LABEL_OFFSET,ax,diff(lim),typ);
    pos(kp) = lim(1) - inc;
    set(htmp,'Position',pos);
end
%-----------------------------------------------------------------------------%
function d = Inch2Data(in,ax,rg,dim)
    px = get(0,'ScreenPixelsPerInch')*in;
    set(ax,'Units','pixels');
    pos = get(ax,'Position');
    set(ax,'Units','normalized');
    switch lower(dim)
    case {'w','x'}
        kt = 3;
    case {'h','y'}
        kt = 4;
    otherwise
        error('Invalid dimention');
    end
    d = px * (rg / pos(kt));
end
%-----------------------------------------------------------------------------%
end