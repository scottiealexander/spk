classdef Contrast < spk.tune.Base
% spk.tune.Contrast
%
% Description: a class implementation of contrast tuning analysis
%              uses Hill equation (aka hyperbolic ratio)
%
% Syntax: c = spk.tune.Contrast(ifile,<options>)
%
% In:
%
% Out:
%
%
% Methods:
%
% See Also:
%       spk.tune.Base
%
% Updated: 2015-09-29
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
    function self = Contrast(ifile,varargin)
        self = self@spk.tune.Base(ifile,varargin{:});
    end
    %-------------------------------------------------------------------------%
end
%PUBLIC METHODS---------------------------------------------------------------%

%STATIC METHODS---------------------------------------------------------------%
methods (Static=true)
    %-------------------------------------------------------------------------%
    function [p0,lb,ub] = Parameters(x,y)
        mx = max(y);
        hh = min(y) + (range(y)/2);
        c50 = x(find(y(2:end) >= hh,1,'first')+1);
        p0 = [mx c50 1 0];
        lb = [0 min(x) 0 0];
        ub = [mx*1.5 max(x) 10 min(y)];
        if ub(end) == 0
            ub(end) = .00001;
        end
    end
    %-------------------------------------------------------------------------%
    function y = Fit(p,x)
        % x    - the stimulus contrast
        % p(1) - the maximum response
        % p(2) - C50, contrast that evokes a half max response
        % p(3) - the exponent that determines the steepness of the curve
        % p(4) - the spontaneous rate
        % Source: Scalr et al. 1990: "Coding of image contrast in the central
        % visual pathway of the macaque monkey"
        y = p(1) * (x.^p(3) ./ (x.^p(3) + p(2).^p(3))) + p(4);
    end
    %-------------------------------------------------------------------------%
    function ifo = FormatOutput(ifo)
        p = ifo.param;
        ifo.param = struct('C50',p(2),'n',p(3),'base',p(4),'max',p(1));
        hh = range(ifo.fit.y)/2;
        bhh = ifo.fit.y >= (min(ifo.fit.y)+hh);
        %ERROR: this should check on self.log (but it's static...)
        ifo.param.C50_interp = ifo.fit.x(find(bhh,1,'first'));
    end
    %-------------------------------------------------------------------------%
end
%STATIC METHODS---------------------------------------------------------------%
end