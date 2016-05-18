classdef SpatialFrequency < spk.tune.Base
% spk.tune.SpatialFrequency
%
% Description: spatial frequency tuning
%
% Syntax: sf = spk.tune.SpatialFrequency(ifile,<options>)
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
%       sf - an instance of the SpatialFrequency class
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
    monitor_distance = NaN;
end
%PUBLIC PROPERTIES------------------------------------------------------------%

%PUBLIC METHODS---------------------------------------------------------------%
methods
    %-------------------------------------------------------------------------%
    function self = SpatialFrequency(ifile,varargin)
        self = self@spk.tune.Base(ifile,varargin{:});
        opt = ParseOpts(varargin,...
            'monitor_distance', NaN ...
            );
        self.monitor_distance = opt.monitor_distance;
    end
    %-------------------------------------------------------------------------%
    function label = ConvertLabels(self,label)
        %convert sf labels in to degrees visual angle using monitor distance
        if ~isnan(self.monitor_distance)
            label = 360*atan(label./(2*self.monitor_distance))/pi;
        end
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

        p0 = [1 cf .5 x(1)];

        lb = [0 x(1) 0 x(1)];
        ub = [+Inf x(end) 1 x(end)];
    end
    %-------------------------------------------------------------------------%
    function y = Fit(p,x)
        %x    - spatial freq
        %p(1) - scaling constant
        %p(2) - characteristic spatial frequency (freq at which the response
        %       falls to 1/e of peak)
        %p(3) - integrated weight of surround relative to center
        %p(4) - characteristic spatial frequency of the surround
        y = p(1)*(exp(-((x./p(2)).^2)) - (p(3)*exp(-((x./p(4)).^2))));
    end
    %-------------------------------------------------------------------------%
    function ifo = FormatOutput(ifo)
        p = ifo.param;
        ifo.param = struct(...
            'scale_factor',    p(1) ,...
            'cf',              p(2) ,...
            'surround_weight', p(3) ,...
            'surround_cf',     p(4)  ...
            );
    end
    %-------------------------------------------------------------------------%
end
%STATIC METHODS---------------------------------------------------------------%
end
