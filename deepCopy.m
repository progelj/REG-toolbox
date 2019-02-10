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

% force a deep copy of a matrix! 


% Author: Peter Rogelj <peter@pipi-XPS>
% Created: 2019-02-07

function [xOut] = deepCopy (xIn)
    xOut=xIn;
    xOut(1)=xOut(1); % this forces a deep copy
end
