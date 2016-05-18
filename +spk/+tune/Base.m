classdef Base < handle
% spk.tune.Base
%
% Description: abstract base class for implementing tuning analyses
%
% Syntax: b = spk.tune.Base(ifile,<options>)
%
% In:
%       ifile - the path to a .smr file
%   options:
%       channel   - ([]) channel to load if preprocessing is needed
%       ts        - ([]) vector of spike timestamps to use
%       bin_size  - (.001) bin size in seconds
%       log       - (false) true to log x data
%       normalize - (true) true to normalize y data before fitting
% Out:
%       b - an instance of the spk.tune.Base class
%
% Methods:
%       RunProc   - preprocess and run fitting (using Run)
%       Run       - prep and run fitting procedure
%       RunFit    - setup and call minimization function
%       F1XFM     - F1-transform - DFT at drift frequency
%       FitInterp - generate best fit vectors for plotting
%
% Virtual Methods:
%       Parameters  - generate initial conditions and bounds
%       Fit         - function representing the model to fit
%       Error       - error for objective function, defaults to error weighted
%                     sum of square error
%       FormatOuput - format output struct in tuning specific mannor
%
% See Also:
%       spk.tune.Contrast, spk.tune.Area
%
% Updated: 2015-09-30
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

%PUBLIC PROPERTIES------------------------------------------------------------%
properties
    bin_size;
    log;
    ts;
    channel;
    werror;
    result;
    ninterp = 200;
    normalize;
    use_error;
end
%PUBLIC PROPERTIES------------------------------------------------------------%

%PRIVATE PROPERTIES-----------------------------------------------------------%
properties (SetAccess=private)
    ifile;
end
%PRIVATE PROPERTIES-----------------------------------------------------------%

%PUBLIC METHODS---------------------------------------------------------------%
methods
    %-------------------------------------------------------------------------%
    function self = Base(ifile,varargin)
        opt = ParseOpts(varargin,...
            'channel'   , []     ,...
            'ts'        , []     ,...
            'bin_size'  , .001   ,...
            'log'       , false  ,...
            'normalize' , true   ,...
            'use_error' , false   ...
            );
        self.ifile = ifile;
        fn = fieldnames(opt);
        for k = 1:numel(fn)
            self.(fn{k}) = opt.(fn{k});
        end
    end
    %-------------------------------------------------------------------------%
    function [sf0,sf1] = RunProc(self,varargin)
        if isempty(self.ts)
            if isempty(self.channel)
                error('Neither channel name nor timestamps were provided');
            end
            self.ts = spk.Preprocess(ifile,self.channel);
        end

        [evt,label,dur] = spk.events.Filter(self.ifile);

        % this allows child classes an opportunity to conver labels as needed,
        % if they don't override the ConvertLabels method, nothing happens
        label = self.ConvertLabels(label);

        [y,x] = spk.Segment(self.ts,evt,...
            'pre'      , 0            ,...
            'post'     , dur          ,...
            'type'     , label        ,...
            'bin_size' , self.bin_size ...
            );

        tf = self.GetTF(self.ifile);

        % this is temporal frequency tuning, thus each trial need a specifc tf
        % for caclulating the f1
        if numel(tf) > 1
           tf = x;
        end

        [f0,f0e,f1,f1e] = self.F1XFM(y,tf,dur,self.bin_size);
        f0_raw = f0;
        f1_raw = f1;

        f0 = nanmean(f0,1);
        f1 = nanmean(f1,1);

        if self.normalize
            [f0,f0e] = varfun(@(x) x./max(f0),f0,f0e);
            [f1,f1e] = varfun(@(x) x./max(f1),f1,f1e);
        end

        sf0 = self.Run(x,f0,'err',f0e);
        sf1 = self.Run(x,f1,'err',f1e);

        sf0.data.raw = f0_raw;
        sf1.data.raw = f1_raw;
    end
    %-------------------------------------------------------------------------%
    function ifo = Run(self,x,y,varargin)
        % Syntax: ifo = spk.tune.Base.Run(x,y,<options>)
        %
        % In:
        %       x - stimulus label vector, same size as y
        %       y - data vector, one element per stimulus value
        %   options:
        %       err - ([]) vector a error/std across repeats, same size as y
        %
        % Out:
        %       ifo - a struct with fields: 'data','fit','param' with results
        %             from fitting procedure

        opt = ParseOpts(varargin,...
            'err'   , []  ...
            );

        if ~isempty(opt.err) && self.use_error
            %add fudge factor to prevent dividing by zero in self.Error
            self.werror = reshape(opt.err,size(y)) + 1e-6;
            ifo.data.err = self.werror;
        else
            self.werror = ones(size(y));
            ifo.data.err = nan(size(y));
        end

        x = reshape(x,size(y));

        p = self.RunFit(x,y);

        [ifo.fit.x,ifo.fit.y] = self.FitInterp(p,x);
        ifo.data.x = x;
        ifo.data.y = y;
        ifo.param = p;

        ifo = self.FormatOutput(ifo);
    end
    %-------------------------------------------------------------------------%
    function p = RunFit(self,x,y)
        os = optimoptions('lsqcurvefit','Display','off');
        [p0,lb,ub] = self.Parameters(x,y);
        p = lsqcurvefit(@(p,x,varargin) self.Objective(p,x),p0,x,y,lb,ub,os);
        %         os = optimoptions('fmincon','Algorithm','active-set','Display','off');
        %         os = optimset('LargeScale','off','Display','off');
        %         p = fmincon(@self.Objective,p0,[],[],[],[],lb,ub);
    end
    %-------------------------------------------------------------------------%
    function [f0,f0e,f1,f1e] = F1XFM(self,y,tf,dur,bin_size)
        %f1: discrete fourier transform of the data at the/each
        %temporal frequency

        npt = size(y{1},2);
        t = reshape(linspace(0,dur,npt),[],1);

        [f0,f0e] = cellfun(@(x) self.ME(x./bin_size),y,'uni',false);

        if numel(tf) == 1
            csw = exp(-1i*2*pi*tf*t);
            [f1,f1e] = cellfun(@(x) self.ME(abs(x*csw)),y,'uni',false);
        else
            if ~iscell(tf)
                tf = num2cell(tf);
            end
            [f1,f1e] = cellfun(@(x,y) self.ME(abs(x*exp(-1i*2*pi*y*t))),y,tf,'uni',false);
        end
        [f0,f0e,f1,f1e] = varfun(@self.Fill,f0,f0e,f1,f1e);
    end
    %-------------------------------------------------------------------------%
    function [x,y] = FitInterp(self,p,x)
        if self.log
            x = logspace(0,log10(max(x)),self.ninterp);
        else
            x = linspace(0,max(x),self.ninterp);
        end
        y = self.Fit(p,x);
    end
    %-------------------------------------------------------------------------%
    function label = ConvertLabels(self,label)
        label = label;
    end
    %-------------------------------------------------------------------------%
