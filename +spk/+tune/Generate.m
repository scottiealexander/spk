function Generate(name)
% spk.tune.Generate
%
% Description:
%
% Syntax: spk.tune.Generate(name)
%
% In:
%       name - the name of the new child class for spk.tune.Base
%
% Out:
%
% Updated: 2015-09-30
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

pth = Path(mfilename('fullpath'));
to = Path(pth.swap('name',name)).swap('ext','m');

pth2 = Path(pth.swap('name','Tune'));
from = pth2.swap('ext','template');

from = Path(from);
str = from.readtext();
str = regexprep(str,'\#NAME\#',regexprep(name,'\.m$',''));

to = Path(to);
to.writetext(str);