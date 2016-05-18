function wf = WF(ifile)

% spk.load.WF
%
% Description:
%
% Syntax: spk.load.WF(ifile)
%
% In:
%
% Out:
%
% Updated: 2015-11-14
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

if ~iscell(ifile)
    ifile = {ifile};
end

wf = cell(numel(ifile),1);
for k = 1:numel(ifile)
    fid = fopen(ifile{k},'r');
    if fid > 0
        row = fread(fid,1,'uint64');
        col = fread(fid,1,'uint64');
        wf{k} = reshape(fread(fid,'double'),row,col);
        fclose(fid);
    else
        fprintf('[WARNING]: failed to open file %s\n',ifile);
    end
end

if numel(ifile) == 1
    wf = wf{1};
end