% Author: Peter Rogelj <peter.rogelj@upr.si>

function [ simUH ] = SimUH_H( h )
%SIMUH SimUH computes multi modality similarity based on point measure s_uh from joint histogram H.


p12e = (h+1) ./ sum(h(:)) ;
p12e = p12e/sum(p12e(:));

p12 = h ./ sum(h(:));

p11e = repmat( sum(p12e,1), [size(p12e,1),1] );
p22e = repmat( sum(p12e,2), [1 size(p12e,2)] );

tmp1= log( (p12e.^2)./(p11e.*p22e) );
tmp1(p12==0) = 0;

simUH= sum( sum ( p12 .* tmp1 ));

%H1= - sum( p1  .* log(p1) );
%H2= - sum( p1  .* log(p1) );
%H12= -sum(p(:) .* log(p(:)) );
%mi=H1+H2-H12;

end
