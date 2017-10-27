function [data,label] = Segment(spk_ts,evt_ts,varargin)

% spk.Segment
%
% Description: segment a vector of spike timestamps based on a vecotr of event
%              timestamps using the spk.PSTH algorithm
%
% Syntax: [data,label] = spk.Segment(spk_ts,evt_ts,varargin)
%
% In:
%       spk_ts  - a vector of spike timestamps
%       evt_ts  - a vector of event timstamps
%   options:
%       type     - ([]) a nevent x 1 vector representing the type of each event
%                  leave empty to skip grouping trials by event type
%       pre      - (0) the amount of time pre-event to include in each trial
%       post     - (0) the amount of time post-event to include in each trial
%       bin_size - (.0005) the bin size in the same units as the timestamps
%
% Out:
%       data  - a ntrial x ntimepoint matrix of data, or a cell of such if the
%               'type' option is specified
%       label - a nevent x 1 vector of labels, one for each type of trial (i.e
%               element of 'data')
%
% See Also:
%       spk.PSTH
%
% Updated: 2015-02-13
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

opt = ParseOpts(varargin,...
    'type'     , []   ,...
    'pre'      , 0    ,...
    'post'     , 0    ,...
    'bin_size' , .0005 ...
    );

kbins = round(-abs(opt.pre)/opt.bin_size) : round(opt.post/opt.bin_size);
psth = spk.PSTH(spk_ts,evt_ts,opt.bin_size,kbins,'pad',true);

if ~isempty(opt.type) && numel(opt.type) == numel(evt_ts)
    opt.type = opt.type(1:size(psth,1));
    label = reshape(sort(unique(opt.type)),[],1);
    n = size(label,1);
    data = cell(n,1);
    for k = 1:n
        data{k} = psth(opt.type==label(k),:);
    end
else
    data = psth;
    label = [];
end