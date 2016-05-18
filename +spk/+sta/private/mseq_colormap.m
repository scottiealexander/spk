function cmap = mseq_colormap(type)

% mseq_colormap
%
% Description: load / return a blue->black->red->white colormap
%
% Syntax: mseq_colormap(type)
%
% In:
%       type - the type of colormap to use, one of:
%               'usrey': usrey lab blue->black->red->white colormap
%               '*': linear ramp blue->black->red->white colormap
%
% Out:
%       cmap - the colormap as a nx3 matrix
%
% Updated: 2015-02-14
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

if strcmpi(type,'usrey')
    cdir = fileparts(mfilename('fullpath'));
    cmap = getfield(load(fullfile(cdir,'cmap.mat')),'cmap');
else
    h = [.6*ones(32,1); ones(32,1)];
    s = [linspace(1/8,1,15)'; ones(32,1); linspace(1,0,17)'];
    v = [ones(16,1); linspace(1,0,16)'; linspace(0,1,16)'; ones(16,1)];
    cmap = hsv2rgb([h s v]);
end