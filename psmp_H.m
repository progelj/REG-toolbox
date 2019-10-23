% Author: Peter Rogelj <peter.rogelj@upr.si>

function [sim] = psmp_H( h12, psf)
%PSMP compute similarity from given joint intensity probability distribution
%P and point similarity function PSF
% Input parameters:
%   P   - joint intensity probability distribution or histogram (size 256x256)
%   PSF - point similarity function (size 256x256)
% Output:
%   sim - estimated similarity

h1=h12.*psf;
%sim = sum(h1(:))/sum(h12(:));
sim = sum(h1(:))/sum(h12(:));

end
