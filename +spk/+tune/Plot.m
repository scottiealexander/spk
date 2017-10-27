function [h,out] = Plot(ifo,varargin)
% spk.tune.Plot
%
% Description: quick-n-dirty ploting for tuning result
%
% Syntax: h = spk.tune.Plot(ifo,<options>)
%
% In:
%       ifo - a struct, or cell or array of such
%   options:
%       xlabel     - ('') xlabel for plot
%       ylabel     - ('Response (spikes x sec^-1)') ylabel for plot
%       log        - (false) true to plot x-axis in log units
%       legend     - ({}) cell of labels for legend
%       error_type - ('bar') method for plotting error, 
%                    one of: ['bar','points']
%       desaturate - (false) true to desaturate fit lines
%
% Out:
%       h - handle to the figure containing the plot
%
% Updated: 2015-10-03
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

ylab = 'Response (spikes x sec^{-1})';
opt = ParseOpts(varargin,...
    'xlabel'      , ''    ,...
    'ylabel'      , ylab  ,...
    'log'         , false ,...
    'legend'      , {}    ,...
    'error_type'  , 'bar' ,...
    'desaturate'  , false ,...
    'parent'      , []     ...
    );

if isstruct(ifo)
    ifo = num2cell(ifo);
end

%nudge factor for x and y labels in inches
LABEL_OFFSET = .5;
ERROR_BAR_WIDTH = .03;

if isempty(opt.parent)
    h = figure(...
        'Name'        , 'Tuning Plot'     ,...
        'NumberTitle' , 'off'             ,...
        'Position'    , [100 100 800 600] ,...
        'Color'       , [1 1 1]            ...
        );

    ax = axes(...
        'Units'         , 'normalized' ,...
        'OuterPosition' , [0 0 1 1]    ,...
        'LineWidth'     , 4            ,...
        'FontSize'      , 14           ,...
        'Box'           , 'off'         ...
        );
elseif ishandle(opt.parent) && strcmpi(get(opt.parent,'Type'),'axes')
    h = get(opt.parent,'Parent');
    ax = opt.parent;    
end

[mn,mx,n] = cellfun(@(x) MMN(x.data.x),ifo);
[mnf,mxf,nf] = cellfun(@(x) MMN(x.fit.x),ifo);

mn = min([mn(:);mnf(:)]);
mx = max([mx(:);mxf(:)]);
n = max([n(:);nf(:)]);

if opt.log
    mn = log10(mn);
    mx = log10(mx);
end

if isinf(mn)
    min_range = 0;
else
    min_range = mn;
end

if isempty(opt.parent)
    set(ax,'XLim',[mn,mx]);
end

ebw = Inch2Data(ERROR_BAR_WIDTH,ax,mx-mn,'x');

[ymn,ymx,hl] = deal(nan(numel(ifo),1));
for k = 1:numel(ifo)
    if ~isfield(ifo{k}.data,'err')
        ifo{k}.data.err = nan(size(ifo{k}.data.x));
    end
    
    hl(k) = FitPlot(ifo{k}.fit.x,ifo{k}.fit.y,ifo{k}.color);

    [ymn(k),ymx(k)] = PlotOne(ifo{k}.data,ifo{k}.color);

    ymn(k) = min([ymn(k) min(ifo{k}.fit.y)]);
    ymx(k) = max([ymx(k) max(ifo{k}.fit.y)]);
end
if isempty(opt.parent)
    arrayfun(@(x) SendToBack(ax,x),hl);

    if ~isempty(opt.legend) && iscellstr(opt.legend) && numel(opt.legend) == numel(hl)
        hleg = legend(hl,opt.legend);
        set(hleg,'Box','off');
    end
end

ymx = max(ymx);
ymn = min(ymn);

xr = (mx-min_range)*.01;
yr = (ymx-ymn)*.02;

if isempty(opt.parent)
    set(ax,'XLim',[mn-xr mx+xr],'YLim',[0 ymx+yr]);
end

xlabel(ax,opt.xlabel,'Interpreter','tex','FontSize',14);
ylabel(ax,opt.ylabel,'Interpreter','tex','FontSize',14);

