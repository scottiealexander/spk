function kernel = Run(spk_ts,evt_ts,varargin)

% Run
%
% Description: compute spike-triggered average
%
% Syntax: kernel = spk.sta.Run(spk_ts,evt_ts,<options>)
%
% In:
%       spk_ts - vector of spike timestamps
%       evt_ts - vector of event (frame) timestamps
%   options:
%       seq - (<auto>) the msequence frames or raw vector
%
% Out:
%       kernel - STA kernel at a 16x16x16 array (frame 1 is the first frame
%                following a spike, frame 2 is the second etc...)
%
% See also:
%       spk.sta.Plot
%
% Updated: 2015-02-20
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

opt = ParseOpts(varargin,...
    'seq' , [] ...
    );

if isempty(opt.seq) || isvector(opt.seq)
    mseq = mseq_gen('seq',opt.seq);
end

spk_hist = histc(spk_ts,evt_ts);

kbin = find(spk_hist);

kernel = zeros(size(mseq,1),size(mseq,2),16);
for k = 16:numel(kbin)    
    kernel = kernel + (mseq(:,:,(kbin(k)-15):kbin(k)).* spk_hist(kbin(k)));
end

kernel = kernel/(numel(kbin)-1);

%flip the frames around so frame 1 is the first frame proceeding each spike
kernel = kernel(:,:,16:-1:1);