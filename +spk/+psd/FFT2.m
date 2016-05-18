function [p,f] = FFT2(ts,varargin)
% spk.psd.FFT2
%
% Description: spike train PSD using fft (not PSTH)
%
% Syntax: spk.psd.FFT2(ts,<options>)
%
% In:
%       ts - a vector of timestamps
%   options:
%       bin_size - (.001) bin size for auto-correlaton in seconds
%       fmax     - ([]) maximum frequency to return in psd
%
% Out:
%       p - psd estimate
%       f - the frequencies correspoding to p the elements of p
%
% See Also:
%       spk.psd.FFT, spk.psd.Plot1D
%
% Updated: 2015-12-08
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

%TODO: implement a gaussian resampling of psd so that the output is not so long

warning('spk.psd.FFT2:Incomplete','This function is not finished!');

opt = ParseOpts(varargin,...
    'bin_size' , .001 ,...
    'fmax'     , []    ...
    );

fs = 1/opt.bin_size;
k = reshape(round(ts*fs)+1,[],1);

x = zeros(max(k),1);
x(k) = 1;

npt = 2^nextpow2(2*numel(x)-1);

nf = floor(npt/2)+1;

f = fs.*reshape(0:nf-1,[],1)./npt;

if ~isempty(opt.fmax)
    b = f <= opt.fmax;
else
    b = true(size(f));
end

%NOTE:
% auto-correlation autocorr(x) = ifft(abs(fft(x)).^2), thus
% abs(fft(autocorr(x))).^2 == abs(fft(x)).^4
p = fft(x,npt);
p = abs(p(1:nf)).^4;

f = f(b);
p = p(b);
