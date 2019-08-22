function testSynthGaussV2( Gcenter, Gsigma, Gamplitude, SimMethod, useTrueH12 )
    
clear global
%global REG; 
%clear REG;
global REG;
checkData();
if  nargin () < 5
    useTrueH12=0; % false
end
%===============================================================================
%% define the problem 
%===============================================================================
imsize=[181,217,181]; 
voxSize=[1,1,1];
LoadRawVolume(1, './data/t1_icbm_normal_1mm_pn3_rf0.rawb', imsize, voxSize);
LoadRawVolume(2, './data/t2_icbm_normal_1mm_pn3_rf0.rawb', imsize, voxSize);

% when using true h12
if useTrueH12
    REG.refIdx = int32(2);
    REG.movIdx = int32(1);
    trueH12=pvi(REG);
end

%generate a deformation field
REG.img(2).D = generateSynthGaussDef( size(REG.img(2).data), Gcenter, Gsigma, Gamplitude );

% Define a new image to serve as a reference
REG.img(3)=REG.img(2);
REG.refIdx = int32(1); REG.movIdx = int32(2);
REG.img(3).data = resampleMov2Ref_(REG);
REG.img(3).D = [];

%% register image 1 to image 3 - then we can compare an error as the deformation 
% of image 1 would ideally equal deformation of image 2:
REG.refIdx = int32(3);
REG.movIdx = int32(1);

regHR = REG;
regLR1 = decimate_reg(regHR);
regLR2 = decimate_reg(regLR1);

checkData();

%% --- initial information about the case --------------------------------------
% -- compute initial error:
e0 = computeErrorD (REG.img(2).D, zeros(size(REG.img(2).D)))
if IsGUI()
    %show the initial checkerboard image
    figure(1); imagesc ( showCheckerboard( REG.img(1).data, REG.img(3).data ) ); colormap gray;
    figure(2); imagesc ( showCheckerboard( REG.img(2).data, REG.img(3).data ) ); colormap gray;
end
 %------------------------------------------------------------------------------


global cgSteps; cgSteps={};  % show debug info
global CFsteps; CFsteps=[0];
global CFtime; CFtime=[];
global err; err=[];
global T1; T1=[];
DIR4Did = -Gsigma;

% ==============================================================================
% ---- optim LR1 iteration 1----------------------------------------------------
if 0 %0/1
REG = regLR1;  
T1=[T1; -1];
CFtimeStart=tic();
NCGmin=4;
PDFfilterSize=6;
if useTrueH12
    optimizeBSpline(SimMethod, NCGmin, PDFfilterSize, trueH12);
else 
    optimizeBSpline(SimMethod, NCGmin, PDFfilterSize);
end
CFtime=[CFtime; toc(CFtimeStart)];
regLR1=REG;
%-------- evaluation
e1 =  computeErrorD (REG.img(1).D, REG.img(2).D)
err=[err; [e0 e1] ];

% save results
storeResults;
end % if 0/1

% ---- optim LR1 iteration 2----------------------------------------------------
if 0 %0/1
REG = regLR1;  
T1=[T1; -1];
CFsteps=[CFsteps;0];
CFtimeStart=tic();
NCGmin=8;
PDFfilterSize=6;
if useTrueH12
    optimizeBSpline(SimMethod, NCGmin, PDFfilterSize, trueH12);
else 
    optimizeBSpline(SimMethod, NCGmin, PDFfilterSize);
end
CFtime=[CFtime; toc(CFtimeStart)];
regLR1=REG;
%-------- evaluation
e1 =  computeErrorD (REG.img(1).D, REG.img(2).D)
err=[err; [e0 e1] ];

% save results
storeResults;

end % if 0/1

     
% ==============================================================================
%regHR.img(regHR.movIdx).D = interpolateD ( regHR.img(regHR.movIdx), regLR1.img(regLR1.movIdx).D );

if 0
% ---- optim HR iteration 1----------------------------------------------------
REG = regHR;  
T1=[T1; -1];
CFsteps=[CFsteps;0];
CFtimeStart=tic();
NCGmin=10;
PDFfilterSize=2;
if useTrueH12
    optimizeBSpline(SimMethod, NCGmin, PDFfilterSize, trueH12);
else 
    optimizeBSpline(SimMethod, NCGmin, PDFfilterSize);
end
CFtime=[CFtime; toc(CFtimeStart)];
regLR1=REG;
%-------- evaluation
e1 =  computeErrorD (REG.img(1).D, REG.img(2).D)
err=[err; [e0 e1] ];

% save results
storeResults;
end

if 1
% ---- optim HR iteration 1----------------------------------------------------
REG = regHR;  
T1=[T1; -1];
CFsteps=[CFsteps;0];
CFtimeStart=tic();
NCGmin=8;
PDFfilterSize=2;
if useTrueH12
    optimizeBSpline(SimMethod, NCGmin, PDFfilterSize, trueH12);
else 
    optimizeBSpline(SimMethod, NCGmin, PDFfilterSize);
end
CFtime=[CFtime; toc(CFtimeStart)];
regLR1=REG;
%-------- evaluation
e1 =  computeErrorD (REG.img(1).D, REG.img(2).D)
err=[err; [e0 e1] ];

% save results
storeResults;
end