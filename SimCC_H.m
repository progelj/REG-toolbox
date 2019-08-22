% Author: Peter Rogelj <peter.rogelj@upr.si>

function [ CC ] = SimCC_H( h )
%SIMCC SimCC_H computes Correlation Coefficient from joint histogram H.
%   therefoere assuming linear interimage intensity dependence.
%   The method is equivalent to matlab's corr2, just working on histograms:
%   https://ch.mathworks.com/help/images/ref/corr2.html
%   For nonlinear dependence see simCR - correlation ratio measure!
% Input:
%   h - joint intensity distribution between Reference (A) and Moving image (B) (ref=dim1=row, moving=dim2=column)

hA = sum(h,2);
hB = sum(h,1);
if (sum(hA)==0) || (sum(hB)==0)
    CC=-1e10; % a very lange NEGATIVE number
    return;
end
avgA= sum( (1:size(h,1))' .* hA ) / sum(hA);
avgB= sum( (1:size(h,2)) .* hB ) / sum(hB);
%----------
%(dA=A-avgA)
dA= repmat( (1:size(h,1))'-avgA  ,[1,size(h,2)]);
dB= repmat( (1:size(h,2)) -avgB  ,[size(h,1),1]);
% sum N (A-avgA)*(B-avgB)
NAB = h.*dA.*dB;
sumNAB = sum(NAB(:));
% sum N (A-avgA).^2;
NAA =  hA .* ((1:size(h,1))'-avgA).^2;
sumNAA = sum(NAA);
% sum N (B-avgB).^2;
NBB =  hB .* ((1:size(h,2))-avgB).^2;
sumNBB = sum(NBB);
% correlation coefficient
CC = sumNAB / sqrt(sumNAA * sumNBB);

end
