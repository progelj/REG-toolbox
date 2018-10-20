% Author: Peter Rogelj <peter.rogelj@upr.si>

function [ reg2 , reduction_vector ] = decimate_reg( reg , method )
%DECIMATE_REG
% imdecimate decreases image resolution in dimensions where sampling rate
% is higher than one half of the maximal sampling rate.
% Maximal sampling rate is defined according to all images in all three directions.
%
%   Detailed explanation goes here
% Input :
%   - ROI structure to be decimated
%   - method { linlin, medianlin ], default linlin
% Output:
%   - decimated ROI structure,
%   - optional boolean vector of decimated directions Nx3, where N is number of images.

% prepare the reduction vector
nImg=length(reg.img);
reduct=false(nImg, 3);

%define the method:
if nargin < 2,
    method = 'linlin';
end

% search for the highest sampling rate:
minVoxDim=min(reg.img(1).voxelSize);
for i=2:nImg,
    minlevelVS=min(reg.img(i).voxelSize);
    minVoxDim=min(minVoxDim, minlevelVS);
end;

% define decimation for dimensions with voxelSize < 2*minVoxDim (save to
% 'reduct')
for i=1:nImg,
    reduct(i,:) = reg.img(i).voxelSize < 2*minVoxDim;
end

% define filters:
switch method
    case 'linlin'
        imageFilt= @(x,dimensions)linearfilter(x,dimensions,[1 2 1]);
        deformationFilter= @(x,dimensions)linearfilter(x,dimensions,[1 2 1]);
    case 'medianlin'
        imageFilt= @(x,dimensions)medianfilter(x,dimensions);
        deformationFilter= @(x,dimensions)linearfilter(x,dimensions,[1 2 1]);
    otherwise
        warning('Unexpected method. Using default (linlin).')
        imageFilt= @(x,dimensions)linearfilter(x,dimensions,[1 2 1]);
        deformationFilter= @(x,dimensions)linearfilter(x,dimensions,[1 2 1]);
end

%initial vaulues, the base for modifications:
reg2=reg;

% modify reg: go through all images, masks, ROIs and deformation fields to convert them
for i=1:nImg,
    % define decimation for dimensions with voxelSize < 2*minVoxDim (save to 'reduct')
    dimensions = reg.img(i).voxelSize < 2*minVoxDim;
    reduct(i,:) = dimensions;

    % voxelSize;
    reg2.img(i).voxelSize = reg.img(i).voxelSize .*  ([1 1 1] + dimensions);

    % data;
    reg2.img(i).data = imageFilt( reg.img(i).data, dimensions);
    reg2.img(i).data = subsample( reg2.img(i).data, dimensions);

    % mask;
    if isfield(reg.img(i),'mask')
        if length(reg.img(i).mask)>0,  %length(reg.img(i).data)==
            reg2.img(i).mask = uint8( linearfilter( reg.img(i).mask, dimensions, [1 2 1])>0 );
            reg2.img(i).mask = subsample( reg2.img(i).mask, dimensions);
            disp('mask subsampled');
        end
    end

    % ROI;
    if isfield(reg.img(i),'ROI'),
       if length(reg.img(i).ROI)==6,
           scale=dimensions+1;
           reg2.img(i).ROI=int32([ ...
               floor(reg.img(i).ROI(1) / scale(1) ) ...
               ceil(reg.img(i).ROI(2) / scale(1) ) ...
               floor(reg.img(i).ROI(3) / scale(2) ) ...
               ceil(reg.img(i).ROI(4) / scale(2) ) ...
               floor(reg.img(i).ROI(5) / scale(3) ) ...
               ceil(reg.img(i).ROI(6) / scale(3) ) ]);
       end
    end

    % D;
    if isfield(reg.img(i),'D'),
        if length(reg.img(i).D)==3*length(reg.img(i).data),
            % split into x,y,z components and process independently
            Dx=reg.img(i).D(:,:,:,1);
            Dy=reg.img(i).D(:,:,:,2);
            Dz=reg.img(i).D(:,:,:,3);
            Dx=deformationFilter(Dx, dimensions);
            Dy=deformationFilter(Dy, dimensions);
            Dz=deformationFilter(Dz, dimensions);
            Dx=subsample( Dx, dimensions);
            Dy=subsample( Dy, dimensions);
            Dz=subsample( Dz, dimensions);
            reg2.img(i).D = zeros ([size(Dx) , 3]);
            reg2.img(i).D(:,:,:,2) = Dx;
            reg2.img(i).D(:,:,:,2) = Dy;
            reg2.img(i).D(:,:,:,3) = Dz;
            % previos ERROR version
            %reg2.img(i).D=deformationFilter(reg.img(i).D, dimensions);
            %reg2.img(i).D = subsample( reg2.img(i).D, dimensions);
        end
    end


end % end of for i=1:nImg


if nargout > 1
    reduction_vector=reduct;
end


end
