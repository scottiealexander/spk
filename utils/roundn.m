function x = roundn(x,n)

% roundn
%
% Description: round to the nearest power of 10
%
% Syntax: x = roundn(x,n)
%
% In:
%       x - a scalar, vector, or matrix to round
%       n - the power of 10 to round to
%
% Out:
%       x - the input data rounded
%
% See also: round
%
% Updated: 2014-08-10
% Scottie Alexander

x = round(x.*(10^-n))./10^-n;