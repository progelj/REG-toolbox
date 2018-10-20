% Author: Peter Rogelj <peter.rogelj@upr.si>

function [ imgOut ] = interpCube( imgIn, voxSize )
%INTERPCUBE Summary of this function goes here
%   InterpCube resampls a 3D (imgIn) image such that voxels have the same
%   size (voxSize) in all three directions.
%   Image size (nimber of voxels) is defined such that the whole original
%   image gets covered.
%   Input parameters:
%       imgIn - input image structure
%       voxSize - voxel size in all three directions (scalar)
%   Output parameters:
%       imgOut - output image structure, with resampled data and MASK!!!
%       TODO.

sizeIn = imgIn.voxelSize .* size(imgIn.data);
xvIn=0: imgIn.voxelSize(1): (sizeIn(1)-imgIn.voxelSize(1));
yvIn=0: imgIn.voxelSize(2): (sizeIn(2)-imgIn.voxelSize(2));
zvIn=0: imgIn.voxelSize(3): (sizeIn(3)-imgIn.voxelSize(3));
xvOut=0: voxSize: (sizeIn(1)-imgIn.voxelSize(1));
yvOut=0: voxSize: (sizeIn(2)-imgIn.voxelSize(2));
zvOut=0: voxSize: (sizeIn(3)-imgIn.voxelSize(3));

[xqOut,yqOut,zqOut] = meshgrid(xvOut,yvOut,zvOut);

I2 = interp3( yvIn,xvIn,zvIn , double(imgIn.data), yqOut,xqOut,zqOut);
I2 = permute( uint8(I2), [2,1,3]);

imgOut=imgIn;
imgOut.data=I2;
imgOut.voxelSize=single([voxSize,voxSize,voxSize]);

if length(imgIn.mask)>0,
    I2 = interp3( yvIn,xvIn,zvIn , double(imgIn.mask), yqOut,xqOut,zqOut);
    I2 = permute( uint8(I2), [2,1,3]);
    imgOut.mask=I2;
end

end
