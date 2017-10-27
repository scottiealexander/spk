function c = ChanNames(ifile)
% spk.load.ChanNames
%
% Description:
%
% Syntax: spk.load.ChanNames(ifile)
%
% In:
%		ifile - path to a .smr file
%
% Out:
%		c - cell of channel names
%
% Updated: 2015-09-28
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

s = spk.load.ChanLabels(ifile);
c = reshape({s(:).label},[],1);
