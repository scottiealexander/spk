classdef Area < spk.tune.Base
% spk.tune.Area
%
% Description:
%
% Syntax: c = spk.tune.Area(ifile,<options>)
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
% Updated: 2015-10-03
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

%CONSTANT PROPERTIES----------------------------------------------------------%
properties (Constant=true)
    step = 0.01;
end
%CONSTANT PROPERTIES----------------------------------------------------------%

%PUBLIC METHODS---------------------------------------------------------------%
methods
    %-------------------------------------------------------------------------%
    function self = Area(ifile,varargin)
        self = self@spk.tune.Base(ifile,varargin{:});
    end
    %-------------------------------------------------------------------------%
end
%PUBLIC METHODS---------------------------------------------------------------%

%PRIVATE METHODS--------------------------------------------------------------%
methods
    %-------------------------------------------------------------------------%
    function y = Fit(self,p,x)
        % x - vector of areas
        % p(1) - center weight
        % p(2) - surround weight
        % p(3) - center sigma
        % p(4) - surround sigma
        [Ge,Gi] = deal(nan(size(x)));
        for k = 1:numel(x)
            x_sub = -x(k)/2:self.step:x(k)/2;
            Ge(k) = trapz(exp(-1*((2*x_sub)./p(3)).^2));
            Gi(k) = trapz(exp(-1*((2*x_sub)./p(4)).^2));
        end
        y = p(1)*Ge*self.step - p(2)*Gi*self.step;
    end
    %-------------------------------------------------------------------------%
end
%PRIVATE METHODS--------------------------------------------------------------%

%STATIC METHODS---------------------------------------------------------------%
methods (Static=true)
    %-------------------------------------------------------------------------%
    function [p0,lb,ub] = Parameters(x,y)
        p0 = [max(y)*10, max(y)*2, .29, 1]; % initial conditions
        lb = [max(y)*2, max(y), .2, .66];  % lower  bounds
        ub = [+Inf, max(y)*5, 1.49, 3]; % upper bounds
    end
    %-------------------------------------------------------------------------%
    function ifo = FormatOutput(ifo)
        p = ifo.param;
        ifo.param = struct('ke',p(1),'ki',p(2),'se',p(3),'si',p(4));
    end
    %-------------------------------------------------------------------------%
end
%STATIC METHODS---------------------------------------------------------------%
end