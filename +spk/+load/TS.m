function ts = TS(ifile)

% spk.load.TS
%
% Description: load a timestamp file
%
% Syntax: ts = spk.load.TS(ifile)
%
% In:
%
% Out:
%
% Updated: 2015-03-11
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

if ~iscell(ifile)
    ifile = {ifile};
end

ts = cell(numel(ifile),1);
for k = 1:numel(ifile)
    fid = fopen(ifile{k},'r');
    if fid > 0
        ts{k} = fread(fid,'double');
        fclose(fid);
    else
        fprintf('[WARNING]: Unable to open file %s\n',ifile);        
    end
end

if numel(ifile) == 1
    ts = ts{1};
end