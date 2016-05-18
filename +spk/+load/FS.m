function fs = FS(ifile,varargin)
% spk.load.FS
%
% Description: load the sampling rate in HERTZ for a channel
%
% Syntax: spk.load.FS(ifile,[channel])
%
% In:
%       ifile     - the path to a .smr file
%       [channel] - the name or index of the channel to get the sampling rate
%                   for, if unspecified all channels with a valid sampling rate
%                   will be queried
%
% Out:
%       fs - the sampling rate of the channel(s) in HERTZ, if [channel] is not
%            specified and all rates are the same only a single value is
%            returned
%
% Updated: 2015-11-15
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

if ~isempty(varargin) && ~isempty(varargin{1})
    name = varargin{1};
    idx = spk.load.Label2Index(ifile, name);
    fs = smr_channel_fs(ifile, idx);

else
    chan = spk.load.ChanLabels(ifile);
    fs = zeros(numel(chan), 1);

    % we should stop being lazy as write a more efficient mex interface that
    % can take an array of indicies...
    for k = 1:numel(chan)
        fs[k] = smr_channel_fs(ifile, chan(k).index);
    end

    if all(fs == fs[1])
        fs = fs[1];
    end
end
