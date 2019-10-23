% Author: Peter Rogelj <peter.rogelj@upr.si>

function A=readi(file,size0,format,endian)
%function A=read(file,size,format, endian)

if nargin()==3
   endian='ieee-le'; % else 'ieee-be'
end

if length(size0)==3
   size2=[size0(1) size0(2)*size0(3)];
else
   size2=size0;
end

FID=fopen(file,'r');
A=fread(FID,size2,format,0,endian);
fclose(FID);

A=reshape(A,size0);
