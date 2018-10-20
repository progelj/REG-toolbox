% Author: Peter Rogelj <peter.rogelj@upr.si>

function [ par ] = rigidTinv( T )
%RIGIDTINV computes transfomration parameters (Euler angles and
%translations) from rigid transformation matrix.
%   Input: T - 3D rigid transformation matrix
%   Output: par - parameters [ty,ty,tz, rx,ry,rz];
% angles r are given in degrees.
% source: https://www.learnopencv.com/rotation-matrix-to-euler-angles/

R = T(1:3,1:3);
shouldBeIdentity = R*R';
if norm(eye(3)-shouldBeIdentity) > 1e-6
    warning('matrix is not rotational');
end

% translations
tx= T(1,4);
ty= T(2,4);
tz= T(3,4);

%rotations
sy = sqrt( T(1,1).^2 + T(2,1).^2 );

if sy > 1e-6 % NOT SINGULAR
    rx = atan2d( T(3,2) , T(3,3) );
    ry = atan2d( -T(3,1) , sy );
    rz = atan2d( T(2,1), T(1,1) );
else  % SINGULAR
    rx = atan2d( -T(2,3), T(2,2) );
    ry = atan2d( -T(3,1), sy );
    rz = 0;
end

par=[tx,ty,tz,rx,ry,rz];

end
