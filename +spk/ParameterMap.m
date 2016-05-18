classdef ParameterMap < handle

% spk.ParameterMap
%
% Description: a parameter-value pair map that allows for fuzzy parameter
%              searching/matching
%
% Syntax: pm = spk.ParameterMap(ifile,<options>)
%
% In:
%       ifile - the path to a spike2 .smr or .par file
%
% Out:
%       pm - an instance of the spk.ParameterMap class
%
% Methods:
%       Get - fetch a value using fuzzy parameter search
%
% See Also:
%       spk.ParameterMap.Get
%
% Updated: 2015-10-03
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

%PRIVATE PROPERTIES-----------------------------------------------------------%
properties (SetAccess=private)
    title;
    domain;
    label;
    value;
    unit;
    evt_channel;
    fmt;
end
%PRIVATE PROPERTIES-----------------------------------------------------------%

%PUBLIC METHODS---------------------------------------------------------------%
methods
    %-------------------------------------------------------------------------%
    function self = ParameterMap(ifile,varargin)
        pth = Path(ifile);
        ifile = pth.swap('ext','smr');
        self.GetFormat(ifile);
        switch self.fmt
        case 'henry'
            tmp = spk.load.PAR(ifile);
            field = fieldnames(tmp);
            for k = 1:numel(field)
                self.(field{k}) = reshape({tmp(:).(field{k})},[],1);
            end
        case 'daniel'
            tmp = spk.load.PAR2(ifile);            
            field = fieldnames(tmp);
            for k = 1:numel(field)
                self.(field{k}) = tmp.(field{k});
            end
        otherwise
            error('invalid format %s',opt.format);
        end        
    end
    %-------------------------------------------------------------------------%
    function GetFormat(self,ifile)
        chan = spk.load.ChanNames(ifile);
        if any(strcmpi('trigger',chan))
            self.fmt = 'daniel';
            self.evt_channel = 'Trigger';
        elseif any(ismember({'pseudotex','stim'},lower(chan)))
            self.fmt = 'henry';
            if any(strcmpi('pseudotex',chan))
                %if both exist, defer to pseudotex
                self.evt_channel = 'PseudoTex';
            else                
                self.evt_channel = 'Stim';
            end
        else
            error('Failed to auto-detect par file format');
        end
    end
    %-------------------------------------------------------------------------%
    function b = IsLabel(self,str)
    % b = spk.ParameterMap.IsLabel(str)
        b = any(strcmpi(str,self.label));
    end
    %-------------------------------------------------------------------------%
    function [val,unt] = Get(self,str,varargin)
    % spk.ParameterMap.Get
    %
    % Description: fetch the value(s) associated with the parameter that most
    %              closely matches the given parameter label   
    %
    % Syntax: [val,unt] = spk.ParameterMap.Get(str,<options>)
    %
    % In:
    %       str - the name of a parameter label to search for
    %   options:
    %       domain - ('') the domain within which to search for the parameter
    %       multi  - (false) true to allow multiple output if multiple matches
    %                are found (in which case outputs are cells)
    % Out:
    %       val - the value of the associated parameter
    %       unt - the units for each output value if any, otherwise an empty
    %             string
    %
    % See Also:
    %       spk.ParameterMap
    %
    % Updated: 2014-11-29
    % Scottie Alexander
    %
    % Please report bugs to: scottiealexander11@gmail.com

        opt = ParseOpts(varargin,...
            'domain' , ''  ,...
            'multi'  , false ...
            );

        if isempty(opt.domain)
            buse = true(size(self.domain));
        else
            dst = self.strdist(opt.domain,self.domain);
            buse = dst == min(dst);
        end

        dst = inf(size(buse));
        dst(buse) = self.strdist(str,self.label(buse));        
        breturn = dst == min(dst);

        if sum(breturn) > 1 && opt.multi
            val = self.value(breturn);
            unt = self.unit(breturn);
        else
            kreturn = find(breturn,1,'first');
            val = self.value{kreturn};
            unt = self.unit{kreturn};
        end
    end
    %-------------------------------------------------------------------------%    
end
%PUBLIC METHODS---------------------------------------------------------------%

%PRIVATE METHODS--------------------------------------------------------------%
methods (Access=private,Static=true)
    %-------------------------------------------------------------------------%
    function d = strdist(s,c)
        if isunix && ~ismac
            d = mx_levenshtein(s,c); 
        else
            d = cellfun(@(x) levenshtein(s,x),c);
        end
    end
    %-------------------------------------------------------------------------%
end
%PRIVATE METHODS--------------------------------------------------------------%
end