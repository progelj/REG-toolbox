% Author: Peter Rogelj <peter.rogelj@upr.si>

function [ e , dxyzs ] = evaluateREG( myREG, xyzs )
%EVALUATEREG evaluates registration field REG accordind to a reference
%point definition xyzs that provides xyz coordinates of a reference point
%for all images
%   REG is a valid registration structure
%   xyzs - a matrix of n rows of [x,y,z] coorinates of the reference point
%   where n is number of images.
% result is standard deviation of position prior to registration (row1) and
% after registration (line2)
%
% load('kindney15L_sxzs_04-Jan-2018_737064.5321_nan.mat')


REG = myREG;
n=length(REG.img);
%% check if all Tranformations (T) are defined
for i=1:n
    if isempty(REG.img(i).T)
        REG.img(i).T=single(eye(4));
    end
end

%% check the size of xyzs
if size(xyzs) ~= [n 3]
    error('invalid size of xyzs array');
end

% trnsform reference points according to T provided in REG
dxyzs=[];
for i=1:n
    X=[ (xyzs(i,:) - REG.img(i).O)' ; 1 ];
    X2= REG.img(i).T * X;
    dxyzs=[dxyzs; X2(1:3)'];
end

% compute standard deviation of points in dyxzs
%figure(11);plot(dxyzs(:,1));
%figure(12);plot(dxyzs(:,2));
%figure(13);plot(dxyzs(:,3));

e=[ nanstd(xyzs) ; nanstd(dxyzs) ];

%ae = [ hypot(e(1,1),e(1,2)), hypot(e(2,1),e(2,2)) ]
