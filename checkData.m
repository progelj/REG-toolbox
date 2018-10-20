% Author: Peter Rogelj <peter.rogelj@upr.si>

function checkData()
% validates the data in REG structure, converts data to correct data type,
% perform eventual corrections...

disp('CHECKING global REG structure...');
global REG;

warning off;

if ~isfield(REG,'img')
    warning('images are not defined!');
    REG.img(1).name='undefined';
    REG.img(2).name='undefined';
end
if ~isa(REG.img,'struct')
    warning('img must be a structure array of images!');
end
nrImg=length(REG.img);
if nrImg<2
    warning('At least two images must be defined to perform any processing!');
    nrImg=2;
end

%% checking refIdx, movIdx

% refIdx	int_32		1	Reference image index (index of image in the img array to be used as a reference)
if ~isfield(REG,'refIdx')
    REG.refIdx=int32(1);
    disp('Reference image index set to 1!');
end
if ~isa(REG.refIdx,'int32')
    REG.refIdx=int32(REG.refIdx);
    disp('refIdx type set to int32');
end
if length(REG.refIdx)>1 || REG.refIdx>nrImg
    REG.refIdx=int32(1);
    disp('Reference image index set to 1!');
    %REG.refIdx=REG.refIdx(1);
end

% movIdx	int_32		2	Moving image index  (index of image in the img array to be processed)
if ~isfield(REG,'movIdx')
    REG.movIdx=int32(2);
    disp('Moving image index set to 2!');
end
if ~isa(REG.movIdx,'int32')
    REG.movIdx=int32(REG.movIdx);
    disp('movIdx type set to int32');
end
if length(REG.movIdx)>1 || REG.movIdx>nrImg
    REG.movIdx=int32(2);
    disp('Moving image index set to 2!');
    %REG.movIdx=REG.movIdx(1);
end


