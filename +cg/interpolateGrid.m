
function [ interp_grid ] = interpolateGrid( grid, newsize, scaling )
% INTERPOLATE_GRID
%
%   Detailed explanation goes here
% Input :
%   - grid:  initial control grid to be interpolated
%   - size: size of the interpolated grid
% Output:
%   - interpolated control grid

%printf("interpolateGrid to size: %f\n",size); %debug


interp_grid = cat(4, interpolate(grid(:,:,:,1), newsize(1:3)) / scaling(1), ...
                     interpolate(grid(:,:,:,2), newsize(1:3)) / scaling(2), ...
                     interpolate(grid(:,:,:,3), newsize(1:3)) / scaling(3));


end
