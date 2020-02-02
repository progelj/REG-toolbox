function LoadMhd ( REGIdx, headerFile )
% a funtion for loading images in MHD format (mhd is a separate header)
% function calling example: 
%    LoadMhd(1,'image.mhd')
%The image gets loaded into the global REG structure.
%
% based on 
% Read Medical Data 3D
%version 1.1.0.0 (54.5 KB) by Dirk-Jan Kroon
% Updated 23 Feb 2011
% https://ch.mathworks.com/matlabcentral/fileexchange/29344-read-medical-data-3d


global REG

[dir, name, ext] = fileparts (headerFile);
% defaults
endian='ieee-le';
voxelSize=[1 1 1];

%read data from header file
fid=fopen(headerFile,'rb');
if(fid<0)
    fprintf('Can not open file %s\n',headerFile);
    return
end
info.Filename=headerFile;
info.Format='MHA';
info.CompressedData='false';
readelementdatafile=false;
while(~readelementdatafile)
    str=fgetl(fid);
    s=find(str=='=',1,'first');
    if(~isempty(s))
        type=str(1:s-1); 
        data=str(s+1:end);
        while(type(end)==' '); type=type(1:end-1); end
        while(data(1)==' '); data=data(2:end); end
    else
        type=''; data=str;
    end
    
    switch(lower(type))
        case 'ndims'
            info.NumberOfDimensions=sscanf(data, '%d')';
        case 'dimsize'
            info.Dimensions=sscanf(data, '%d')';
        case 'elementspacing'
            info.PixelDimensions=sscanf(data, '%lf')';
        case 'elementsize'
            info.ElementSize=sscanf(data, '%lf')';
            if(~isfield(info,'PixelDimensions'))
                info.PixelDimensions=info.ElementSize;
            end
        case 'elementbyteordermsb'
            info.ByteOrder=lower(data);
        case 'anatomicalorientation'
            info.AnatomicalOrientation=data;
        case 'centerofrotation'
            info.CenterOfRotation=sscanf(data, '%lf')';
        case 'offset'
            info.Offset=sscanf(data, '%lf')';
        case 'binarydata'
            info.BinaryData=lower(data);
        case 'compresseddatasize'
            info.CompressedDataSize=sscanf(data, '%d')';
        case 'objecttype',
            info.ObjectType=lower(data);
        case 'transformmatrix'
            info.TransformMatrix=sscanf(data, '%lf')';
        case 'compresseddata';
            info.CompressedData=lower(data);
        case 'binarydatabyteordermsb'
            info.ByteOrder=lower(data);
        case 'elementdatafile'
            info.DataFile=data;
            readelementdatafile=true;
        case 'elementtype'
            info.DataType=lower(data(5:end));
        case 'headersize'
            val=sscanf(data, '%d')';
            if(val(1)>0), info.HeaderSize=val(1); end
        otherwise
            info.(type)=data;
    end
end
switch(info.DataType)
    case 'char', datatype='int8';
    case 'uchar', datatype='uint8';
    case 'short', datatype='int16';
    case 'ushort', datatype='uint16';
    case 'int', datatype='int32';
    case 'uint', datatype='uint32';
    case 'float', datatype='single';
    case 'double', datatype='double';
    otherwise, datatype='uint8';
end
if(~isfield(info,'HeaderSize'))
    info.HeaderSize=ftell(fid);
end
fclose(fid);

if info.NumberOfDimensions~=3
    error("The image is not 3D!");
end

switch(info.ByteOrder(1))
    case 'f'
        endian='ieee-le';
    otherwise
        endian='ieee-be';
end

LoadRawVolume( REGIdx, info.DataFile, info.Dimensions, info.PixelDimensions , datatype, endian );


REG.img(REGIdx).name=name;
REG.img(REGIdx).path=dir;
REG.img(REGIdx).O = info.CenterOfRotation;
%info.TransformMatrix