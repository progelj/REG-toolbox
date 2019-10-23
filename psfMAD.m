% Author: Peter Rogelj <peter.rogelj@upr.si>

function [ PSF ] = psfMAD( p12 )
%PSFMI computes point similarity function analog to MAD similarity measure
%density function P = p12 is not required as the messure ins mono-modality one.

% return : PSF (point similarity function)

p11 = repmat(0:255,[256,1]);
p12 = p11'; 

PSF = -abs(p11-p12);

end
