function saveMhd(REG, imindex, filename)
% save untransformed and undeformed image

element_types=struct('double','MET_DOUBLE','int8','MET_CHAR','uint8','MET_UCHAR','int16','MET_SHORT','uint16','MET_USHORT','int32','MET_INT','uint32','MET_UINT');

[dir, name, ext] = fileparts ([ filename '.img' ]);
warning('off')
mkdir(dir);
warning('on')

% raw data
datatype='uint8'; % default 
if numel(REG.img(imindex).data_orig)>0  % use data_orig field
    fhandle = fopen([ filename '.img' ],'w','ieee-le');
    datatype=class(REG.img(imindex).data_orig);
    fwrite(fhandle,REG.img(imindex).data_orig,datatype);
    fclose(fhandle);
else %use data field
    fhandle = fopen([ filename '.img' ],'w','ieee-le');
    datatype=class(REG.img(imindex).data);
    fwrite(fhandle,REG.img(imindex).data,datatype);
    fclose(fhandle);
end
    
% header
fhandle = fopen([ filename '.mhd' ],'w');
fprintf(fhandle,'ObjectType = Image\nNDims = 3\nBinaryDataByteOrderMSB = False\nBinaryData = True\nCompressedData = False\n');
fprintf(fhandle,'ElementSpacing = %f %f %f\n', REG.img(imindex).voxelSize);
fprintf(fhandle,'DimSize = %d %d %d\n', size(REG.img(imindex).data));
fprintf(fhandle,'Origin = %f %f %f\n', REG.img(imindex).O);
fprintf(fhandle,'ElementNumberOfChannels = 1\n');
fprintf(fhandle,'ElementType = %s\n', element_types.(datatype) );
fprintf(fhandle,'ElementDataFile = %s\n', [ name ext ]);
fclose(fhandle);
