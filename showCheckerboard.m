% Author: Peter Rogelj <peter.rogelj@upr.si>

function [ d ] = showCheckerboard( A, B, z )
%SHOWCHECKERBOARD Summary of this function goes here
%   show two images in chackerboard pattern

if exist('z','var'),
    % nothing to do, use z
else
    z=floor(size(A,3)/2);
end
Ap=A(:,:,z);
Bp=B(:,:,z);

s1=size(A,1);
s2=size(A,2);
tileSize=floor( max(s1,s2)/10 );%20; %-------------------- setting
n1=floor(s1/tileSize)+1;
n2=floor(s2/tileSize)+1;
c= checkerboard(tileSize,n1,n2);
c=c(1:s1,1:s2);
d= zeros(size(c));

d(c==1) = Ap(c==1);
d(c==0) = Bp(c==0);

if nargout==0,
    imagesc(d);
end

end
