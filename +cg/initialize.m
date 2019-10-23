function cgstruct = initialize( imageSize, step, margin, kernelType )
    cgstruct=struct();
    
    % kernel type
    if nargin<4
        kernelType=3;
    end
    if any(kernelType==[1, 2 ,3])
        cgstruct.kernelType=kernelType;
    else
        warning('Invalid kernel type: setting to default 3rd order b-spline (3)!');
        cgstruct.kernelType=3; %default
    end
       
    % step
    if length(step)~=3
        error('Invalid argument Step: must be a vector of 3 elements!');
    end
    cgstruct.step=abs(int32(step));
    % margin
    if nargin<3
        margin=[];
    end
    if length(margin)~=3
	    %redefine margin such that it will be optimal for the given kernelType
	    switch cgstruct.kernelType
	        case 1
	            cgstruct.margin = int32(step/2);
	        case 2
                cgstruct.margin = int32(1.5*step/2);
          case 3
                cgstruct.margin = int32(2*step/2);
	     end
	  else 
        cgstruct.margin=int32(margin);
    end
    % grid
	  cgstruct.grid=single(zeros( [ int32(1+floor( single(int32(imageSize)+2*cgstruct.margin-1)./single(cgstruct.step) )) ,3] ));

	  %kernels: kernelx, kernely, kernelz, kernel3D
    switch cgstruct.kernelType
	    case { 1 , 2 , 3 } % b-spline order 1 , 2, or 3
	        cgstruct.kernelx=cg.bSplineKernel(cgstruct.step(1),cgstruct.kernelType);
	        cgstruct.kernely=cg.bSplineKernel(cgstruct.step(2),cgstruct.kernelType);
	        cgstruct.kernelz=cg.bSplineKernel(cgstruct.step(3),cgstruct.kernelType);
          cgstruct.kernel3D=cgstruct.kernelx'.*cgstruct.kernely.*permute(cgstruct.kernelz,[3 1 2]); %' kernelXYZ...
	    %case 4 
      otherwise
          error('selected kernel type is not implemented, yet!');
    end         

end
