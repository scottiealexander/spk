classdef Orientation < spk.tune.Base
% spk.tune.Orientation
%
% Description: orientation / direction tuning
%
% Syntax: ori = spk.tune.Orientation(ifile,<options>)
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
%       ori - an instance of the Orientation class
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
    function self = Orientation(ifile,varargin)
        self = self@spk.tune.Base(ifile,varargin{:});
    end
    %-------------------------------------------------------------------------%
end
%PUBLIC METHODS---------------------------------------------------------------%

%STATIC METHODS---------------------------------------------------------------%
methods (Static=true)
    %-------------------------------------------------------------------------%
    function [p0,lb,ub] = Parameters(x,y)
        % NOTE: this will work whether or not the data are normalized as the
        % data will be passed here in the form in which it will be fit
        [ymx,kmx] = max(y);
        [ymn,kmn] = min(y);

        knull = spk.tune.Orientation.NearestOri(x, x(kmx), 180);

        p0 = [ymx, x(kmx), 60, 1, y(knull), ymn];

        lb = [ymn, min(x), 10, .001, 0, 0];
        ub = [ymx*10, max(x), 120, +Inf, +Inf, +Inf];
    end
    %-------------------------------------------------------------------------%
    function y = Fit(p,x)
        % x - direction of motion of grating
        % p(1) - response amplitude
        % p(2) - prefered direction
        % p(3) - std (width) of circular gaussians
        % p(4) - relative width of first peak
        % p(5) - amplitude of second peak
        % p(6) - baseline firing rate
        theta = deg2rad(p(2));
        sigma = deg2rad(p(3))^2;
        x = deg2rad(x);
        y = p(1) * ( ...
                    exp(-2*(1-cos(x-theta)) ./ (sigma*p(4)))         ...
                    + p(5) * exp(-2*(1-cos(x-theta-pi)) ./ sigma) ...
                   ) ...
           + p(6);
    end
    %-------------------------------------------------------------------------%
    function ifo = FormatOutput(ifo)
        p = ifo.param;
        ifo.param = struct(...
            'amplitude' , p(1) ,...
            'preferred_direction', p(2) ,...
            'std', p(3) ,...
            'relative_preferred_width', p(4) ,...
            'null_amplitude', p(5) ,...
            'baseline', p(6) ...
            );

        % caclulate osi and dsi (using a difference-over-sum metric)
        % NOTE: we are using the fit-interpolated data
        [mx, kpref] = max(ifo.fit.y);
        theta = ifo.fit.x(kpref);

        korth = spk.tune.Orientation.NearestOri(ifo.fit.x, theta, 90);
        ifo.param.osi = spk.tune.Orientation.DiffOverSum(mx, ifo.fit.y(korth));

        knull = spk.tune.Orientation.NearestOri(ifo.fit.x, theta, 180);
        ifo.param.dsi = spk.tune.Orientation.DiffOverSum(mx, ifo.fit.y(knull));
    end
    %-------------------------------------------------------------------------%
    function k = NearestOri(x, theta, offset)
        [~,k] = min(abs(x-mod(theta+offset, 360)));
    end
    %-------------------------------------------------------------------------%
    function d = DiffOverSum(a, b)
        d = (a - b) / (a + b);
    end
    %-------------------------------------------------------------------------%
end
%STATIC METHODS---------------------------------------------------------------%
end
