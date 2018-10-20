% Author: Peter Rogelj <peter.rogelj@upr.si>

function [ p12 ] = h2p( h12 )
% REG=h2p(REG) estimate prob. density function from histogram without prior knowledge

p12 = h12+1;
p12 = p12 ./ sum( p12(:) );

end
