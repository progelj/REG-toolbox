% Author: Peter Rogelj <peter.rogelj@upr.si>

function [ E ] = evaluateREG( myREG, SegPtPx )
%EVALUATEREG evaluates registration field REG accordind to a reference
%point definition xyzs that provides xyz coordinates of a reference point
%for all images of a 4D image sequence
% Inputs:
%   REG is a valid registration structure
%   SegPtPx - a matrix of size [n,3,p] where n is number of points, 
%             p is number of images and 
%             values  are image coordinates with 0 in the center of the first voxel
%
% Outputs: - all representing standard deviation of point positions
%  ..0     - error before registration
%  ..1     - error after registration
% std..    - standard devition of point positions (when registering multiple images together, time sequence)
% std..pts - standard deviation for each point
% err..    - error (deviation ofpoint position - mean abs value)
% err..pts - errors for all points
% max..    - maximal error  

REG = myREG;
nImg=length(REG.img);
%% check if all Tranformations (T) are defined
for nim=1:nImg
    if isempty(REG.img(nim).T)
        REG.img(nim).T=single(eye(4));
    end
end

%% check the size of xyzs
if size(SegPtPx,3)~=nImg || size(SegPtPx,2)~=3
    error('invalid size of the xyzs array');
end

% trnsform reference points according to T provided in REG
nrPt=size(SegPtPx,1);
xyzs0=nan(size(SegPtPx,1),4,size(SegPtPx,3));
xyzs1=xyzs0;
for npt=1:nrPt  % point Nr.
    for nim=1:nImg %image Nr.
        X0 =  [ (SegPtPx(npt,:,nim).*REG.img(nim).voxelSize - REG.img(nim).O)' ; 1 ];
        xyzs0(npt,:,nim)= X0'; % 4 element coord (x,y,z,1)
        X1 =  REG.img(nim).T * X0;
        xyzs1(npt,:,nim)= X1'; % 4 element coord (x,y,z,1)
        
        %if isfield(REG.img(i),"D") 
        if numel(REG.img(nim).D)>0
            % interpolate D for the given image coordinates
            % add D(points) to point coordinates xyzs;
            D = [0 0 0 0];
            D(1) = interp3(REG.img(nim).D(:,:,:,1) ,SegPtPx(npt,1,nim)+1, SegPtPx(npt,2,nim)+1, SegPtPx(npt,3,nim)+1);
            D(2) = interp3(REG.img(nim).D(:,:,:,2) ,SegPtPx(npt,1,nim)+1, SegPtPx(npt,2,nim)+1, SegPtPx(npt,3,nim)+1);
            D(3) = interp3(REG.img(nim).D(:,:,:,3) ,SegPtPx(npt,1,nim)+1, SegPtPx(npt,2,nim)+1, SegPtPx(npt,3,nim)+1);
            xyzs1(npt,:,nim)=xyzs1(npt,:,nim)+D;
        end

    end
end

E.xyzs0=xyzs0;
E.xyzs1=xyzs1;
E.std0pts= nanstd(xyzs0,0,3); 
E.std1pts= nanstd(xyzs1,0,3);
E.std0 = mean(E.std0pts,1);
E.std1 = mean(E.std1pts,1);
E.err0pts = diff(xyzs0,1,3);%abs(diff(xyzs0,1,3));
E.err1pts = diff(xyzs1,1,3);%abs(diff(xyzs1,1,3));
E.mean0= mean(abs(E.err0pts),1,'omitnan');
E.mean1= mean(abs(E.err1pts),1,'omitnan');
E.max0 = max(max(E.err0pts,[],3,'omitnan'),[],1,'omitnan');
E.max1 = max(max(E.err1pts,[],3,'omitnan'),[],1,'omitnan');
