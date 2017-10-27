function varargout = varfun(f,varargin)
% varfun
%
% Description:
%
% Syntax: [var1,...,varN] = varfun([var1],...,[varN])
%
% In:
%       f      - a handle to a function that takes one input and returns 
%                one output
%       [var1] - a variable to pass to the function f
%
% Out:
%       [var1] - results of passing var1 to function f
%
% Updated: 2015-10-03
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

varargout = cellfun(f,varargin,'uni',false);