% Author: Peter Rogelj <peter.rogelj@upr.si>

function [ fx ] = linearfilter( x, dimensions, kernel )
%LINEARFILTER
%   linearfilter filters a 3D image such that a new pixel value is obtained
% by convolution filtering in all given directions. Directions are defined
% according to dimensions, which is a 3 element vector, defining if
% filtering is requested for each of the dimensions. If filtering in
% certain dimension, the corresponding dimensions element must be >0.
% Inputs:
%   x - 3D image to be filtered,
%   dimensions - 3 element vector defining if filtering is requested in
%   certain dimension, e.g., [1 0 0] means that filtering only takes place
%   in the first direction (column wise).
%   kernel - kernel used for convolution filtering (vector with odd number
%   of elements)
% Output:
%   fx - filtered image

kerneln=ones(1,3);
kerneln(1:3)=kernel(1:3);
kerneln=kerneln/sum(kerneln);

if dimensions(1)>0, % column-wise
    x = imfilter(x,kerneln');
end

if dimensions(2)>0, % row-wise
    x = imfilter(x,kerneln);
end

if dimensions(3)>0, % plane-wise
    kerneln3 = reshape(kerneln,[1 1 size(kerneln)]);
    x = imfilter(x,kerneln3);
end

fx=x;

end
