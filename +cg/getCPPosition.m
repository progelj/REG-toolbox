% Copyright (C) 2019 Peter Rogelj
% 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

% find position of control point on the image in voxels
% input: REG.img structure, cgIndex
% output: voxel index [ix, iy, iz] 
% cgIndex may be in x,y,z or i format.

% Author: Peter Rogelj <peter.rogelj@upr.si>
% Created: 2019-02-07

function [imageIndex] = getCPPosition (img, cgIndex)
    if min(cgIndex)<1
        error("Invalid control grid index (<1)!");
    end
    % could add test for the upper limit
        %allow sub instead of index:
    if numel(cgIndex)==1
        [ia, ib, ic]=ind2sub(size(img.cg.grid), cgIndex);
        cgIndex=[ia, ib, ic];
    end    
    % computtion:
	margin = img.cg.margin;
    cgstep = img.cg.step;
    imageIndex = -margin+(cgIndex-1).*cgstep;
end

