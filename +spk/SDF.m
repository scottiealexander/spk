function sdf = SDF(psth,bin_size,sigma)
% spk.SDF
%
% Description:
%
% Syntax: sdf = spk.SDF(psth,bin_size,sigma)
%
% In:
%       psth     - a ntrial x ntimepoint psth matrix
%       bin_size - psth bin_size in seconds
%       sigma    - sigma for gaussion in seconds
%
% Out:
%       sdf - estimate of spike density
%
% Updated: 2015-10-29
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

x = sigma*10;

kernel = normpdf(-x:bin_size:x,0,sigma) * bin_size;
y = nan(size(psth));
for k = 1:size(psth,1)
    y(k,:) = conv(psth(k,:),kernel,'same');
end
sdf = mean(y,1);