function [evt,label,dur] = Filter(ifile)
% spk.events.Filter
%
% Description: attempts to automatically remove spurious events from event
%              timestamps
%
% Syntax: [evt,label,dur] = spk.events.Filter(ifile)
%
% In:
%       ifile - a .smr file from which to read and filter events
%
% Out:
%       evt   - a vector of event start (i.e. stim-on) timestamps
%       label - the label (i.e. stimulus value) of each event
%       dur   - the duration of the stimulus according to the .par file
%
% Updated: 2015-10-04
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

pm = spk.ParameterMap(ifile);

if ~isempty(pm.title)
    tmp = regexprep(pm.title,'[Tt]uning','');
    type = lower(regexp(tmp,'\w+ \w*','match','once'));
    label = pm.Get(type);
else
    type = pm.Get('type','domain','tuning  parameters');
    label = pm.Get('values','domain','tuning parameters');
end

if sum(size(label)>1) == 1
    %if label is a vector make sure it's a column
    label = reshape(label,[],1);
else
    if all(diff(label(:,1))==1)
        %remove first column
        label = label(:,2);
    else
        error('Labels from .par file are poorly formatted!');    
    end
end

if strcmpi(pm.fmt,'daniel')
    dur = pm.Get('signal duration');
else
    dur = pm.Get('stimulus duration');    
end

if strcmpi(pm.evt_channel,'stim')
    %NOTE: this is a hack and should NOT be relied on in the long term
    [evt,txt] = spk.load.Events(ifile,'name','untitled');
    buse = cellfun(@(x) strcmp(x,'+'),txt);
    evt = evt(find(buse)-1);
    nevt = numel(evt);
    if numel(label) > nevt
        label = label(1:nevt);
        msg = 'Inconsistency detected in event time stamps, attempting to continue';
        warning('Filter:Events',msg);
    end
    return;
else
    evt = spk.load.Events(ifile,'name',pm.evt_channel);
end

df = reshape(diff(evt),[],1);
bdur = df >= dur*.9 & df <= dur*1.1;

if pm.IsLabel('blank duration')
    blank_dur = pm.Get('blank duration');
    buse = bdur;
    if dur == blank_dur
        %remove every other event (to remove stim off events)
        buse(2:2:end) = false;
    else
        if abs(df(end)-blank_dur) < abs(df(end)-dur)
            %last event marks stimulus start so chop it off
            buse = [buse; false];
        end
    end
else
    %the proportion of events that are of length dur
    n = sum(bdur) / numel(df);
    if n <= .1
        %few / no events are of length dur: events only mark stim onset
        total_dur = nanmedian(df);
        buse = [df >= total_dur*.9 & df <= total_dur*1.1; true];
    elseif n >= .9
        %most / all events are of length dur: events mark on and offset of stim
        %and blank_dur == stim_dur
        blank_dur = dur;
        buse = bdur;        
        buse(2:2:end) = false;
    elseif n > .4 && n < .6
        %~50% of events are of length dur: events mark on and offset of stim
        %and blank_dur != stim_dur
        blank_dur = nanmedian(df(~bdur));
        buse = bdur & (df >= blank_dur*.9 & df <= blank_dur*1.1);
        if abs(df(end)-blank_dur) < abs(df(end)-dur)
            %last event marks stimulus start so chop it off
            buse = [buse; false];
        end
    else
        error('Event durations are too inconsistent to estimate blank duration');
    end
end

%remove spurious events
evt = evt(buse);

nevt = sum(buse);
if nevt > numel(label)
    error('Inconsistency detected in event time stamps');
elseif numel(label) > nevt
    label = label(1:nevt);
    msg = 'Inconsistency detected in event time stamps, attempting to continue';
    warning('Filter:Events',msg);
end