function Plot1D(f,p)
% spk.psd.Plot1D
%
% Description:
%
% Syntax: spk.psd.Plot1D(f,p)
%
% In:
%
% Out:
%
% Updated: 2015-11-13
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

LABEL_OFFSET = .5;

po = [100 100 800 600];

h = figure(...
    'NumberTitle' , 'off'  ,...
    'Name'        , 'PSD'  ,...
    'Position'    ,  po    ,...
    'Color'       , [1 1 1] ...
    );

ax = axes(...
    'Units'     , 'Normalized' ,...
    'Color'     , [1 1 1]      ,...
    'LineWidth' , 4            ,...
    'TickDir'   , 'out'        ,...
    'FontSize'  , 14            ...
    );

% this could be, and perhaps should be, a call to bar
hb = bar(ax,f(2:end),p(2:end),'grouped');
set(hb,'FaceColor',[0 0 1],'BarWidth',1);

% hl = line(f(2:end),p(2:end),'Color',[0 0 1],'LineWidth',4,'Parent',ax);

FixLabel('x');
FixLabel('y');

set(ax,'Box','off','TickDir','out','TickLength',[.015 .025],'LineWidth',4);
xlabel(ax,'Frequency (Hz)','FontSize',18);
ylabel(ax,'Power','FontSize',18);
xlim(ax,[0 max(f)+.5])

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