% Author: Peter Rogelj <peter.rogelj@upr.si>

function [ Im2, scale ] = im2uint8( Im1 , scale)
%IM2UINT8 conversion of image (e.g. 16 bit image) to 256 intensity image in
%uint8 format.
%   Detailed explanation goes here

if nargin()<2 % no scale defined
    m1=double(min(Im1(:)));
    M1=double(max(Im1(:)));
    Im2=255*(double(Im1)-m1)/(M1-m1);
    scale(1)=m1;
    scale(2)=255/(M1-m1);
else
    %scale given
    %--- m1=double(min(Im1(:)));
    Im2=(double(Im1)-scale(1)) * scale(2);
end

%----------- optional additional image enhancements------------------------
%Im2 = imadjust(Im2(:));
%Im2 = histeq(Im2(:),2048);
%--------------------------------------------------------------------------

Im2 = reshape(Im2, size(Im1));

Im2=uint8(Im2);
%figure; imhist(Im2(:));
%figure; imagesc(Im2(:,:,round(size(Im2,3)/2))); colormap gray

end
