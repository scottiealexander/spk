function TS(ifile,name,kunit,fts,fwf,varargin)

% spk.write.TS
%
% Description: write timestamp and waveform files
%
% Syntax: spk.write.TS(ifile,name,kunit,ts,wf,<options>)
%
% In:
%       ifile - the original .smr file
%       name  - the name of the channel
%       kunit - the unit number (for the given channel)
%       ts    - vector or timestamps
%       wf    - matrix of waveforms, nsample x nspike
%   options:
%       dir   - (<auto>) output directory
% Out:
%
% Updated: 2016-05-13
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

opt = ParseOpts(varargin,...
    'dir' , [] ...
    );

chan = spk.load.ChanLabels(ifile);
kchan = spk.load.Label2Index(ifile, name);

if isempty(kchan)
    error('Failed to locate channel number');
end

if isempty(opt.dir)
    p = Path(ifile);
    p = fullfile(p.parent,p.name);
else
    p = opt.dir;
end

if ~isdir(p)
    mkdir(p);
else
    cf = FindFiles(p,[sprintf('%02f',kchan) '\-\d\d\.ts']);
    if ~isempty(cf)
        tmp = cellfun(@(x) str2double(getfield(regexp(x,'\d\d\-(?<unit>\d+)\.ts$','names'),'unit')),cf);
        if any(tmp==kunit)
            kunit = max(tmp)+1;
        end
    end
end

tsfile = fullfile(p,sprintf('%02d-%02d.ts',kchan,kunit));
wffile = Path(tsfile).swap('ext','wf');

fid = fopen(tsfile,'w');
if fid > 0
    fwrite(fid,fts,'double');
    fclose(fid);
else
    error('Failed to open file %s for writing',tsfile);
end

fid = fopen(wffile,'w');
if fid > 0
    [row,col] = size(fwf);
    fwrite(fid,row,'uint64');
    fwrite(fid,col,'uint64');
    fwrite(fid,reshape(fwf,[],1),'double');
    fclose(fid);
else
    error('Failed to open file %s for writing',tsfile);
end
