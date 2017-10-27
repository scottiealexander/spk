function s = PAR2(ifile)
% spk.load.PAR2
%
% Description: load contents of .par file in Daniel Rathbun format
%
% Syntax: spk.load.PAR2
%
% In:
%       ifile - path to .smr r .par file
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

s.title = regexprep(str(1:find(str==10,1,'first')),'\[|\]','');

re = regexp(str,'"(?<field>[^"]*)"\s*(?<val>[^\n]*)','names');
field = reshape({re(:).field},[],1);
val = reshape({re(:).val},[],1);

field_names = unique(field);
nfield = numel(field_names);

[s.label,s.value] = deal(cell(nfield,1));

for k = 1:nfield
    b = strcmpi(field_names{k},field);
    s.label{k} = field_names{k};
    s.value{k} = ParseVal(val(b));
end

s.domain = repmat({''},nfield,1);
s.unit = repmat({''},nfield,1);

%-----------------------------------------------------------------------------%
function x = ParseVal(x)
    bcell = iscell(x);
    if bcell &&  numel(x) == 1
        x = x{1};
        bcell = false;
    end
    [bnum,n] = isnumstr(x);
    if all(bnum)
        x = n;
    elseif bcell
        tmp = regexp(x,'\s+','split');
        if all(cellfun(@numel,tmp) == numel(tmp{1}))
            tmp = cat(1,tmp{:});
            [bnum,n] = isnumstr(tmp);
            if all(bnum)
                x = n;
            end
        end
    end
end
%-----------------------------------------------------------------------------%
end