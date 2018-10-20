% Author: Peter Rogelj <peter.rogelj@upr.si>

function [ psf ] = h2psf_mi( H )
%H2PSF_MI computes Mutual information based point similarity function from
%joint histogram H
%   H shall be of size 256x256, single precision

%% prepare the data
% first check that elements of H are positive, normalize it to 1 and add
% eps to prevent problems at low joint probabilities. Eventually normalize
% again.

eps = 1./(256*256*256);
p12 = H ./ sum(H(:)) + eps;
p12 = p12 ./ sum(p12(:));
p11 = repmat( sum(p12,1), [size(H,1),1] );
p22 = repmat( sum(p12,2), [1 size(H,2)] );
psf= log(p12./(p11.*p22));

%% debug
% figure(1); imagesc(log(p12));
% figure(2); imagesc(log(p11));
% figure(3); imagesc(log(p22));
% figure(4); imagesc(psf); title('psf_mi','interpreter','none');
end
