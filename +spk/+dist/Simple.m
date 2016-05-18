function coef = Simple(x,y,evt,varargin)

% spk.dist.Simple
%
% Description:
%
% Syntax: coef = spk.dist.Simple(x,y,evt,<options>)
%
% In:
%       x - a vector of time stamps
%       y - another vector of time stamps
%   options:
%       pre      - (0) pre event interval to include in seconds
%       post     - (0) post event interval to include in seconds
%       bin_size - (.0005) bin size in seconds
%       tau      - (.0005) synchronous window size in +/- seconds
%       shift    - ([]) shift period in seconds (leave empty to skip)
% Out:
%
% Updated: 2014-12-01
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

opt = ParseOpts(varargin,...
    'pre'     , 0     ,... %pre event interval to include in seconds
    'post'    , 0     ,... %post event interval to include in seconds
    'bin_size', .0005 ,... %bin size in seconds
    'tau'     , .0005 ,... %synchronous window size in +/- seconds
    'shift'   , []     ... %shift period in seconds
    );

xdat = spk.Segment(x,evt,'bin_size',opt.bin_size,'pre',opt.pre,'post',opt.post);
ydat = spk.Segment(y,evt,'bin_size',opt.bin_size,'pre',opt.pre,'post',opt.post);

win = floor(opt.tau / opt.bin_size);

coef = nan(size(xdat,1),1);
cshift = coef;

for k = 1:size(xdat,1)
    xk = find(xdat(k,:));
    yk = find(ydat(k,:));
    if ~isempty(xk) && ~isempty(yk)
        totl = sum([xdat(k,:),ydat(k,:)]);
        if isempty(opt.shift)
            sync = spk.PSTH(xk,yk,1,-win:win,'pad',true);
            sync = sum(sync(:));
        else            
            center = size(xdat,2);
            shift_win = center-1;
            psth = spk.PSTH(find(xdat(k,:)),find(ydat(k,:)),1,-shift_win:shift_win,'pad',true);
            if isvector(psth)
                coef(k) = 0;
                continue;
            end
            psth = sum(psth,1);
            sync = sum(psth(center-win:center+win));
            nshift = opt.shift/opt.bin_size;
            kshift = [center-nshift:-nshift:1 center+nshift:nshift:(shift_win*2)+1];
            npts = numel(psth);
            mshift = nan(size(kshift));
            for kS = 1:numel(kshift)
                kuse = kshift(kS)-win:kshift(kS)+win;
                kuse(kuse<1 | kuse>npts) = [];
                mshift(kS) = sum(psth(kuse));
            end
            sync = (sync - nanmean(mshift));
            if sync < 0
                sync = 0;
            end
        end
        coef(k) = sync / totl;
    else
        coef(k) = 0;
    end
end

%TODO
%   compute full xcorr b/t x(k,:) and y(k,:), sync = # of spks in zero bin +/- win
%       i.e. sum(sum(tmp(:,6000:6002)))
%   shuffle corr = mean number of spikes in harmonics of the temporal frequency