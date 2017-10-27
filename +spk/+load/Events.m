function [ts,val,mrk] = Events(ifile,varargin)

% spk.load.Events
%
% Description: load events from a text marker channel from a .smr file
%
% Syntax: [ts,val,mrk] = spk.load.Events(ifile,<options>)
%
% In:
%       ifile - the path to a .smr file
%   options:
%       name - ('pseudotex') the name of the event channel to load
%
% Out:
%       ts  - the timestamp for each event in seconds
%       val - the value of each event (double or cellstr)
%       mrk - the marker for each event (i.e. the event "type")
%             this is usually a vector of base 0 indices such that
%             if types = sort(unique(val)), then val == types(mrk+1)
%
% Updated: 2015-05-13
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

% Channel types:
% 1  : continuous data
% 2-4: event channel
% 5  : marker channel
% 6  : ADC marker channel (e.g. wave mark)
% 7  : real marker channel
% 8  : text marker channel

opt = ParseOpts(varargin,...
    'name' , 'pseudotex'...
    );

chan = spk.load.ChanLabels(ifile);
idx = spk.load.Label2Index(ifile, opt.name);
kchan = find([chan(:).index] == idx);

if ~isempty(idx)

    ifo = smr_read_channel(ifile, idx(1));

    switch chan(kchan).type
    case {2,3,5,8}
        ts = ifo.timestamps;

        % ifo.text is a nchar x nevent matrix, thus we group by column
        tmp = mat2cell(char(ifo.text'),...
            ones(size(ifo.text,2),1)  ,...
            size(ifo.text,1)           ...
            );

        % if all text info are numbers convert to double
        if isnumstr(tmp)
            val = str2double(tmp);
        else
            % remove trailing white space or null chars
            val = strtrim(deblank(tmp));
        end

        %the type / index of stimulus that was shown on each trial
        mrk = bitsum(ifo.markers,'dim',1);
    case 4
        ts = ifo;
        val = [];
        mrk = [];

    otherwise
        error('Given channel in not an event channel [%d]',chan(kchan(1)).type);
    end
else
    error('Failed to find any event channels in file %s',ifile);
end