end
%PUBLIC METHODS---------------------------------------------------------------%

%PRIVATE METHODS--------------------------------------------------------------%
methods
    %-------------------------------------------------------------------------%
    function yf = Objective(self,p,x)
        yf = self.Fit(p,x);
        if any(isnan(yf))
            error('NANs found in Fit function output\n');
        end
    end
    %-------------------------------------------------------------------------%
    function e = Error(self,y,yf)
        %default error function is SSE weighted by error across repititions
        % if unspecificed, self.werror is a vector of ones
        e = sum(((yf-y).^2)./self.werror);
    end
    %-------------------------------------------------------------------------%
    function y = Fit(self,p,x)
        error('Virtual function must be defined in child class');
    end
    %-------------------------------------------------------------------------%
end
%PRIVATE METHODS--------------------------------------------------------------%

%STATIC METHODS---------------------------------------------------------------%
methods (Static=true)
    %-------------------------------------------------------------------------%
    function [p0,lb,ub] = Parameters(x,y)
        error('Virtual function must be defined in child class');
    end
    %-------------------------------------------------------------------------%
    function ifo = FormatOutput(ifo)
        ifo = ifo;
    end
    %-------------------------------------------------------------------------%
    function tf = GetTF(ifile)
        %this should be overwritten in temporal frequency tuning
        pm = spk.ParameterMap(ifile);
        tf = pm.Get('temporal frequency');
    end
    %-------------------------------------------------------------------------%
    function [d,e] = ME(d)
        if size(d,2) > 1
            %mean within trial if needed
            d = nanmean(d,2);
        end
        %stderr across trials
        e = nanstderr(d,[],1);
    end
    %-------------------------------------------------------------------------%
    function inp = Fill(inp)
        %fills array within a cell with nans so that all arrays are the same
        %size: this compensates for when some stimulus values were presented
        %fewer times than others
        mx = max(cellfun(@numel,inp));
        for k = 1:numel(inp)
            n = mx - numel(inp{k});
            inp{k} = [reshape(inp{k},[],1); nan(n,1)];
        end
        inp = cat(2,inp{:});
    end
    %-------------------------------------------------------------------------%
end
%STATIC METHODS---------------------------------------------------------------%
end
