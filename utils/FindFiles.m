function c = FindFiles(strdir,re)

% FindFiles
%
% Description: find files in a given directory that match a regex pattern
%
% Syntax: c = FindFiles(strdir,re)
%
% In:
%       strdir - the path to a directory in which to search
%       re     - a regular expression pattern
%
% Out:
%       c - a cell of paths to files, or an empty cell if no matches were found
%
% Updated: 2014-08-07
% Scottie Alexander

s = dir(strdir);
s([s(:).isdir]) = [];

brm = arrayfun(@(x) ~isempty(regexp(x.name,'^\.|~$','match','once')),s);
s(brm) = [];

bgood = arrayfun(@(x) ~isempty(regexp(x.name,re,'match','once')),s);

c = arrayfun(@(x) fullfile(strdir,x.name),s(bgood),'uni',false);