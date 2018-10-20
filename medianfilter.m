function [ fx ] = medianfilter( x, dimensions )
%MEDIANFILTER 
% medianfilter filters a 3D image such that a new pixel value is obtained
% as a median in a surrounding region. The size of the region is defined
% according to dimensions, which is a 3 element vector, defining if
% filtering is requested for each of the dimensions. If filtering in
% certain dimension, the size of region in this dimension eqauls 3, else 1.
% Inputs: 
%   x - 3D image to be filtered,
%   dimensions - 3 element vector defining if filtering is requested in
%   certain dimension, e.g., [1 0 0] means that filtering only takes place
%   in the first direction (column wise).
% Output:
%   fx - filtered image

region=[1 1 1]+ 2 * (dimensions(1:3)>0);
fx = medfilt3 ( x, region);

end

