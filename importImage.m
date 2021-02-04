% Author: Peter Rogelj <peter.rogelj@upr.si>

function scale= importImage( REGIdx, imData, voxSize, scale )
%ImportImage from variable into REG structure
%Input parameters:
% REGIdx - index of image in the global REG structure
% imData - variable providing the image data (voxel values) of size [Nx, Ny, Nz]
% voxSize - image voxel size in all dimensions [Sx, Sy, Sz]
% scale - scaling for transition from original format to uint8 (for equaly loading images in series)


global REG
if nargin()<4
   scale=[0 0];
end
imData=squeeze(imData);
imSize = size(imData);


if strcmp(class(imData), 'uint8') % 1 if identical
    scale=[0 1];
else
    REG.img(REGIdx).data_orig=imData;
    if scale(2)>0,
        [im,scale]=im2uint8_(imData,scale);
    else
        [im,scale]=im2uint8_(imData);
    end
end

REG.img(REGIdx).name="var";
REG.img(REGIdx).path="imported";
REG.img(REGIdx).uid=[];
REG.img(REGIdx).voxelSize=single(voxSize);
REG.img(REGIdx).data=im;
REG.img(REGIdx).mask=[];
REG.img(REGIdx).ROI=[];
REG.img(REGIdx).O=single( (size(REG.img(REGIdx).data)-1) .* voxSize /2 );
REG.img(REGIdx).T=[];
REG.img(REGIdx).D=[];

if isfield(REG.img(REGIdx),'H')
    REG.img(REGIdx).H=[];
end
if isfield(REG.img(REGIdx),'P')
    REG.img(REGIdx).P=[];
end
if isfield(REG.img(REGIdx),'PSF')
    REG.img(REGIdx).PSF=[];
end
if isfield(REG.img(REGIdx),'sim')
    REG.img(REGIdx).sim=[];
end
if isfield(REG.img(REGIdx),'simWeight')
    REG.img(REGIdx).simWeight=[];
end
