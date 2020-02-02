function showGridSlice( dx, dy, dz, voxelSize, origin);
% shows a displacement grid of one image slice
% parameters: dx,dy,dz - x,y,z components of displacements - one slice only!

if (nargin < 3)
    dz=zeros(isize);
end
if (nargin < 4)
    voxelSize=[1 1 1];
end
if (nargin < 5)
    origin=[0 0 0];
end

isize=size(dx);
if isize~=size(dy)
    error("Grid size x and y do not match!");
end

gx=(0:isize(1)-1)*voxelSize(1)-origin(1);
gy=(0:isize(2)-1)*voxelSize(2)-origin(2);
[yi,xi]=meshgrid(gy,gx);
xi = xi+dx;
yi = yi+dy;

mesh( xi(:,:,1) ,yi(:,:,1), dz(:,:,1) ); colorbar;
view([0 0 1]); xlabel('x');ylabel('y');zlabel('z');axis equal; 