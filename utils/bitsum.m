function x = bitsum(x,varargin)

% bitsum
%
% Description: combine an array of integers into a sinlge representation
%
% Syntax: x = bitsum(x,<options>)
%
% In:
%       x       - an array of integers or doubles to treat as integers
%   options:
%       class - (class(x)) the integer class to use for the calculations
%       dim   - (<1st non-singleton>) the dimention along which to operate
%
% Out:
%       x - a double representation of the bitwise combination of the array
%
% Examples:
%       bitsum(uint8([3 1 0 0])) => 259
%       bitsum([255 2],'class','uint8') => 767
%       bitsum([1 1 0; 6 0 0],'class','uint16','dim',2) => [65537; 6]
%
% Updated: 2014-11-29
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

siz = size(x);
dim = find(siz > 1,1,'first');
if isempty(dim)
    dim = 1;
end

opt = ParseOpts(varargin,...
    'class' , class(x) ,...
    'dim'   , dim  ...
    );

ndim = numel(siz);
if opt.dim < 1
    opt.dim = 1;
elseif opt.dim > ndim
    opt.dim = ndim;
end

kdim = setdiff(1:ndim,opt.dim);
c1 = repmat({[]},1,ndim);
c1{kdim} = 1;

c2 = repmat({1},1,ndim);
c2{kdim} = siz(kdim);

tmp = repmat(double(intmax(opt.class))+1,siz) .^ repmat(reshape(0:siz(opt.dim)-1,c1{:}),c2{:});
x = sum(double(x).*tmp, opt.dim);