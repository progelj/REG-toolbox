% Author: Peter Rogelj <peter.rogelj@upr.si>

function [ CR ] = SimCR_H( h )
%SIMCC SimCR_H computes Correlation Ratio from joint histogram H.
%   therefoere NOT assuming linear interimage intensity dependence.
%   see:
%   "The Correlation Ratio as a New Similarity Measure for Multimodal Image Registration",
%   Alexis Roche, Grégoire Malandain, Xavier Pennec, and Nicholas Ayache
%   MICCAI 98
% DIFFERENCE - computation of variance: avg( square(x-xm) )
% Input:
%   h - joint intensity distribution between Reference (A) and Moving image (B) (ref=dim1=row, moving=dim2=column)

hA = sum(h,2);
hB = sum(h,1);
avgA= sum( (1:size(h,1))' .* hA ) / sum(hA);
%avgB= sum( (1:size(h,2)) .* hB ) / sum(hB);
%----------
%(dA=A-avgA)
dA= repmat( (1:size(h,1))'-avgA  ,[1,size(h,2)]);
% vA - total variance
NAA =  hA .* ((1:size(h,1))'-avgA).^2;
shA = sum(hA);
if shA<=0
    CR=0;
    return;
end
vA = sum(NAA) / shA;% sum(hA);

% vAi - variances of A for each given intensity of B
% avgAi - mean values of A for each intensity B
%hAi = h(:,i)
avgAi= sum( (1:size(h,1))' .* h ,1 ) ./ hB;
nAAi = h.* ( repmat( (1:size(h,1))' , [1,size(h,2)] ) -avgAi ).^2;
vAi = sum(nAAi ,1)./ hB;
vAi(isnan(vAi))=0;

% CR
CR = 1 - sum (vAi.* hB) / shA / vA;


end
