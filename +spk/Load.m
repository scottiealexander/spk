function d = Load(ifile,name)

% spk.Load
%
% Description: load a single channel of data from a Spike2 .smr file
%
% Syntax: d = spk.Load(ifile,name)
%
% In:
%       ifile - the path to a Spike2 .smr file
%       name  - the name or index of the channel to load
%
% Out:
%       d - a struct of data
%
% Updated: 2014-11-08
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

[~,~,ext] = fileparts(ifile);

switch lower(ext)
case '.smr'
    d = spk.load.SMR(ifile,name);
case '.ts'
    d.ts = spk.load.TS(ifile);
otherwise
    if strncmpi(ifile,'sim',3)
        base_dir = fileparts(mfilename('fullpath'));
        sim_file = fullfile(base_dir,'data','C_Easy1_noise01.mat');
        d.d = getfield(load(sim_file,'data'),'data');
        d.fs = 1e3/getfield(load(sim_file,'samplingInterval'),'samplingInterval');
    else
        error('Invalid file');
    end
end