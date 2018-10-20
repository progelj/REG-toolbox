% Author: Peter Rogelj <peter.rogelj@upr.si>

function LoadDicomVolume( REGIdx, DirName)
%function [ Im , Info ] = LoadDicomVolume( dir )
%  the function opens a medical image stored in Dicom format.
%  All the files that belong to the image must be stored in the same
%  folder, provided by parameter 'DirName'.
%
%  example  LoadDicomVolume( REGIdx , '..\Data1\' )
%       !!! nnote the '\' at the end of the directory name !!!
%  REGIdx is an index (position) of an image in a global REG structure
%
%  internal variables:
%  Im - field with image data;
%  VoxSize - voxel size
%  T - transformation matrix to transform image coordinates from image
%      coordinates to reference coordinates: [Xr ; 1] = T * [ Xs.*VoxSize; 1]
%  files - structure with all the info about image files, sorted by frame Z
%      coordinate (slice location)
%

% oldState = intwarning('off');

files = dir(DirName);
nFiles=size(files,1);
fileOrder=nan(1,nFiles)' ; % z-coord

for i=1:nFiles,
    if files(i).isdir==1,
        continue
    end
    files(i).fname=[ DirName filesep files(i).name];
    try
        files(i).info = dicominfo(files(i).fname);
    catch
        continue;
    end
    %if strcmp(files(i).info.ColorType,'grayscale') == 0,
    if isfield(files(i).info, 'PhotometricInterpretation');
        if strcmp(files(i).info.PhotometricInterpretation,'MONOCHROME2') == 0,
            files(i).isImage=0;
            continue
        end
    else
        continue
    end
    if isfield(files(i).info, 'SliceLocation');
        fileOrder(i)= files(i).info.SliceLocation;   % z koordinata
    else
        fileOrder(i)= nan;
    end
    files(i).seriesinstance=files(i).info.SeriesInstanceUID;  % M
end



% add SeriesIstance
SeriesInstance.UID = files(1).seriesinstance
for i=2:nFiles
    flag = false;
    temp = 0;
    tempSeries = size(SeriesInstance,2);
    for j = 1:tempSeries
        %if ~strcmp(string(files(i).seriesinstance), string(SeriesInstance(j).UID))
        if ~strcmp(files(i).seriesinstance, SeriesInstance(j).UID)
            flag = true;
            temp = temp + 1;
        end
    end
    if flag & (temp == tempSeries)
        SeriesInstance(size(SeriesInstance,2)+1).UID= files(i).seriesinstance;
    end
end
% check if it is only one series

k = 1;
for i = 1:size(SeriesInstance,2)
    if (~isempty(SeriesInstance(i).UID))
        SeriesInstance1(k).UID = SeriesInstance(i).UID;
        k = k + 1;
    end
end
SeriesInstance = SeriesInstance1;
clear SeriesInstance1 k


if (size(SeriesInstance,2)>1)
    choice = LoadSeriesInstance(SeriesInstance);
else
    choice = SeriesInstance(1).UID;
end


% order files according to z coordinate
[zCoord,IX] = sort(fileOrder);
%files2=files;
k = 0;

for j = 1:nFiles
    if ~isnan(zCoord(j));
         if strcmp(files(IX(j)).seriesinstance, choice)
             k = k+1;
            files2(k) = files(IX(j));
         end
    end
end

if ~exist('files2','var'),
    Im = [];
    VoxSize = [1 1 1];
    T = eye(4);
    return
end
files=files2;
nFiles=length(files);


% define coordinate system
orientation=files(1).info.ImageOrientationPatient;
orientation3=cross(orientation(1:3),orientation(4:6));
position=files(1).info.ImagePositionPatient;
T=[orientation(1), orientation(4), orientation3(1), position(1);
   orientation(2), orientation(5), orientation3(2), position(2);
   orientation(3), orientation(6), orientation3(3), position(3);
   0 0 0 1];


%konstruiranje slike  ( also checking for missing files)
VoxSize=[ files(1).info.PixelSpacing ; files(2).info.SliceLocation-files(1).info.SliceLocation ];
Im=dicomread(files(1).info.Filename);
for j = 2:nFiles,
    Im(:,:,j)=dicomread(files(j).info.Filename);
    if round((files(j).info.SliceLocation-files(1).info.SliceLocation)/VoxSize(3))~=(j-1)
        warning('missing frames detected!?')
    end
    %disp(j)
    %posi=T*[0;0;(j-1)*VoxSize(3);1]
    %position=files(j).info.ImagePositionPatient
end

%% storing results in a global REG structure
global REG
REG.img(REGIdx).name='DICOM';
REG.img(REGIdx).path=DirName;
REG.img(REGIdx).uid=SeriesInstance(1).UID;
REG.img(REGIdx).voxelSize=single(VoxSize);
REG.img(REGIdx).data_orig=single(Im);
REG.img(REGIdx).data=im2uint8( Im ); % conversion to uint8 required
REG.img(REGIdx).mask=[];
REG.img(REGIdx).ROI=[];
REG.img(REGIdx).O=single([0,0,0]);
REG.img(REGIdx).T=single(T);
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


% izpis fajlov
% for j = 1:nFiles
%     disp(files(j).fname)
%     disp(zCoord(j))
% end
% intwarning(oldState);
