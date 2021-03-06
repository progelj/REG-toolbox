function SegPtPx=exportPoints(REG)
% input is a REG structure with points defined for all images, 
% in a REG.img(n).segPtPx field (e.g. using manulaSegmentPoints)
% output is a xyzs array:
% 1st dimension - point nr. - multiple points for each image
% 2dn dimension - image coordinates of a point (nx,ny,nz)
% 3rd dimension - image Nr. (ref, mov or a sequence ...)
% Undefined values are set to NaN.
% All values represent point coordinates in the image coordinate system
% with 0 being in a center of the first (corner) voxel.

if ~isfield(REG.img,'segPtPx')
    SegPtPx=[];
end
nrImgs=length(REG.img);
nrPoints=0;
for i=1:nrImgs % image number
    nrPoint=max( nrPoints, size(REG.img(i).segPtPx,1) );
end

SegPtPx=NaN(nrPoints,3,nrImgs);

for i=1:nrImgs % image number
    SegPtPx(1:size(REG.img(i).segPtPx,1),:,i)=REG.img(i).segPtPx;
end

%SegPtPx(SegPtPx==0)=NaN; % just to prevent errors in the case of segmentation failures ??
