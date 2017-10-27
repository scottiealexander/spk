function ifo = PAR(ifile)
% spk.load.PAR
%
% Description: read a Henry Alitto formatted spike2 .par file
%
% Syntax: ifo = spk.load.PAR(ifile)
%
% In:
%       ifile - path to a .smr or .par file
%
% Out:
%       ifo - struct reprsenting the field:value pairs in the par file
%
% Updated: 2015-09-28
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

p = Path(ifile);
if ~strcmpi(p.ext,'par')
    p = Path(p.swap('ext','par'));
end 

if p.exists
    str = p.readtext();
else
    msg = ['Input file "%s" is not a .par file and no ',...
           'corresponding par file could be located'    ...
          ];
    error(msg,ifile);
end

str(str==13) = [];

%replace sections that resemble:
%   <domain_type>
%   --------------
%with:
%   ###<domain_type>
%in order to facilitate chuncking by domain
re = regexp(str,'\n+(?<domain>[\w ]+)\n+[\-]{2,}\n+','names');
pat = ['(' strjoin({re(:).domain},')\n|(') ')\n'];
str = regexprep(regexprep(str,pat,'###$1\n'),'\n\-{2,}\n','');
re = regexp(str,'\#{3}(?<domain>[\w ]+)\n*(?<block>.*?(?=\#{3}|\n*$))','names');

ifo = struct('domain',[],'label',[],'value',[],'unit',[]);
inc = 1;
for kD = 1:numel(re)
    tmp = regexp(re(kD).block,'(?<field>[^:\n]*)\s*:\s+(?<val>[^\n]*)\n*','names');

    cf = strtrim({tmp(:).field});
    cv = strtrim({tmp(:).val});
    
    for k = 1:numel(cf)
        [field,unit] = ParseUnits(cf{k});
        field = ParseMultiField(field);
        b = iscell(field);
        val = ParseValue(cv{k},b);
        if b
            for kF = 1:numel(field)
                ifo(inc) = struct('domain',lower(re(kD).domain),'label',field{kF},'value',val{kF},'unit',unit);
                inc = inc+1;
            end
        else
            ifo(inc) = struct('domain',lower(re(kD).domain),'label',field,'value',val,'unit',unit);
            inc = inc+1;
        end
    end
end

%-----------------------------------------------------------------------------%
function [field,unit] = ParseUnits(str)
    unit = '';    
    tmp = regexp(str,'[^\(]*(?<unit>\([\w%, ]*\))','names');
    if ~isempty(tmp)
        str = strrep(str,tmp.unit,'');
        unit = lower(regexprep(tmp.unit,'\W',''));
    end
    field = lower(strtrim(strrep(str,'#','num ')));
end
%-----------------------------------------------------------------------------%
function c = ParseMultiField(field)
    c = field;
    if sum(field==',') > 1
        c = strtrim(regexp(c,'\s*,\s*','split'));
    end
end
%-----------------------------------------------------------------------------%
function val = ParseValue(str,bmulti)
    [bnl,lst] = isnumlist(str);
    if bnl
        val = lst;
        if bmulti
            val = num2cell(val);
        end
    else
        str = strtrim(str);
        tmp = regexp(str,'[^:]*:\s*(?<val>\w+)\s*','names');
        if ~isempty(tmp)
            val = lower(tmp.val);
        else
            val = str;
        end
    end
end
%-----------------------------------------------------------------------------%
function [b,l] = isnumlist(str)
    b = false;
    if sum(str==',') > 1
        str = strtrim(regexp(str,'[^\d\.\+\-e]*','split'));
        b = all(isnumstr(str));
    else
        b = isnumstr(str);
    end
    if b
        l = str2double(str);
    else
        l = [];
    end
end
%-----------------------------------------------------------------------------%
end