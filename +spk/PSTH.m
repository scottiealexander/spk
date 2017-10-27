function [evt_psth,cgrp] = PSTH(spk_ts,evt_ts,bin_size,kbin,varargin)

% spk.PSTH
%
% Description: peri-stimulus time histogram
%
% Syntax: [evt_psth,cgrp] = spk.PSTH(spk_ts,evt_ts,bin_size,kbin,<options>)
%
% In:
%       spk_ts  - a vector of spike time stamps
%       evt_ts  - a vector of event time stamps
%       bin_siz - the bin size (in the same units as spk_ts and evt_ts)
%       kbin    - the bins indicies (relative to the event bin) to include in
%                 the psth i.e. bin 0 is the bin in which the event occured,
%                 bin 1 is one bin post-event, bin -1 is one bin pre-event
%   options:
%       pad     - (false) true to zero-pad spike histogram to force each event
%                 to have a row in the output psth
%       grp_dim - ('bin') the dimention along which to group spike indicies for
%                 'cgrp' output, one of:
%                     'bin': each cell of cgrp contains the indicies of the
%                            spikes assigned to that bin
%                     'trial': each cell of cgrp contains the indicies of the
%                              spikes assigned to that trial
%
% Out:
%       evt_psth - the peri-stimulus time histogram (as a ntrial x nbin matrix)
%                  aligned to the event
%       cgrp     - a 1 x nbin cell where each element contains the indices
%                  of the spk_ts vector elements that contributed to that bin
%
% Updated: 2015-11-14
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

opt = ParseOpts(varargin,...
    'pad'     , false ,...
    'grp_dim' , 'bin'  ...
    );

t_mx = max([max(spk_ts) max(evt_ts)]);
bins = 0:bin_size:t_mx;
bins = [-inf  bins(1:end-1) + bin_size/2 inf];

%resample timestamps to binned representation according to bin_size and kbin
%   kevt: the index within the binned timeseries at which each event occured
%         i.e. kevt == find(histc(evt_ts,bins))
[~,kevt] = histc(evt_ts,bins);
[spk_hist,kspk] = histc(spk_ts,bins);

kevt = reshape(kevt,[],1);
kbin = reshape(kbin,1,[]);

if opt.pad
    %pad spike histogram with zeros so that the full winodw can be extracted
    %around each event
    kmx = max(kevt) + max(kbin);
    kmn = min(kevt) + min(kbin);
    if kmn > 1
        kmn = 0;
    else
        kmn = abs(kmn)+1;
    end

    spk_hist = [zeros(kmn,1); reshape(spk_hist,[],1); zeros(kmx - numel(spk_hist),1)];

    %adjust indicies for zero-padding
    kevt = kevt+kmn;
    kspk = kspk+kmn;

    if max(kevt) + max(kbin) > numel(spk_hist) | min(kevt) + min(kbin) < 1
        error('Das ist faul');
    end
else
    brm = kevt + max(kbin) > numel(spk_hist) | kevt + min(kbin) < 1;
    kevt(brm) = [];
end

seed_mat = repmat(kevt,1,numel(kbin)) + repmat(kbin,numel(kevt),1);

evt_psth = spk_hist(seed_mat);

%calculate the spike indices that contribute to each bin
if nargout > 1
    if max(spk_hist) > 1
        warning('PSTH:BinViolation','multiple spikes have been assinged to the same bin');
    end

    %recreate the spike histogram but using indices to 'tag' where each
    %non-zero value in the histogram came from
    tmp = zeros(size(spk_hist));
    tmp(kspk) = 1:numel(kspk);
    tmp = tmp(seed_mat);

    switch lower(opt.grp_dim)
    case 'bin'
        %group our matrix column wise (so each column ends up as a cell element)
        cgrp = mat2cell(tmp,size(tmp,1),ones(size(tmp,2),1));
    case 'trial'
        cgrp = mat2cell(tmp,ones(size(tmp,1),1),size(tmp,2));
    otherwise
        error('Invalid grouping dimention: must be either "bin" or "trial"');
    end

    %make cells with no spikes empty
    cgrp = cellfun(@(x) x(x>0),cgrp,'uni',false);
end