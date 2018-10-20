% Author: Peter Rogelj <peter.rogelj@upr.si>

function [ mi ] = SimMI_H( h )
%SIMMI SimMI computes Mutual Information from joint histogram H.
%   MI = H(A) + H(B) - H(A,B) ;
%    H = -sum (p*log(p));

p12e = (h+1) ./ sum(h(:)) ;
p12e = p12e/sum(p12e(:));

p12 = h ./ sum(h(:));

p11e = repmat( sum(p12e,1), [size(p12e,1),1] );
p22e = repmat( sum(p12e,2), [1 size(p12e,2)] );

tmp1= log( p12e./(p11e.*p22e) );
tmp1(p12==0) = 0;

mi= sum( sum ( p12 .* tmp1 ));

%H1= - sum( p1  .* log(p1) );
%H2= - sum( p1  .* log(p1) );
%H12= -sum(p(:) .* log(p(:)) );
%mi=H1+H2-H12;

end
