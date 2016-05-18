function mseq = mseq_gen(varargin)

% mseq_gen
%
% Description: generate msequence frames from the raw 1x2^25 msequence vector
%
% Syntax: mseq = mseq_gen(<options>)
%
% In:
%   options:
%       seq - (<auto>) a 1x2^15 msequence vector, default is to load the usrey
%              lab sequence
%
% Out:
%       mseq - the msequence frames as a 16x16x2^15 array
%
% Updated: 2015-02-14
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

opt = ParseOpts(varargin,...
    'seq' , [] ...
    );

if isempty(opt.seq)
    cdir = fileparts(mfilename('fullpath'));
    seq = getfield(load(fullfile(cdir,'mseq_f537.mat'),'Mseq'),'Mseq');
else
    seq = opt.seq;
end

%sacle binary sequence to be {-1,1}
seq = (2*reshape(seq,1,[]))-1;

mseq = zeros(16,16,numel(seq));
inc = 1;
for row = 1:16
    for col = 1:16
        mseq(row,col,:) = [seq(inc:end) seq(1:inc-1)];
        inc = inc+128;
    end
end