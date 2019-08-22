function [val, gradient] = criterionFunction2c(x, simFunc_H, PSF)
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
    
    %h12 = linearIntHist_(REG);
    h12 = pvi(REG);

    if (nargin >= 3)
        if numel(PSF)>2
            simFunc_H = @(x) psmp( x , PSF );
        else 
            if numel(PSF)==2
                PDFfilterSize=PSF(2); %if PSF not defined a 2 element vector is expected, element 1: method (1=MI, 2=UH), 2: PDFfilterSize
            else
                PDFfilterSize = 4;
            end
            h12f = gaussfilt2d(h12, PDFfilterSize);  % % gausian filtering as parzen window estimation for the case of low image reolution % 1.5 % for Matlab
            p12 = h2p(h12f);
            switch PSF(1)
                case 1
                    PSF = psfMI(p12);
                case 2
                    PSF = psfUH(p12);
                otherwise
                    error("invalid point similarity measure method selected!");
            end
            simFunc_H = @(x) psmp( x , PSF );  
        end
    end
        
    % compute similarity function value
    REG.img(REG.movIdx).cg.grid = single(reshape(x,sx)); 
    cg.computeDisplacementW(REG.img(REG.movIdx).cg,REG.img(REG.movIdx).D);
    if isfield (REG.img(REG.movIdx),'D0')
        if size( REG.img(REG.movIdx).D0) == size(REG.img(REG.movIdx).D) 
            REG.img(REG.movIdx).D = REG.img(REG.movIdx).D + REG.img(REG.movIdx).D0;
        end
    end 
    

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
        gradient = single(zeros(sx));
        D0=deepCopy(REG.img(REG.movIdx).D);
        
        step=min(REG.img(REG.movIdx).voxelSize) / max(REG.img(REG.movIdx).cg.kernel3D(:))/5;
                   
        for i=1:nx
            REG.img(REG.movIdx).ROI= cg.getCPROI (REG.img(REG.movIdx), i);
            
            REG.img(REG.movIdx).D = deepCopy(D0);
            %h12 = linearIntHist_(REG);
            h12 = pvi(REG);
            %p12 = h2p( h12 );
            %val0=simFunc_H( p12 );   
            val0=simFunc_H( h12 );        
            
            %cg.modifyDisplacement(REG.img(REG.movIdx).cg, int32([ix iy iz it]), -step, D0, REG.img(REG.movIdx).D );
            cg.modifyDisplacement(REG.img(REG.movIdx).cg, int32(i), -step, D0, REG.img(REG.movIdx).D );

            %h12 = linearIntHist_(REG);
            h12 = pvi(REG);
            %p12 = h2p( h12 );
            %val1=simFunc_H( p12 );
            val1=simFunc_H( h12 );
         
            %cg.modifyDisplacement(REG.img(REG.movIdx).cg, int32([ix iy iz it]), step, D0, REG.img(REG.movIdx).D );
            cg.modifyDisplacement(REG.img(REG.movIdx).cg, int32(i), step, D0, REG.img(REG.movIdx).D );

            %h12 = linearIntHist_(REG);
            h12 = pvi(REG);
            %p12 = h2p( h12 );
            %val2=simFunc_H( p12 );
            val2=simFunc_H( h12 );
            
            if val0>max(val1,val2)
                gradient(i) =  0;
                printf("0");
            else
                gradient(i) = val2 - val1;
                printf(".");
            end
            %printf("val: %f %f %f , step: %d gradient: %f\n" , val0, val1, val2, step, gradient(i));
            
        end  
        gradient=gradient/(2*step);
        gradient=reshape(gradient,size(x)); 
    end
    REG.img(REG.movIdx).ROI=[];
    clear REG.img(REG.movIdx).ROI;
    %REG.img(REG.movIdx).cg.grid = pregrid;
    printf("\n");
    toc(t0);
    
    global T1
    if T1(end)==-1
        T1(end)=toc(t0);
    end