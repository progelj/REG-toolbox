% Author: Peter Rogelj <peter.rogelj@upr.si>

function [ fx ] = subsample( x, dimensions )
%SUBSAMPLE
%  subsample subsamples a 3D array in the given directions, defined with
%  a 3 element dimensions vector. The subsampling (decimation) is performed if a
%  corresponding dimensions element is >0.

s=size(x);
step=[1 1 1]+ 1.0 * (dimensions(1:3)>0);
fx=x(1:step(1):s(1), 1:step(2):s(2), 1:step(3):s(3));

end
