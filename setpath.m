function setpath()
% setpath
%
% Description: add utils directory, which contains dependencies for the
%              the +spk package, to the matlab search path
%
% Syntax: setpath()
%
% In:
%
% Out:
%
% Updated: 2016-05-18
% Scottie Alexander

if exist('ParseOpt','file') ~= 2
    cur_dir = fileparts(mfilename('fullpath'));
    addpath(cur_dir);
    addpath(fullfile(cur_dir, 'utils'));
    msg = ['the "spk" package and its dependencies have been added to your',...
           'path, use the "savepath" command to save this addition to your',...
           'pathdef.m file\n'...
           ];
    fprintf(msg);
end
