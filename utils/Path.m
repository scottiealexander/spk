classdef Path < handle

% Path
%
% Description: a class representing a file or directory path
%
% Syntax: p = Path(ipath)
%
% In:
%       ipath - the path to a directory of file
% Out:
%       p - an instance of the Path class
%
% Methods:
%       append     - add a directory to a directory or file path
%       parts      - split a path into parent directory, name and extension
%       full       - join a path into parent directory, name and extension in a full
%                    file / directory path
%       split      - split a path into a cell of directory / file names
%       join       - join a cell of directory / file names into a path 
%       sub        - extract a sub-directory from a file / directory path
%       swap       - swap parent directory, name, or extension
%       isopen     - check if the file is open for reading / writing
%       open       - open the file for reading or writing
%       close      - close the file
%       writetext  - write text to file (overwrites contents)
%       appendtext - append text to file
%       readtext   - read text from file
%       char       - get underlying char representation
%
% Updated: 2015-03-05
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

%PUBLIC PROPERTIES------------------------------------------------------------%
properties
    isdir;
    exists;
    parent;
    name;
    ext;
    fid = -1;    
end
%PUBLIC PROPERTIES------------------------------------------------------------%

%PRIVATE PROPERTIES-----------------------------------------------------------%
properties (Access=private)
    rep;
    open_fmt = '';
end
%PRIVATE PROPERTIES-----------------------------------------------------------%

%PUBLIC METHODS---------------------------------------------------------------%
methods
    %-------------------------------------------------------------------------%
    function self = Path(str)
        self.isdir = exist(str,'dir') > 0   ;
        if ~self.isdir
            self.exists = exist(str,'file') > 0;
        else
            self.exists = true;    
        end        
        self.rep = str;
        [self.parent,self.name,self.ext] = self.parts();
    end
    %-------------------------------------------------------------------------%
    function x = append(self,varargin)        
        if self.isdir
            x = fullfile(self.rep,varargin{:});            
        elseif ~isempty(varargin) && ischar(varargin{1})
            x = self.swap('parent',fullfile(self.parent,varargin{1}));
        end
    end
    %-------------------------------------------------------------------------%
    function [fdir,fname,fext] = parts(self)
        [fdir,fname,fext] = fileparts(self.rep);
        fext = regexprep(fext,'^\.','');
    end
    %-------------------------------------------------------------------------%
    function x = full(self,fdir,fname,fext)
        fext = regexprep(fext,'^\.','');
        if ~self.isdir && ~isempty(fext)
            fname = [fname '.' fext];
        end
        x = fullfile(fdir,fname); 
    end
    %-------------------------------------------------------------------------%
    function x = join(self,c)
        n = numel(c);
        if n > 0
            tmp = cell(2,n);
            tmp(1,:) = reshape(c,1,[]);
            if strcmp(c{1},filesep) && n > 1
                tmp{1,1} = '';
            end
            tmp(2,:) = [repmat({filesep},1,n-1) {''}];        
            x = cat(2,tmp{:});
        else
            x = '';
        end
    end
    %-------------------------------------------------------------------------%
    function x = split(self)
        x = regexp(self.rep,filesep,'split');
        if isempty(x{1}) && isunix
            x{1} = filesep;
        end
    end
    %-------------------------------------------------------------------------%
    function x = sub(self,k)        
        c = self.split();
        n = numel(c);
        if ischar(k)
            if k == ':'
                k = n;
            else
                k = find(strcmpi(k,c));
                if isempty(k)
                    k = 0;
                end                
            end
        end
        if isnumeric(k)
            if k <= 0
                k = n + k;
            end            
            if k > n
                k = n;
            end
            x = self.join(c(1:k));            
        else
            error('Invalid input type %s',class(k));    
        end
    end
    %-------------------------------------------------------------------------%
    function x = swap(self,field,val)
        switch lower(field)
        case {'parent','directory','dir','folder'}
            x = self.full(val,self.name,self.ext);
        case {'name','filename'}
            x = self.full(self.parent,val,self.ext);
        case {'ext','extension'}
            x = self.full(self.parent,self.name,val);
        otherwise
            error('%s is not a valid or swapable field',field);
        end
    end
    %-------------------------------------------------------------------------%
    function x = switchdir(self,k,d)
        if ischar(k)
            x = strrep(self.rep,k,d);
        elseif isnumeric(k)
            if k
                c = self.split();
                n = numel(c);
                if k < 0
                    k = n + k;
                end
                if k > n
                    k = n;
                end
                c{k} = d;
                x = self.join(c);
            else
                x = self.rep;
            end
        end
    end
    %-------------------------------------------------------------------------%
    function b = isopen(self)
        b = false;
        fid_all = fopen('all');
        if ~isempty(fid_all)
            b = self.fid > 0 && any(fid_all == self.fid);
        end
        if ~b
            self.fid = -1;
        end
    end
    %-------------------------------------------------------------------------%
    function b = open(self,fmt)
        b = false;        
        if ~self.isdir            
            if self.isopen() && strcmpi(fmt,self.open_fmt)                
                b = true;
            else
                self.close();
                self.fid = fopen(self.rep,fmt);
                if self.fid > 0
                    self.open_fmt = fmt;
                    b = true;
                end
            end
        end
    end
    %-------------------------------------------------------------------------%
    function close(self)
        if self.isopen()
            fclose(self.fid);
            self.fid = -1;
        end
    end
    %-------------------------------------------------------------------------%
    function str = readtext(self)
        if self.open('r')
            str = transpose(fread(self.fid,'*char'));
            self.close();
        else
            str = '';
        end
    end
    %-------------------------------------------------------------------------%
    function b = writetext(self,str)
        b = self.write('w',str);
    end
    %-------------------------------------------------------------------------%
    function b = appendtext(self,str)        
        b = self.write('a',str);
    end
    %-------------------------------------------------------------------------%
    function x = char(self)
        x = self.rep;
    end
    %-------------------------------------------------------------------------%
    function x = class(self)
        x = 'Path';
    end
    %-------------------------------------------------------------------------%
    function disp(self)
        fprintf('%s\n',self.rep);
    end
    %-------------------------------------------------------------------------%
    function delete(self)
        self.close();
    end
    %-------------------------------------------------------------------------%
end
%PUBLIC METHODS---------------------------------------------------------------%

%PRIVATE METHODS--------------------------------------------------------------%
methods (Access=private)
    %-------------------------------------------------------------------------%
    function b = write(self,fmt,str)
        b = false;
        if self.open(fmt)
            fprintf(self.fid,'%s',str);
            self.close;
            b = true;
        end
    end
    %-------------------------------------------------------------------------%
end
%PRIVATE METHODS--------------------------------------------------------------%
end