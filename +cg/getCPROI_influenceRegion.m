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

% find REGION influenced by a control point 
% input: REG.img structure, cgIndex [x, y, z] 
% output: 
% ROI image soordinates [xLow, xHigh, yLow, yHigh, zLow, zHigh] .

% Author: Peter Rogelj <peter.rogelj@upr.si>
% Created: 2019-02-07

function [ROI] = getCPROI (img, cgIndex)
    if min(cgIndex)<1
        error("Invalid control grid index (<1)!");
    end
    % could add test for the upper limit
    
    %allow sub instead of index:
    if numel(cgIndex)==1
        [ia, ib, ic, id]=ind2sub(size(img.cg.grid), cgIndex);
        cgIndex=[ia, ib, ic];
    end
    % computtion:
    imsize=size(img.data);
	margin = img.cg.margin;
    cgstep = img.cg.step;
    ind = -margin+(int32(cgIndex)-1).*cgstep+1;

    instep = floor((size(img.cg.kernel3D)-1)/2);
        
    %ROI=int32( [max(ind(1)-cgstep(1),1), min(ind(1)+cgstep(1),imsize(1)), ...
    %            max(ind(2)-cgstep(2),1), min(ind(2)+cgstep(2),imsize(2)), ...
    %            max(ind(3)-cgstep(3),1), min(ind(3)+cgstep(3),imsize(3)) ] );

    ROI=int32( [max(ind(1)-instep(1),1), min(ind(1)+instep(1),imsize(1)), ...
                max(ind(2)-instep(2),1), min(ind(2)+instep(2),imsize(2)), ...
                max(ind(3)-instep(3),1), min(ind(3)+instep(3),imsize(3)) ] );

end

