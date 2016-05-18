function x = nanstderr(x,flag,dim)

% nanstderr
%
% Description: standard error of the mean excluding nans
%
% Syntax: x = nanstderr(x,flag,dim)
%
% In:
%       x    - the data as a vector or matrix
%       flag - see std
%       dim  - the dimention along which to calculate
%
% Out:
%       x - the standard error of x
%
% See also: nanstd, std
%
% Updated: 2014-08-10
% Scottie Alexander

x = nanstd(x,flag,dim)./sqrt(sum(~isnan(x),dim));
