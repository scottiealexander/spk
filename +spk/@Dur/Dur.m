classdef Dur < handle

% spk.Dur
%
% Description: a class representing a duration of time
%
% Syntax: d = spk.Dur(t,[unit]='s')
%
% In:
%       t      - a double representing a duration magnitude *OR* a string
%                representing a magnitude and unit of duration (e.g '1.2sec')
%       [unit] - the unit of time that t represents *IFF* t is a double
%
% Out:
%       d - a duration object
%
% Updated: 2014-11-30
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

%PUBLIC PROPERTIES------------------------------------------------------------%
properties
    rep;
    unit;
end
%PUBLIC PROPERTIES------------------------------------------------------------%

%PRIVATE PROPERTIES-----------------------------------------------------------%
properties (Access=private)

end
%PRIVATE PROPERTIES-----------------------------------------------------------%

%PUBLIC METHODS---------------------------------------------------------------%
methods
    %-------------------------------------------------------------------------%
    function self = Dur(t,varargin)
        if isnumeric(t)
            [~,self.unit] = self.get_coef(varargin);
        elseif ischar(t)
            re = regexp(t,'(?<n>[\d\.\+\-e]*)\s*(?<u>[a-zA-z]*)','names');
            t = str2double(re.n);
            [~,self.unit] = self.get_coef(re.u);
        else
            error('Invalid input type %s',class(t));
        end
        self.rep = self.to_sec(self.unit,t);        
    end
    %-------------------------------------------------------------------------%
    function varargout = to(self,unit)
        [~,unit] = self.get_coef(unit);
        if nargout
            varargout{1} = spk.Dur(self.from_sec(unit),unit);
        else
            self.unit = unit;
        end
    end
    %-------------------------------------------------------------------------%
    function disp(self)
        mag = self.from_sec(self.unit);
        unt = self.unit;
        if mag ~= 1
            unt = [unt 's'];
        end        
        fprintf('%f %s\n',mag,unt);
    end
    %-------------------------------------------------------------------------%
    function varargout = plus(self,d)
        if nargout
            varargout{1} = self.op(d,@plus);
        else
            self.op(d,@plus);
        end
    end
    %-------------------------------------------------------------------------%
    function varargout = minus(self,d)
        if nargout
            varargout{1} = self.op(d,@minus);
        else
            self.op(d,@minus);
        end
    end
    %-------------------------------------------------------------------------%
    function varargout = times(self,d)
        if nargout
            varargout{1} = self.op(d,@times);
        else
            self.op(d,@times);
        end
    end
    %-------------------------------------------------------------------------%
    function varartout = mtimes(self,d)
        if nargout
            varargout{1} = self.op(d,@times);
        else
            self.op(d,@times);
        end
    end
    %-------------------------------------------------------------------------%
    function varargout = rdivide(self,d)
        if nargout
            varargout{1} = self.op(d,@rdivide);
        else
            self.op(d,@rdivide);
        end
    end
    %-------------------------------------------------------------------------%
    function varargout = mrdivide(self,d)
        if nargout
            varargout{1} = self.op(d,@rdivide);
        else
            self.op(d,@rdivide);
        end
    end
    %-------------------------------------------------------------------------%
    function varargout = op(self,other,f)
        if strcmpi(class(other),'dur')
            x = f(self.rep,other.rep);            
        elseif isnumeric(other) || islogical(other)
            x = f(self.rep,other);
        else
            error('Invalid operation between objects of class Dur and %s',class(other));
        end
        if nargout
            varargout{1} = spk.Dur(x,self.unit);
        else
            self.rep = x;
        end
    end
    %-------------------------------------------------------------------------%
    function str = class(self)
        str = 'Dur';
    end
    %-------------------------------------------------------------------------%
    function x = double(self)
    %returns the duration in seconds
        x = self.rep;
    end
    %-------------------------------------------------------------------------%
end
%PUBLIC METHODS---------------------------------------------------------------%

%PRIVATE METHODS--------------------------------------------------------------%
methods (Access=private)
    %-------------------------------------------------------------------------%
    function d = to_sec(self,unit,varargin)
        d = self.cvt(unit,@times,varargin{:});
    end
    %-------------------------------------------------------------------------%
    function d = from_sec(self,unit,varargin)
        d = self.cvt(unit,@rdivide,varargin{:});
    end
    %-------------------------------------------------------------------------%
    function d = cvt(self,unit,f,varargin)
        if isempty(varargin)
            d = self.rep;
        else
            d = varargin{1};
        end
        d = f(d, self.get_coef(unit));
    end
    %-------------------------------------------------------------------------%
end
%PRIVATE METHODS--------------------------------------------------------------%

%PRIVATE STATIC METHODS-------------------------------------------------------%
methods (Access=private,Static=true)
    %-------------------------------------------------------------------------%
    function [x,unit] = get_coef(unit)
        if iscell(unit)
            if ~isempty(unit)                
                unit = unit{1};
            else
                unit = 's';
            end
        end
        if ~ischar(unit)
            error('invalid unit');            
        end

        %remove a trailing s if present
        switch lower(regexprep(unit,'\w+s$',''))
        case {'year','yr','y'}
            x = 3.15569e+7;
            unit = 'year';
        case {'month','mon'}
            x = 2.63e+6;
            unit = 'month';
        case {'day','d'}
            x = 86400;
            unit = 'day';
        case {'hour','hr','h'}
            x = 3600;
            unit = 'hour';
        case {'minute','min','m'}
            x = 60;
            unit = 'minute';
        case {'second','sec','s'}
            x = 1;
            unit = 'second';
        case {'millisecond','millisec','millis','ms'}
            x = 1e-3;
            unit = 'millisecond';
        case {'microsecond','microsec','micros','us'}
            x = 1e-6;
            unit = 'microsecond';
        case {'nanosecond','nanosec','nanos','ns'}
            x = 1e-9;
            unit = 'nanosecond';
        otherwise
            error('%s is not a valid unit of time',unit);
        end
    end
    %-------------------------------------------------------------------------%
end
%PRIVATE STATIC METHODS-------------------------------------------------------%

%STATIC METHODS---------------------------------------------------------------%
methods (Static=true)
    %-------------------------------------------------------------------------%
    function x = t2k(x,fs)
        x = floor(x * fs) + 1;
    end
    %-------------------------------------------------------------------------%
    function x = k2t(x,fs)
        x = (x-1) / fs;
    end
    %-------------------------------------------------------------------------%
end
%STATIC METHODS---------------------------------------------------------------%
end