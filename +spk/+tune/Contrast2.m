classdef Contrast2 < spk.tune.Base
% spk.tune.Contrast2
%
% Description: a class implementation of contrast tuning analysis
%              uses splines instead of a model to derive C50
%
% Syntax: c = spk.tune.Contrast2(ifile,<options>)
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
% Updated: 2015-09-30
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
    function  p = RunFit(self,x,y)
        p = spline(x,y);
    end
    %-------------------------------------------------------------------------%
end
%PUBLIC METHODS---------------------------------------------------------------%

%STATIC METHODS---------------------------------------------------------------%
methods (Static=true)
    %-------------------------------------------------------------------------%
    function [p0,lb,ub] = Parameters(x,y)
        error('Virtual function must be defined in child class');
    end
    %-------------------------------------------------------------------------%
    function y = Fit(p,x)
        y = ppval(p,x);
    end
    %-------------------------------------------------------------------------%
end
%STATIC METHODS---------------------------------------------------------------%
end