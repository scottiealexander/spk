function s = SPIKE(x,y)

% spk.dist.SPIKE
%
% Description:
%
% Syntax: spk.dist.SPIKE
%
% In:
%
% Out:
%
% Updated: 2014-11-30
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com
bin_size = .0005;

nx = numel(x);
ny = numel(y);

t_mx = max([max(x) max(y)]);
bins = 0:bin_size:t_mx;
bins = [-inf  bins(1:end-1) + bin_size/2 inf];

[xh,xk] = histc(x,bins);
[yh,yk] = histc(y,bins);

if max(xh) > 1 || max(yh) > 1
    error('multiple spikes have been assinged to the same bin');
end

xi = zeros(size(xh));
xi(xk) = 1:nx;

yi = zeros(size(yh));
yi(yk) = 1:ny;