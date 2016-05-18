function [b,n] = isnumstr(str)

% isnumstr
%
% Description: check if a string or cell of such represents a number
%
% Syntax: [b,n] = isnumstr(str)
%
% In:
%       str - a string
%
% Out:
%       b - a logical indicating whether str represents a number
%       n - the result of the attempted conversion to double
%
% Updated: 2015-10-04
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

n = str2double(str);
b = ~isnan(n);
bnan = strcmpi(str,'nan');
n(bnan) = NaN;
b(bnan) = true;

% str2double is faster than regexp
% pat = '^[+\-]?\d+\.?e[+\-]?\d+$|^[+\-]?\d+\.?$|^[+\-]?\d*\.\d+e[+\-]?\d+$|^[+\-]?\d*\.\d+$';
% b = ~isempty(regexp(str,pat));