function d = SMR(ifile, name)

% spk.load.SMR
%
% Description: load a channel from a .smr file
%
% Syntax: d = spk.load.SMR(ifile,name)
%
% In:
%       ifile - the path to a spike2 .smr file
%       name  - the channel name or channel number to load
%
% Out:
%       d - a data struct
%
% Updated: 2016-05-13
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

chan = spk.load.ChanLabels(ifile);
kchan = spk.load.Label2Index(ifile, name);

% call mex function located in the private folder within spk.load
d = smr_read_channel(ifile, name);
