% Author: Peter Rogelj <peter.rogelj@upr.si>

function [ T ] = rigidT( parameters )
%RIGIDT rigidT computes the rigid transformation matrix T from translation and rotation parameters
% parameters: [tx, ty, tz, rx, ry, rz]
% tx, ty, tz: translations in mm (x, y, z)
% rx, ry, rz: rotations in DEGREES

    % if using less then 6 parameters others are considered to be 0
    if length(parameters)<6
        parameters(6)=0;
    end

    t=parameters(1:3);
    r=parameters(4:6)*pi/180; %[(15*pi)/180 (20*pi)/180 (25*pi)/180];

    T=single([cos(r(2))*cos(r(3)), cos(r(3))*sin(r(1))*sin(r(2))-cos(r(1))*sin(r(3)), cos(r(1))*cos(r(3))*sin(r(2))+sin(r(1))*sin(r(3)) t(1);
       cos(r(2))*sin(r(3)), cos(r(1))*cos(r(3))+sin(r(1))*sin(r(2))*sin(r(3)), -cos(r(3))*sin(r(1))+cos(r(1))*sin(r(2))*sin(r(3)) t(2);
       -sin(r(2)), cos(r(2))*sin(r(1)), cos(r(1))*cos(r(2)), t(3);
       0 0 0 1]);

end
