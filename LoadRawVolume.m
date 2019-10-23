% Author: Peter Rogelj <peter.rogelj@upr.si>

function scale= LoadRawVolume( REGIdx, filePath, imSize, voxSize, type, endian, scale )
%LoadRawVolume loadds 3d image form raw file inro REG structure
%Input parameters:
% REGIdx - index of image in the global REG structure
% filepath - file name (including path)
% imSize - ima ge size (number of voxels in all dimensions) [Nx, Ny, Nz]
% voxSize - image voxel size in all dimensions [Sx, Sy, Sz]
% type - data type to read from the file, e.g. 'uint8'
% endian - big or little endian: 'ieee-le' (default) or 'ieee-be'
% scale - scaling for transition from original format to uint8 (for equaly loading images in series)


global REG
if nargin()<7
   scale=[0 0];
end
if nargin()<6
   endian='ieee-le';
end
if nargin()<5
   type='uint8'; % TODO: guess from the file size!
end

if strcmp(type, 'uint8') % 1 if identical
    im=uint8(readi(filePath, imSize, 'uint8', endian));
    scale=[0 1];
else
    imo=readi(filePath, imSize, type, endian);
    REG.img(REGIdx).data_orig=single(imo);
    if scale(2)>0,
        [im,scale]=im2uint8_(imo,scale);
    else
        [im,scale]=im2uint8_(imo);
    end
end

[pathstr,fname,ext] = fileparts(filePath);
REG.img(REGIdx).name=fname;
REG.img(REGIdx).path=filePath;
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
