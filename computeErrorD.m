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
%
% Computation om amx and RMS error for displacement fields using Euclidean distance
% [errRMS, errMax] = computeErrorD (D1, D2)
% input: two displacement fields (D)
% output errRMS and errMax
%
% Author: Peter Rogelj <peter.rogelj@upr.si>
% Created: 2019-02-01

function [errRMS, errMax] = computeErrorD (D1, D2)
    global REG;
    error=D1-D2;  % REG.img(idx1).D-REG.img(idx2).D;
    error3=sqrt(error(:,:,:,1).^2 + error(:,:,:,2).^2 + error(:,:,:,3).^2);
    errMax=max(error3(:));
    errRMS=rms(error3(:));
end
