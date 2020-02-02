function xyzs=exportPoints(REG)
% input is a REG structure with points defined for all images, 
% in a REG.img(n).segPtPx field (e.g. using manulaSegmentPoints)
% output is a xyzs array:
% 1st dimension - image number
% 2dn dimension - coordinate (x,y,z)
% 3rd dimension - point nr. - multiple points for each image
% Undefined values are set to NaN.

if ~isfield(REG.img,'segPtPx')
    xyzs=[];
end
nrImgs=length(REG.img);
nrPoints=0;
for i=1:nrImgs % image number
    nrPoint=max( nrPoints, size(REG.img(i).segPtPx,1) );
end

xyzs=NaN(nrImgs,3,nrPoints);

for i=1:nrImgs % image number
    voxSize=REG.img(i).voxelSize;
    for n=1:size(REG.img(i).segPtPx,1);
        xyzs(i,:,n)=REG.img(i).segPtPx(n,:) .* voxSize;
    end
end

xyzs(xyzs==0)=NaN;
