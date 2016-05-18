function [p,f] = FFT(ts,varargin)
% spk.psd.FFT
%
% Description: spike train PSD using fft (i.e. the fft of the
%              autocorrelation function)
%
% Syntax: spk.psd.FFT(ts,<options>)
%
% In:
%       ts - a vector of timestamps
%   options:
%       bin_size - (.001) bin size for xcorr in seconds
%       tmax     - (1) maximum lag (+-) for xcorr
%       fmax     - ([]) maximum frequency to return in psd
%
% Out:
%       p - psd estimate
%       f - the frequencies correspoding to p the elements of p
%
% See Also:
%       spk.psd.Plot1D
%
% Updated: 2015-11-13
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

opt = ParseOpts(varargin,...
    'bin_size' , .001 ,...
    'tmax'     , 1    ,...
    'fmax'     , []    ...
    );

x = spk.xcorr.Run(ts,ts,'bin_size',opt.bin_size,'tmax',opt.tmax);
x = reshape(x,[],1);

fs = 1/opt.bin_size;

npt = numel(x);

nf = floor(npt/2)+1;

f = fs.*reshape(0:nf-1,[],1)./npt;

if ~isempty(opt.fmax)
    b = f <= opt.fmax;
else
    b = true(size(f));
end

p = fft(x);
p = abs(p(1:nf)).^2;

f = f(b);
p = p(b);
