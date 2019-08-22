function [val, gradient] = criterionFunction2(x, simFunc_H, PSF)
%   Criterion function for optimization of similarity for optimization
%   Input parameters:
%       x - vector of control grid parameters, nuber of elements equal to REG.img(movIdx).cg.grid
%       simFunc_H - a handle to simmilarity computation function Sim=simFunc_H(H12), where H12 is a joint histogram
%   Outouts:
%       val - value of similarity at given control grid parameters x
%       gradient  - gradient vector for each control grid parameter at x
%   Comments:
%       controlgrid cg must be part of REG structure: REG.img(REG.movIdx).cg
%       REG structure must be provided as a global variable
    global REG;
    t0=tic;
    
    % check the input arguments
    sx=size(REG.img(REG.movIdx).cg.grid);
    nx=numel(REG.img(REG.movIdx).cg.grid);
    if numel(x)~=nx
        error("Invalid number of variables passed into criterionFunction!");
    end
    
    if (nargin < 2)
        simFunc_H = @SimMI_H;
    end
    if (nargin >= 3)
        simFunc_H = @(x) psmp( x , PSF );
    end
        
    % compute similarity function value
    REG.img(REG.movIdx).cg.grid = single(reshape(x,sx)); 
    cg.computeDisplacementW(REG.img(REG.movIdx).cg,REG.img(REG.movIdx).D);
    if isfield (REG.img(REG.movIdx),'D0')
        if size( REG.img(REG.movIdx).D0) == size(REG.img(REG.movIdx).D) 
            REG.img(REG.movIdx).D = REG.img(REG.movIdx).D + REG.img(REG.movIdx).D0;
        end
    end 
    
    %h12 = linearIntHist_(REG);
    h12 = pvi(REG);
    val = simFunc_H( h12 );
    
    %================== DEBUG ================================
    global CFsteps % counting steps - number of criterion function estimation
    if length(CFsteps)>0
        CFsteps(end)=CFsteps(end)+1;
    end
    % in order to debug, define a global cell variable cgSteps
    global cgSteps;
    if iscell(cgSteps)
        printf("file: %s \n", mfilename('fullpath'));
        printf("max-x=%f\n",max(abs(REG.img(REG.movIdx).cg.grid(:,:,:,1)(:))) ) ;
        printf("max-y=%f\n",max(abs(REG.img(REG.movIdx).cg.grid(:,:,:,2)(:))) ) ;
        printf("max-z=%f\n",max(abs(REG.img(REG.movIdx).cg.grid(:,:,:,3)(:))) ) ;
        printf("value %f\n",val);
    end
    %=========================================================
    
    
    % compute similarity function gradients
    if (nargout > 1) % compute gradients!!!
        %gradient = single(zeros(nx,1));
        gradient = single(zeros(size(x)));
        pregrid=deepCopy(REG.img(REG.movIdx).cg.grid);
        %step= 0.5/max(REG.img(REG.movIdx).cg.kernel3D(:));
        step=min(REG.img(REG.movIdx).voxelSize) / max(REG.img(REG.movIdx).cg.kernel3D(:))/5;
        for i=1:nx
            REG.img(REG.movIdx).cg.grid = pregrid;
            REG.img(REG.movIdx).cg.grid(i)=REG.img(REG.movIdx).cg.grid(i)-step;
            cg.computeDisplacementW(REG.img(REG.movIdx).cg,REG.img(REG.movIdx).D);
            if isfield (REG.img(REG.movIdx),'D0')
                if size( REG.img(REG.movIdx).D0) == size(REG.img(REG.movIdx).D) 
                    REG.img(REG.movIdx).D = REG.img(REG.movIdx).D + REG.img(REG.movIdx).D0;
                end
            end 
            %h12 = linearIntHist_(REG);
            h12 = pvi(REG);
            val1=simFunc_H( h12 );
            
            REG.img(REG.movIdx).cg.grid = pregrid;
            REG.img(REG.movIdx).cg.grid(i)=REG.img(REG.movIdx).cg.grid(i)+step;
            cg.computeDisplacementW(REG.img(REG.movIdx).cg,REG.img(REG.movIdx).D);
            if isfield (REG.img(REG.movIdx),'D0')
                if size( REG.img(REG.movIdx).D0) == size(REG.img(REG.movIdx).D) 
                    REG.img(REG.movIdx).D = REG.img(REG.movIdx).D + REG.img(REG.movIdx).D0;
                end
            end             
            %h12 = linearIntHist_(REG);
            h12 = pvi(REG);
            val2=simFunc_H( h12 );
            
            if val>max(val1,val2)
                gradient(i) =  0; 
                printf("0");
            else
                gradient(i) = val2 - val1;
                printf(".");
            end
            %printf("%f ", gradient(i));

        end  
        gradient=gradient/(2*step);
    end
    REG.img(REG.movIdx).cg.grid = deepCopy(pregrid);
    printf("\n");
    toc(t0);
    
    global T1
    if T1(end)==-1
        T1(end)=toc(t0);
    end