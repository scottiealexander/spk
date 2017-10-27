function c = ChanLabels(ifile)

% spk.ChanLabels
%
% Description: load a struct array of information about each channel
%
% Syntax: s = spk.ChanLabels(ifile)
%
% In:
%       ifile - the path to a .smr file
%
% Out:
%       s - struct of info for each channel
%
% Updated: 2016-05-13
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

[~,~,ext] = fileparts(ifile);

switch lower(ext)
case '.smr'
    c = smr_channel_info(ifile);
otherwise
    error('file format %s is not supported',ext);
end

end
