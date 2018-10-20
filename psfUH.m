% Author: Peter Rogelj <peter.rogelj@upr.si>

function [ PSF ] = psfUH( p12 )
%PSFMI computes point similarity function based on MI, from probability
%density function P = p12.
%Note that P(i,j) must be > 0!
% return : PSF (point similarity function

%p12 = REG.img(movIdx).P;
p11 = repmat( sum(p12,1), [size(p12,1),1] );
p22 = repmat( sum(p12,2), [1 size(p12,2)] );

PSF=log((p12.^2)./(p11.*p22));

end