%%checking images inside the Img[] structure
for nImg=1:nrImg

    % img[i].name	char[]			Image name
    if ~isfield(REG.img(nImg),'name')
        REG.img(nImg).name='undefined';
    end
    if ~isa(REG.img(nImg).name,'char')
        REG.img(nImg).name='undefined';
    end

    % img[i].path	char[]			Data file path
    if ~isfield(REG.img(nImg),'path')
        REG.img(nImg).path='';
    end

    % img[i].uid	char[]			Unique identifier (e.g. Dicom image UID)
    if ~isfield(REG.img(nImg),'uid')
        REG.img(nImg).uid='';
    end

    % img[i].voxelSize	1x3 single	yes		Image voxel size
    if ~isfield(REG.img(nImg),'voxelSize')
        warning('Image %d has undefined voxelSize, setting to [1 1 1] mm!',nImg);
        REG.img(nImg).voxelSize=single([1 1 1]);
    else
        if length(REG.img(nImg).voxelSize)<3
            warning('Image %d voxel size is not defined for all 3 dimensions, setting to 1 mm!',nImg);
        end
        while length(REG.img(nImg).voxelSize)<3
            REG.img(nImg).voxelSize=single([REG.img(nImg).voxelSize,1]);
            %warning('Image %d has undefined dimensions of voxelSize, setting to 1 mm!\n',nImg);
        end
        if ~isa(REG.img(nImg).voxelSize,'single')
            REG.img(nImg).name=single(REG.img(nImg).voxelSize);
            warning('Image %d voxelSize has invalid type - single required!',nImg);
        end
    end

    % img[i].data_<original_ type>	[nx, ny, nz] of arbitrary type			Original image data (other than uint8 type), usually not preserved in order to free memory (can be reloaded knowing path)
    % ---- not officialy checked ---

    % img[i].data	[nx, ny, nz] uint8	yes		Image data in uint8 format dimensions: x,y,z (row, column, plane)
    if ~isfield(REG.img(nImg),'data')
        REG.img(nImg).data=uint8([]);
        warning('Image %d does not have data defined!',nImg);
    else
        if length(REG.img(nImg).data)==0
            warning('Image %d does not have data defined (length=0)!',nImg);
        else
            if ndims(REG.img(nImg).data)<3
                warning('Image %d data does not have at least 3 dimensions!',nImg);
            end
            if ~isa(REG.img(nImg).data,'uint8')
                warning('Image %d data has invalid type - uint8 required!',nImg); % error?
            end
        end
    end

    % img[i].mask	[nx, ny, nz] uint8		ones	Image mask, for computations only positions where mask>0 shall be used
    if ~isfield(REG.img(nImg),'mask')
        REG.img(nImg).mask=uint8([]);
    else
        if length(REG.img(nImg).mask)>0;
            if size(REG.img(nImg).mask)~=size(REG.img(nImg).data)
                warning('Image %d mask size does not equal the data size! Clearing!',nImg);
                REG.img(nImg).mask=uint8([]);
            end
            if ~isa(REG.img(nImg).mask,'uint8')
                warning('Image %d mask has invalid type - uint8 required!',nImg);
                REG.img(nImg).mask=uint8(REG.img(nImg).mask);
            end
        end
    end

    % img[i].ROI	1x4 int_32		[1,Nx,1,Ny,1,Nz]	image coordinates of RegionOfInterest [xmn,xmax,ymin,ymax] starting with 1
    if ~isfield(REG.img(nImg),'ROI')
        REG.img(nImg).ROI=int32([]);
    else
        if ~isempty(REG.img(nImg).ROI) && length(REG.img(nImg).ROI)~=6;
            warning('Invalid Image %d ROI size (must be 1x6)! Clearing!',nImg);
                REG.img(nImg).ROI=int32([]);
        else
            if ~isempty(REG.img(nImg).ROI) && ~isa(REG.img(nImg).ROI,'int32')
                warning('Image %d ROI has invalid type - uint32 required!',nImg);
                REG.img(nImg).ROI=int32(REG.img(nImg).ROI);
            end
        end
    end

    % img[i].O	1x3 single		[0,0,0]	image origin, distance from the center of the first voxel to the image origin (undeformed, untransformed)
    if ~isfield(REG.img(nImg),'O')
        warning('Undefined image %d O (origin) - setting to [0,0,0]!',nImg);
        REG.img(nImg).O=single([0 0 0]);
    else
        if length(REG.img(nImg).O)~=3;
            warning('Invalid Image %d O (origin) size (must be 1x3)!',nImg);
            while length(REG.img(nImg).O)<3
                REG.img(nImg).O=single([REG.img(nImg).O, 0]);
            end
        else
            if ~isa(REG.img(nImg).O,'single')
                warning('Image %d O (origin) has invalid type - single required!',nImg);
                REG.img(nImg).O=single(REG.img(nImg).O);
            end
        end
    end

    % img[i].T	4x4 single		Eye(4)	global transformation matrix Xtransf=TXoriginal (column-major order in memory)
    if ~isfield(REG.img(nImg),'T')
        REG.img(nImg).T=single([]);
    else
        if ~isempty(REG.img(nImg).T)
            if sum(size(REG.img(nImg).T)~=[4 4]); % invalid size
                warning('Invalid Image %d T (transformation matrix) size (must be 4x4)! Clearing!',nImg);
                REG.img(nImg).T=single([]);
            else
                if sum(REG.img(nImg).T(4,1:4) ~= [0 0 0 1])
                    warning('Invalid Image %d T (transformation matrix)!',nImg);
                    %REG.img(nImg).T=short([]);
                end
                if ~isa(REG.img(nImg).T,'single')
                    warning('Image %d T (transformation matrix) has invalid type - single required!',nImg);
                    REG.img(nImg).T=single(REG.img(nImg).T);
                end
            end
        end
    end

    % img[i].D	[nx, ny, nz, 3] single		zeros	Deformation field. A displacement in x,y,z direction for each voxel
    if ~isfield(REG.img(nImg),'D')
        REG.img(nImg).D=single([]);
    else
        if ~isempty(REG.img(nImg).D)
            if sum(size(REG.img(nImg).D)~=[size(REG.img(nImg).data), 3]); % invalid size
                warning('Invalid Image %d D (deformation field) size (must be [data size, 3])! Clearing!',nImg);
                REG.img(nImg).D=single([]);
            else
                if ~isa(REG.img(nImg).D,'single')
                    warning('Image %d D (deformation field) has invalid type - single required!',nImg);
                    REG.img(nImg).D=single(REG.img(nImg).D);
                end
            end
        end
    end

    %% fields,rescribing relation with the reference image:
    % in H, P, PSF
    % the first dimension (row nr), correspond to the reference image intensities,
    % the second dimension (column nr) corresponds to the moving image intensities.
    % TODO: CHECK IF IT IS NOT JUST THE OPPOSITE!

    % img[i].H	[256 256] double			joint intensity distribution between Reference and Moving image
    if ~isfield(REG.img(nImg),'H')
        REG.img(nImg).H=double([]);
    else
        if ~isempty(REG.img(nImg).H)
            if sum(size(REG.img(nImg).H)~=[256 256]); % invalid size
                warning('Invalid Image %d H (joint histogram) size (expecting [256,256])! Clearing!',nImg);
                REG.img(nImg).H=double([]);
            else
                if ~isa(REG.img(nImg).H,'double')
                    warning('Image %d H (deformation field) has invalid type - double required!',nImg);
                    REG.img(nImg).H=double(REG.img(nImg).H);
                end
            end
        end
    end

    % img[i].P	[256 256] double			estimated joint intensity distribution
    if ~isfield(REG.img(nImg),'P')
        REG.img(nImg).P=double([]);
    else
        if ~isempty(REG.img(nImg).P)
            if sum(size(REG.img(nImg).P)~=[256 256]); % invalid size
                warning('Invalid Image %d P (intensity probability density funcion) size (expecting [256,256])! Clearing!',nImg);
                REG.img(nImg).P=double([]);
            else
                if ~isa(REG.img(nImg).P,'double')
                    warning('Image %d P (intensity probability density funcion) has invalid type - double required!',nImg);
                    REG.img(nImg).P=double(REG.img(nImg).P);
                end
            end
        end
    end

    % img[i].PSF	[256 256] double			point similarity function
    if isfield(REG.img(nImg),'PSF')
        if ~isempty(REG.img(nImg).PSF)
            if sum(size(REG.img(nImg).PSF)~=[256 256]); % invalid size
                warning('Invalid Image %d PSF (point similarity funcion) size (expecting [256,256])! Clearing!',nImg);
                REG.img(nImg).PSF=double([]);
            else
                if ~isa(REG.img(nImg).PSF,'double')
                    warning('Image %d PSF (point similarity funcion) has invalid type - double required!',nImg);
                    REG.img(nImg).PSF=double(REG.img(nImg).PSF);
                end
            end
        end
    end

    % img[i].sim	double			last result of measuring similarity between the moving and reference images
%     if isfield(REG.img(nImg),'sim')
%         if ~isempty(REG.img(nImg).PSF)
%            if  length(REG.img(nImg).sim) ~=1
%                warning('Image %d sim (similarity) is not a scalar!',nImg);
%            end
%            if ~isa(REG.img(nImg).sim,'double')
%                 warning('Image %d sim (similarity) has invalid type - double required!',nImg);
%                 REG.img(nImg).sim=double(REG.img(nImg).sim);
%            end
%         end
%     end

    % img[i].simWeight	double			number of voxels involved in last similarity estimation
    % -- informative value - nothing to check


end

warning on;

return;



%
