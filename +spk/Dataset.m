classdef Dataset < handle
% spk.Dataset
%
% Description: a class representing a file or directory path
%
% Syntax: d = spk.Dataset(ifile)
%
% In:
%       ipath - the path to a directory of file
% Out:
%       d - an instance of the spk.Dataset class
%
% Methods:
%       GetTS     - get spike timestamps given channels/units
%       GetWF     - get spike waveforms given channels/units
%       Label2Idx - parse label string as chan-unit index list
%
% Updated: 2015-10-05
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

%PRIVATE PROPERTIES-----------------------------------------------------------%
properties (SetAccess=private)
    idir;
    ifile;
    chan;
    units;
end
%PRIVATE PROPERTIES-----------------------------------------------------------%

%PUBLIC METHODS---------------------------------------------------------------%
methods
    %-------------------------------------------------------------------------%
    function self = Dataset(ifile)
        pth = Path(ifile);
        if pth.isdir
            self.ifile = fullfile(pth.parent,[pth.name '.smr']);
            if exist(self.ifile,'file') ~= 2
                error('Failed to locate .smr file %s',self.ifile);
            end
            self.idir = char(pth);
        elseif pth.exists
            self.ifile = ifile;
            self.idir = fullfile(pth.parent,pth.name);
        else
            error('Input *MUST* be a existing .smr file or its associated directory');
        end
        self.chan = spk.load.ChanNames(self.ifile);
        self.GetUnitNames();
    end
    %-------------------------------------------------------------------------%
    function [chan,unit] = Label2Idx(self,str)
        % given a label of the form chan#-unit# (as the string \d\d-\d\d)
        % returns channel and unit index
        if ~iscell(str)
            str = {str};
        end
        [chan,unit] = deal(zeros(numel(str),1));
        for k = 1:numel(str)
            tmp = str2double(regexp(str{k},'\-','split'));
            chan(k) = tmp(1);
            unit(k) = tmp(2);
        end
    end
    %-------------------------------------------------------------------------%
    function [evt,lab,dur] = GetEvents(self)
        [evt,lab,dur] = spk.events.Filter(self.ifile);
    end
    %-------------------------------------------------------------------------%
    function fs = GetFS(self,varargin)
        fs = spk.load.FS(self.ifile,varargin{:});
    end
    %-------------------------------------------------------------------------%
    function varargout = GetTS(self,chan,varargin)
        % [ts1,ts2,...,tsN] = d.GetTS(chan,[unit])
        c = self.FormatPaths('ts',chan,varargin{:});
        varargout = cellfun(@spk.load.TS,c,'uni',false);
    end
    %-------------------------------------------------------------------------%
    function varargout = GetWF(self,chan,varargin)
        % [wf1,wf2,...,wfN] = d.GetWF(chan,[unit])
        c = self.FormatPaths('wf',chan,varargin{:});
        varargout = cellfun(@spk.load.WF,c,'uni',false);
    end
    %-------------------------------------------------------------------------%
end
%PUBLIC METHODS---------------------------------------------------------------%

%PRIVATE METHODS--------------------------------------------------------------%
methods (Access=private)
    %-------------------------------------------------------------------------%
    function GetUnitNames(self)
        c = FindFiles(self.idir,'.*\.ts');
        self.units = cellfun(@(x) Path(x).name,c,'uni',false);
    end
    %-------------------------------------------------------------------------%
    function c = FormatPaths(self,ext,chan,varargin)
        if ischar(chan)
            kchan = self.Name2Idx(chan);
        elseif iscellstr(chan)
            kchan = cellfun(@self.Name2Idx,chan);
        elseif iscell(chan) && all(cellfun(@isnumeric,chan))
            kchan = cat(1,chan{:});
        elseif isnumeric(chan)
            kchan = reshape(chan,[],1);
        else
            error('Requested channel is not a valid channel');
        end

        nchan = numel(kchan);

        if isempty(varargin)
            units = ones(nchan,1);
        elseif isnumeric(varargin{1})
            units = reshape(varargin{1},[],1);
            n = nchan - numel(units);
            if n > 0
                units = [units; repmat(1,n,1)];
            end
        else
            error('Requested unit is not valid: units *MUST* be specified numericly');
        end

        c = arrayfun(@(x,y) sprintf('%02d-%02d',x,y),kchan,units,'uni',false);

        b = ismember(c,self.units);
        if ~all(b)
            error('Requested channel/units do not exist:\n\t%s',strjoin(reshape(c(~b),1,[]),'\n\t'));
        end
        if ext(1) ~= '.'
            ext = ['.' ext];
        end
        c = cellfun(@(x) fullfile(self.idir,[x ext]),c,'uni',false);
    end
    %-------------------------------------------------------------------------%
    function k = Name2Idx(self,name)
        k = find(strcmpi(name,self.chan),1,'first');
        if isempty(k)
            error('Channel %s does not exist',name);
        end
    end
    %-------------------------------------------------------------------------%
end
%PRIVATE METHODS--------------------------------------------------------------%
end
