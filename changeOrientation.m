% Author: Peter Rogelj <peter.rogelj@upr.si>

function changeOrientation( REGIdx, dimPermute, dimFlip )
%ImportImage from variable into REG structure
%Input parameters:
% REGIdx - index of image in the global REG structure
% dimPermute - variable providing the new order of dimensions , default [1 2 3]
% dimFlip - variable telling which dimension to flip, default [0 0 0], according to the original directions.
% transformaions, deformaions, ROIs ARE NOT PRESERVED. 

global REG
if nargin()<3
   dimFlip=[0 0 0];
end

for dim=1:3
    if dimFlip(dim)>0
        REG.img(REGIdx).data = flip( REG.img(REGIdx).data , dim);
        if numel(REG.img(REGIdx).data_orig)>0
            REG.img(REGIdx).data_orig = flip( REG.img(REGIdx).data_orig , dim);
        end

        %fprintf("flip, %d\n",dim);
        if numel(REG.img(REGIdx).mask)>0
            REG.img(REGIdx).mask = flip( REG.img(REGIdx).mask , dim);
        end
        
        REG.img(REGIdx).O(dim)= (size(REG.img(REGIdx).data,dim)-1).*REG.img(REGIdx).voxelSize(dim) - REG.img(REGIdx).O(dim);
        
        if isfield(REG.img(REGIdx),'segPtPx')>0
            if numel(REG.img(REGIdx).segPtPx)>0
                ImSizeDim = size(REG.img(REGIdx).data,dim);
                REG.img(REGIdx).segPtPx(:,dim)=ImSizeDim-1-REG.img(REGIdx).segPtPx(:,dim);
            end   
        end
        
    end
end


REG.img(REGIdx).data =  permute( REG.img(REGIdx).data, dimPermute );
if numel(REG.img(REGIdx).data_orig)>0
    REG.img(REGIdx).data_orig =  permute( REG.img(REGIdx).data_orig, dimPermute );
end
if numel(REG.img(REGIdx).mask)>0
    REG.img(REGIdx).mask=permute( REG.img(REGIdx).mask, dimPermute);
end

if isfield(REG.img(REGIdx),'segPtPx')
    REG.img(REGIdx).segPtPx=REG.img(REGIdx).segPtPx(:,dimPermute);
end

REG.img(REGIdx).voxelSize=REG.img(REGIdx).voxelSize(dimPermute);
REG.img(REGIdx).O=REG.img(REGIdx).O(dimPermute);

%%TODO:
% DONE: REG.img(REGIdx).mask=[];
REG.img(REGIdx).ROI=[];

REG.img(REGIdx).T=[];
REG.img(REGIdx).D=[];