if opt.log && isempty(opt.parent)
    xtl = 10.^str2double(cellstr(get(ax,'XTickLabel')));
    xtl = arrayfun(@num2str,roundn(xtl,-2),'uni',false);
    set(ax,'XTickLabel',xtl);
end

if isempty(opt.parent)
    FixLabel('x');
    FixLabel('y');
    set(ax,'TickDir','out');
    set(ax,'TickLength',[.015 .025]);
end

out.fit = hl;
out.ax = ax;

%-----------------------------------------------------------------------------%
function [mn,mx] = PlotOne(dat,col)
    error_bars = true;
    if opt.log
        dat.x = log10(dat.x);
    end

    htmp = line(dat.x,dat.y,...
        'Color'      , col    ,...
        'LineStyle'  , 'none' ,...
        'Marker'     , '.'    ,...
        'MarkerSize' , 24     ,...
        'Parent'     , ax      ...
        );

    if strcmpi(opt.error_type,'none')
        mn = min(dat.y);
        mx = max(dat.y);
    elseif strncmpi(opt.error_type,'point',5)
        [mn,mx] = ErrorPts(dat.x,dat.raw,col);
    elseif ~all(isnan(dat.err))        
        [mn,mx] = ErrorBars(dat.x,dat.y,dat.err,col);        
    else
        mn = min(dat.y);
        mx = max(dat.y);
    end
end
%-----------------------------------------------------------------------------%
function hl = FitPlot(x,y,col)
    if opt.log
        x = log10(x);
    end
    if opt.desaturate
        col = FitColor(col);
    end
    hl = line(x,y,...
        'Color'      , col ,...
        'LineStyle'  , '-' ,...
        'LineWidth'  , 3.5   ,...
        'Parent'     , ax   ...
        );
end
%-----------------------------------------------------------------------------%
function [mn,mx] = ErrorBars(x,y,e,col)
    x = reshape(x,1,[]);
    y = reshape(y,1,[]);
    e = reshape(e,1,[]);
    line([x; x],[y-e; y+e],'Color',col,'LineWidth',3,'Parent',ax);
    line([x-ebw; x+ebw],[y-e; y-e],'Color',col,'LineWidth',3,'Parent',ax);
    line([x-ebw; x+ebw],[y+e; y+e],'Color',col,'LineWidth',3,'Parent',ax);
    mn = min(y-e);
    mx = max(y+e);
end
%-----------------------------------------------------------------------------%
function [mn,mx] = ErrorPts(x,pts,col)
    if opt.desaturate
        col = FitColor(col);
    end
    line(x,transpose(pts),...
        'LineStyle'  , 'none' ,...
        'Marker'     , '.'    ,...
        'MarkerSize' , 16     ,...
        'Color'      , col     ...
        );
    mn = min(pts(:));
    mx = max(pts(:));
end
%-----------------------------------------------------------------------------%
function [mn,mx,n] = MMN(x)
    mn = min(x);
    mx = max(x);
    n = numel(x);
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
function FixLabel(typ)
    lim = 'XY';
    if strcmpi(typ,'x')
        kp = 2;
    else
        kp = 1;
    end
    typ = upper(typ);    
    lim = get(ax,[lim(kp) 'Lim']);
    if isinf(lim(1))
        lim(1) = 0;
    end
    htmp = get(ax,[typ 'Label']);
    pos = get(htmp,'Position');
    inc = Inch2Data(LABEL_OFFSET,ax,diff(lim),typ);
    pos(kp) = lim(1) - inc;
    set(htmp,'Position',pos);
end
%-----------------------------------------------------------------------------%
function cole = FitColor(col)
    fErr = 8;
    fEdge = .6;
    hsv = rgb2hsv(col);
    hsv(2) = hsv(2)/fErr;
    hsv(3) = 1 - abs(1-hsv(2))^fErr/fErr;        
    colf = hsv2rgb(min(1,hsv));
    cole = (1-fEdge)*colf + fEdge*col;
end
%-----------------------------------------------------------------------------%
function SendToBack(ax,h)
    hChild = reshape(get(ax,'Children'),[],1);
    h = reshape(h,[],1);
    hChild(ismember(hChild,h)) = [];
    hChild = [hChild;h];
    set(ax,'Children',hChild);
end
%-----------------------------------------------------------------------------%
end