function [ e1 e0 ] = evaluateResults(D,voxSize, xyzRef, xyzMov)
%evaluate displacement field based on segmented feature points:
% D - displacement field
% voxSize - voxel size [sx,sy,sz]
% xyzRef - image coordinates of feature points on the reference image
% xyzMov - image coordinates of feature points on the moving image
%returns:
% e1 - error considering D
% e0 - initial error

xyzi=xyzRef;
xyze=xyzMov;
    
PosRef=xyzi.*voxSize;
PosMov=xyze.*voxSize;
% initial displacement
d_unreg=PosRef-PosMov;
dd_unreg=sqrt ( d_unreg(:,1).^2 + d_unreg(:,2).^2 + d_unreg(:,3).^2 );
err_unreg_mean=mean(dd_unreg);
err_unreg_max =max (dd_unreg);
err_unreg_std =std (dd_unreg);
printf("initial err: %f (max) %f (mean) %f (std)\n", err_unreg_max, err_unreg_mean, err_unreg_std);

% result -remaining displacements
Dx=D(:,:,:,1);
Dy=D(:,:,:,2);
Dz=D(:,:,:,3);
linearInd = sub2ind(size(Dx), xyze(:,1), xyze(:,2), xyze(:,3));
PosReg = PosMov + [ Dx(linearInd), Dy(linearInd), Dz(linearInd) ];
d_reg=PosRef-PosReg;
dd_reg=sqrt ( d_reg(:,1).^2 + d_reg(:,2).^2 + d_reg(:,3).^2 );
err_reg_mean=mean(dd_reg);
err_reg_max =max (dd_reg);
err_reg_std =std (dd_reg);
printf("final err: %f (max) %f (mean) %f (std)\n", err_reg_max, err_reg_mean, err_reg_std);

e0=[err_unreg_max, err_unreg_mean, err_unreg_std]; %max, mean, std
e1=[err_reg_max, err_reg_mean, err_reg_std]; %max, mean, std
