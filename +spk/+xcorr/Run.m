function [xc,t,sp] = Run(ts1,ts2,varargin)
% spk.xcorr.Run
%
% Description: cross-correlation between spikes of two units
%
% Syntax: [xc,t,sp] = spk.xcorr.Run(ts1,ts2,<options>)
%
% In:
%       ts1 - a vector of spike timestamps
%       ts2 - another vector of spike timestamps
%   options:
%       bin_size - (.0005) bin size to use of histogram
%       tmax     - (.015) max time (+/-) over which to calculate xcorr
%       tf       - ([]) stimulus temporal frequency in Hz
%       nshift   - (0) the number of shifts to average over in shift-predictor
%                  calculation
%
% Out:
%       xc - cross-correlation between ts1 and ts2
%       t  - vector of times associated with each sample in xc
%       sp - shift-predictor, same size and shape as xc
%
% Updated: 2015-10-03
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

opt = ParseOpts(varargin,...
    'bin_size' , .0005  ,...
    'tmax'     , .015   ,...
    'tf'       , []     ,...
    'nshift'   , 0       ...
    );

nbin = round(opt.tmax/opt.bin_size);
kbin = -nbin:nbin;

xc = mean(spk.PSTH(ts2,ts1,opt.bin_size,kbin,'pad',true),1) ./ opt.bin_size;

t = -opt.tmax:opt.bin_size:opt.tmax;

sp = zeros(1,numel(xc));
if opt.nshift > 0
    if isempty(opt.tf) || ~isnumeric(opt.tf)
        error('"tf" option is required for calculating shift-predictor');
    end
    sft = (1/opt.tf);
    for k = 1:opt.nshift
        sp = sp + mean(spk.PSTH(ts2,ts1+(k*sft),opt.bin_size,kbin,'pad',true),1);
    end
    sp = (sp ./ opt.nshift) ./ opt.bin_size;
end