% Author: Peter Rogelj <peter.rogelj@upr.si>

function [ I2 ] = interpolate( I, S )
%INTERPOLATE Summary of this function goes here
%   interpolate 3D image data to increase resolution in 2 in certain
%   directions, evident from original image size of input image I and
%   requested interpolated image size S = [sx,sy,sz]

%% find out in which directions to interpolate:
%printf("S = %f\n",S'); %debug

S0x=size(I,1);
S0y=size(I,2);
S0z=size(I,3);
xv=zeros(1,S(1));
yv=zeros(1,S(2));
zv=zeros(1,S(3));

if S(1) == S0x
    xv=0:(S0x-1);
else
    if ceil(S(1)/2) == S0x
        xv=0:0.5:(S(1)/2-0.5);
    else
        printf("old size iz x direction: %d, new size %d.\n", S0x, S(1));
        error('Invalid X size of requested resampled image!');
    end
end

if S(2) == S0y
    yv=0:(S0y-1);
else
    if ceil(S(2)/2) == S0y
        yv=0:0.5:(S(2)/2 -0.5);
    else
        printf("old size iz y direction: %d, new size %d.\n", S0y, S(2));
        error('Invalid X size of requested resampled image!');
    end
end

if S(3) == S0z
    zv=0:(S0z-1);
else
    if ceil(S(3)/2) == S0z
        zv=0:0.5:(S(3)/2 -0.5);
    else
        printf("old size iz z direction: %d, new size %d.\n", S0z, S(3));
        error('Invalid X size of requested resampled image!');
    end
end

[xq,yq,zq] = meshgrid(xv,yv,zv);
I2 = interp3(double(I), yq+1, xq+1, zq+1);
%I2 = interp3(double(I), yq+1,xq+1,zq+1,"spline"); % --- not working well -high error

I2 = permute( cast(I2,class(I)), [2,1,3]);

%% Extrapolate at the edge
if isnan(I2(S(1),1,1))
    I2(S(1),:,:)=I2(S(1)-1,:,:);
end
if isnan(I2(1,S(2),1))
    I2(:,S(2),:)=I2(:,S(2)-1,:);
end
if isnan(I2(1,1,S(3)))
    I2(:,:,S(3))=I2(:,:,S(3)-1);
end