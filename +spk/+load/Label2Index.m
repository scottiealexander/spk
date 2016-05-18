function idx = Label2Index(ifile, chan)
% spk.load.Label2Index
%
% Description: convert a channel name to it's corresponding index
%
% Syntax: idx = spk.load.Label2Index(ifile, chan)
%
% In:
%       ifile - the path to a .smr file
%       chan  - a channel name as a string or integer
%
% Out:
%       idx - the index of the given channel
%
% Updated: 2016-05-13
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

ifo = spk.load.ChanLabels(ifile);

if ischar(chan)
    b = strcmpi(chan, {ifo(:).label});

    if ~any(b)
        error('The channel "%s" does not exist', name);
    end

    idx = ifo(b).index;

elseif isnumeric(chan)
    % just check to make sure the index is valid
    kall = [ifo(:).index];
    if any(kall == chan)
        idx = chan;
    else
        error('No channel with index [%d] exists', chan);
    end
else
    error('Invalid channel name given, *MUST* be a string or integer');
end
