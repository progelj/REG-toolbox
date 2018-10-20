% Author: Peter Rogelj <peter.rogelj@upr.si>

function [ img ] = moveOrigin( img0, O_new )
%MOVEORIGIN Summary of this function goes here
%   move origin moves origin to a new location defined by O_new parameter.
%   O_new is location location of the origin in the coordinate system
%   aligned with image coordinate system, but defined in millimeters
%   instead of pixels. It defines the point according to which the
%   transformation of image is defined.
%   Inputs:
%       - img0 - the input image structure (part of the REG structure)
%       - O_new - the new origin [ox,oy,oz] in millimeters
%   Output:
%       - img - output image structure (as part of REG), equal to the input
%               image structure (img0) but with the modified origin and
%               transformation T.

    img=img0;
    deltaO = O_new - img0.O;
    T2=eye(4);
    T2(1:3, 4) = deltaO;

    img.O = single(O_new);
    if isempty(img0.T),
        img.T=T2;
    else
        img.T = img0.T * T2;
    end

end
