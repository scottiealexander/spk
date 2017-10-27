function coef = Wavelet(dat)

% spk.decomp.Wavelet
%
% Description:
%
% Syntax: coef = spk.decomp.Wavelet(dat)
%
% In:
%       dat - a nsample x nspike matrix of waveforms
%
% Out:
%       coef - a ncoefficient x nspike matrix
%
% Updated: 2014-11-08
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

%prevent lillietest from issuing a warning about really big/small p-values...
warning('off','stats:lillietest:OutOfRangePLow');
warning('off','stats:lillietest:OutOfRangePHigh');

[len,nspk] = size(dat);
cc = nan(size(dat));

inputs = 10;

for k = 1:nspk
    tmp = wavedec(dat(:,k),4,'haar');
    cc(:,k) = tmp(1:len);
end

for k = 1:len
    thr_dist = std(cc(k,:)) * 3;
    thr_dist_min = mean(cc(k,:)) - thr_dist;
    thr_dist_max = mean(cc(k,:)) + thr_dist;
    b = cc(k,:)>thr_dist_min & cc(k,:)<thr_dist_max;
    aux = cc(k,b);

    if length(aux) > 10;
        [~,~,sd(k)] = lillietest(aux);
    else
        sd(k) = 0;
    end
end

[~, kmx] = sort(sd);
kcc = kmx(len:-1:len-inputs+1);

coef = zeros(nspk,inputs);
for k = 1:nspk
    for j = 1:inputs
        coef(k,j) = cc(kcc(j),k);
    end
end

coef = transpose(coef);
