function scale = LoadNifti ( REGIdx, niifile, scale)
% a funtion for loading images in Nifti format
% function calling example: 
%    LoadNifti(1,'image.nii.gz')
%The image gets loaded into the global REG structure.
%
% uses Matlab Image processing toolbox - Nifty read and info commands (niftiread, niftiinfo)

if nargin<3
    scale=[];
end

%--------------------------------------------------------
global REG
data_orig=niftiread(niifile);
info = niftiinfo(niifile);
%--------------------------------------------------------
if strcmp(info.Datatype, 'uint8') % 1 if identical
    REG.img(REGIdx).data=data_orig;
    REG.img(REGIdx).data_orig=[];
    scale=[0 1];
else
    if numel(scale)==2
        [im,scale]=im2uint8_(data_orig,scale);
    else
        [im,scale]=im2uint8_(data_orig);
    end
    REG.img(REGIdx).data=im;
    REG.img(REGIdx).data_orig=single(data_orig);
end

[filepath,name,ext]=fileparts(niifile);
REG.img(REGIdx).name=name;
REG.img(REGIdx).path=filepath;
REG.img(REGIdx).uid='';
REG.img(REGIdx).O = [0 0 0];
REG.img(REGIdx).voxelSize=single(info.PixelDimensions);

% change orientation based on info.Transform.T
[v, dimPermute]=max(abs(info.Transform.T(1:3,1:3)));
dimFlip=sum( info.Transform.T(1:3,1:3)<0 , 2)';
changeOrientation(REGIdx,dimPermute,dimFlip);

REG.img(REGIdx).O = single(REG.img(REGIdx).O -info.Transform.T(4,1:3)); 

REG.img(REGIdx).mask=[];
REG.img(REGIdx).ROI=[];
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
