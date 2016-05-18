classdef TemporalFrequency < spk.tune.Base
% spk.tune.TemporalFrequency
%
% Description: temporal frequency tuning
%
% Syntax: tf = spk.tune.TemporalFrequency(ifile,<options>)
%
% In:
%       ifile - the path to a .smr file
%   options:
%       channel   - ([]) channel to load if preprocessing is needed
%       ts        - ([]) vector of spike timestamps to use
%       bin_size  - (.001) bin size in seconds
%       log       - (false) true to log x data
%       normalize - (true) true to normalize y data before fitting
%
% Out:
%       tf - an instance of the TemporalFrequency class
%
% See Also:
%       spk.tune.Base
%
% Updated: 2016-05-13
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

%PUBLIC PROPERTIES------------------------------------------------------------%
properties
end
%PUBLIC PROPERTIES------------------------------------------------------------%

%PUBLIC METHODS---------------------------------------------------------------%
methods
    %-------------------------------------------------------------------------%
    function self = TemporalFrequency(ifile,varargin)
        self = self@spk.tune.Base(ifile,varargin{:});
    end
    %-------------------------------------------------------------------------%
end
%PUBLIC METHODS---------------------------------------------------------------%

%STATIC METHODS---------------------------------------------------------------%
methods (Static=true)
    %-------------------------------------------------------------------------%
    function [p0,lb,ub] = Parameters(x,y)
        % not sure why we exclude the first data point... perhaps due to noise
        % but this is how it was done in RFTune...
        x = x(2:end);
        y = y(2:end);

        y = y./max(y);

        [~,kmx] = max(y);
        kcf = find(y(kmx+1:end)<= 1/exp(1),1,'first')+kmx;
        cf = x(kcf);

        if isempty(cf)
            cf = x(end);
        end

        p0 = [1 cf 1 1];

        lb = [0 x(1) x(1) 0];
        ub = [+Inf x(end) x(end) +Inf];
    end
    %-------------------------------------------------------------------------%
    function y = Fit(p,x)
        %x    - temporal frequency
        %p(1) - scaling constant
        %p(2) - characteristic temporal frequency
        %p(3) - corner frequency of low frequency limb
        %p(4) - slope of low frequency limb
        y = (p(1)*exp(-(x/p(2)).^2)) ./ (1 + (p(3)./x).^p(4));
    end
    %-------------------------------------------------------------------------%
    function ifo = FormatOutput(ifo)
        p = ifo.param;
        ifo.param = struct(...
            'scale_factor',   p(1),...
            'cf',             p(2),...
            'corner_freq',    p(3),...
            'low_freq_slope', p(4) ...
            );
    end
    %-------------------------------------------------------------------------%
end
%STATIC METHODS---------------------------------------------------------------%
end
