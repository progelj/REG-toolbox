% Author: Peter Rogelj <peter.rogelj@upr.si>

function [ mi ] = SimMI( p )
%SIMMI SimMI computes Mutual Information from joint probability density
%function P.
%   MI = H(A) + H(B) - H(A,B) ;
%    H = -sum (p*log(p));

p1=sum(p,1);
p2=sum(p,2);

H1= - sum( p1  .* log(p1) );
H2= - sum( p1  .* log(p1) );
H12= -sum(p(:) .* log(p(:)) );
mi=H1+H2-H12;

end
