function [JF] = Jacobians( D , VoxSize );

if nargin <2 
    VoxSize=[1 1 1];
end
    
if size(D,4) ~= 3
    error ("invalid 3D deformtion field size -the size in the fourth dimension must be 3");
end


sD=size(D);
Js = zeros( sD(1), sD(2), sD(3), 9 );
%JF = zeros( sD(1), sD(2), sD(3) );

[Js(:,:,:,1),Js(:,:,:,2),Js(:,:,:,3)] = gradient( D(:,:,:,1) );
[Js(:,:,:,4),Js(:,:,:,5),Js(:,:,:,6)] = gradient( D(:,:,:,2) ); 
[Js(:,:,:,7),Js(:,:,:,8),Js(:,:,:,9)] = gradient( D(:,:,:,3) );  

Js=mat2cell(Js, ones(1,sD(1)) ,ones(1,sD(2)), ones(1,sD(3)), 9);
Js=cellfun(@(x)reshape(x,[3 3]),Js,"UniformOutput",false);
scale=[VoxSize(1) VoxSize(1) VoxSize(1);VoxSize(2),VoxSize(2),VoxSize(2);VoxSize(3),VoxSize(3),VoxSize(3)]';
Js=cellfun( @(x)(x./scale+eye(3)),Js,"UniformOutput",false);
JF=cellfun(@det,Js);
%JF=cellfun( @(x)det(x.*scale+eye(3)),Js); % slower!


%% ==== previous - slower implementation ========================
%[DXX,DXY,DXZ] = gradient( D(:,:,:,1) );
%[DYX,DYY,DYZ] = gradient( D(:,:,:,2) ); 
%[DZX,DZY,DZZ] = gradient( D(:,:,:,3) );   

%sD=size(D);
%JF = zeros( sD(1), sD(2), sD(3) );


%for k=1:sD(3)
%    for j=1:sD(2)
%        for i=1:sD(1)
%            J=[ DXX(i,j,k)./VoxSize(1)+1,  DXY(i,j,k)./VoxSize(1),  DXZ(i,j,k)./VoxSize(1);
%                DYX(i,j,k)./VoxSize(2),  DYY(i,j,k)./VoxSize(2)+1,  DYZ(i,j,k)./VoxSize(2);
%                DZX(i,j,k)./VoxSize(3),  DZY(i,j,k)./VoxSize(3),  DZZ(i,j,k)./VoxSize(3)+1  ];
%            JF(i,j,k)=det(J);
%        end
%    end
%end