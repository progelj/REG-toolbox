function REG = dicom2reg( dirPath )
%% read all dicom files in a folder and store as a REG.
% if no LHS parameters it stores the REG into MAT file
% DOES NOT WORK IN OCTAVE - MATLAB ONLY!!!

%D = '/home/peter/Downloads/PROSJEKTER^Nyrefunksjon/PROSJEKTER^Nyrefunksjon20131022/fl3d_dyn_flip20_192_23s1520131022180304830000/';
S = dir(dirPath); % list all files.
% remove folders:
k=1;
while k <= numel(S)
    if S(k).isdir
        S(k)=[];
    else
        k=k+1;
    end
end

infos={};
voxelSizes=[];
for k = 1:numel(S)
    F = fullfile(dirPath,S(k).name);
    dinfo = dicominfo(F);
    infos(k,1) = {dinfo.StudyTime};  %{'-'};
    infos(k,2) = {dinfo.AcquisitionTime};
    infos(k,3) = {dinfo.SliceLocation};
    infos(k,4) = {dinfo.LargestPixelValueInSeries};
    infos(k,5) = {F};
    voxelSizes(k,:) = single([dinfo.PixelSpacing' dinfo.SliceThickness]);
    
end
[Sinfos, index]=sortrows(infos);
voxelSizes=voxelSizes(index,:);

REG = [];
imNr=0;
previous=''; %% the first three elements should change for a new image
for k = 1:size(Sinfos,1)
    newValue=char(Sinfos(k,2));
    if ~isequal(previous, newValue)
        imNr=imNr+1;
        REG.img(imNr).path=char(Sinfos(k,5));
        REG.img(imNr).data_orig=[];
        %fprintf("new image: %d, k=%d, %s\n",imNr, k, newValue);
    end 
    previous=newValue;
    
    %read the current file into (one) slice of data_orig
    REG.img(imNr).data_orig(:,:,end+1)=dicomread(char(Sinfos(k,5)));
    REG.img(imNr).LargestPixelValueInSeries = cell2mat(Sinfos(k,4));
    REG.img(imNr).voxelSize=single(voxelSizes(k,:)); % should be always the same    
    
end
    

%convert to 8 bit and define origin!
for imNr = 1:length(REG.img)
    scale = ceil( REG.img(imNr).LargestPixelValueInSeries / 255 );
    REG.img(imNr).data = uint8( REG.img(imNr).data_orig./double(scale));
    REG.img(imNr).O = size(REG.img(imNr).data) .* REG.img(imNr).voxelSize; %origin in the image center
end
checkData(REG);

if nargout<1
    lastFolderName=regexp(dirPath,filesep,'split');
    if length(lastFolderName(end))<=3
        seriesName=lastFolderName(end-1);
    else 
        seriesName=lastFolderName(end);
    end
    save(char([seriesName ".mat"]), "REG");
end

return;
