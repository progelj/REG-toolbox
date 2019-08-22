function testDIR4Dn( DIR4Did, SimMethod)
    
clear global
%global REG; 
%clear REG;
global REG;
checkData();
%===============================================================================
%% define the problem 
%===============================================================================
imsize=load(['./data/Case' num2str(DIR4Did) 'Pack/size.txt']); 
voxSize=load(['./data/Case' num2str(DIR4Did) 'Pack/VoxSize.txt']);
fname=ls(['./data/Case' num2str(DIR4Did) 'Pack/Images/case' num2str(DIR4Did) '_T00*']);
LoadRawVolume( 1, fname, imsize, voxSize, 'int16' ); 
fname=ls(['./data/Case' num2str(DIR4Did) 'Pack/Images/case' num2str(DIR4Did) '_T50*']);
LoadRawVolume( 2, fname, imsize, voxSize, 'int16' );  
REG.img(1).data_orig=max(0, REG.img(1).data_orig);
REG.img(1).data=im2uint8_(REG.img(1).data_orig);
REG.img(2).data_orig=max(0, REG.img(2).data_orig);
REG.img(2).data=im2uint8_(REG.img(2).data_orig);

fname=ls(['./data/Case' num2str(DIR4Did) 'Pack/?xtremePhases/?ase' num2str(DIR4Did) '_*300_T00_xyz.txt']);
xyzRef = load(fname); %ref 
fname=ls(['./data/Case' num2str(DIR4Did) 'Pack/?xtremePhases/?ase' num2str(DIR4Did) '_*300_T50_xyz.txt']);
xyzMov = load(fname); %mov

%-------------------------------------------------------------------------------

REG.refIdx = int32(1);
REG.movIdx = int32(2);

regHR = REG;
regLR1 = decimate_reg(regHR);
regLR2 = decimate_reg(regLR1);

checkData();

global cgSteps; cgSteps={};  % show debug info
global CFsteps; CFsteps=[0];
global CFtime; CFtime=[];
global err; err=[];
global T1; T1=[];

% ==============================================================================
if DIR4Did<=5 % LR1

% ---- optim LR1 iteration 1----------------------------------------------------
REG = regLR1;  
T1=[T1; -1];
CFtimeStart=tic();
NCGmin=2;
PDFfilterSize=6;
SM=SimMethod(1);
optimizeBSpline(SM, NCGmin, PDFfilterSize);
CFtime=[CFtime; toc(CFtimeStart)];
regLR1=REG;
%-------- evaluation
regHR.img(regHR.movIdx).D = interpolateD ( regHR.img(regHR.movIdx), regLR1.img(regLR1.movIdx).D );
[e1, e0] =  evaluateResults(regHR.img(regHR.movIdx).D, regHR.img(regHR.movIdx).voxelSize, xyzRef, xyzMov);
err=[err; [e0 e1] ];

% save results
storeResults;


% ---- optim LR2 iteration 2----------------------------------------------------
REG = regLR1;  
T1=[T1; -1];
CFsteps=[CFsteps;0];
CFtimeStart=tic();
NCGmin=4;
PDFfilterSize=6;
if length(SimMethod)>=2
    SM=SimMethod(2);
else 
    SM=SimMethod(end);
end
optimizeBSpline(SM, NCGmin, PDFfilterSize);
CFtime=[CFtime; toc(CFtimeStart)];
regLR1=REG;
%-------- evaluation
regHR.img(regHR.movIdx).D = interpolateD ( regHR.img(regHR.movIdx), regLR1.img(regLR1.movIdx).D );
[e1, e0] =  evaluateResults(regHR.img(regHR.movIdx).D, regHR.img(regHR.movIdx).voxelSize, xyzRef, xyzMov);
err=[err; [e0 e1] ];

% save results
storeResults;

% ---- optim LR2 iteration 3----------------------------------------------------
REG = regLR1;  
T1=[T1; -1];
CFsteps=[CFsteps;0];
CFtimeStart=tic();
NCGmin=8;
PDFfilterSize=6;
if length(SimMethod)>=3
    SM=SimMethod(3);
else 
    SM=SimMethod(end);
end
optimizeBSpline(SM, NCGmin, PDFfilterSize);
CFtime=[CFtime; toc(CFtimeStart)];
regLR1=REG;
%-------- evaluation
regHR.img(regHR.movIdx).D = interpolateD ( regHR.img(regHR.movIdx), regLR1.img(regLR1.movIdx).D );
[e1, e0] =  evaluateResults(regHR.img(regHR.movIdx).D, regHR.img(regHR.movIdx).voxelSize, xyzRef, xyzMov);
err=[err; [e0 e1] ];

% save results
storeResults;
     
end
% ==============================================================================
if DIR4Did>=6  % LR2
    
% ---- optim LR2 iteration 1----------------------------------------------------
REG = regLR2;  
T1=[T1; -1];
CFtimeStart=tic();
NCGmin=2;
PDFfilterSize=6;
SM=SimMethod(1)
optimizeBSpline(SM, NCGmin, PDFfilterSize);
CFtime=[CFtime; toc(CFtimeStart)];
regLR2=REG;
%-------- evaluation
regLR1.img(regLR1.movIdx).D = interpolateD ( regLR1.img(regLR1.movIdx), regLR2.img(regLR2.movIdx).D );
regHR.img(regHR.movIdx).D = interpolateD ( regHR.img(regHR.movIdx), regLR1.img(regLR1.movIdx).D );
[e1, e0] =  evaluateResults(regHR.img(regHR.movIdx).D, regHR.img(regHR.movIdx).voxelSize, xyzRef, xyzMov);
err=[err; [e0 e1] ];

% save results
storeResults;


% ---- optim LR2 iteration 2----------------------------------------------------
REG = regLR2;  
T1=[T1; -1];
CFsteps=[CFsteps;0];
CFtimeStart=tic();
NCGmin=4;
PDFfilterSize=6;
if length(SimMethod)>=2
    SM=SimMethod(2);
else 
    SM=SimMethod(end);
end
optimizeBSpline(SM, NCGmin, PDFfilterSize);
CFtime=[CFtime; toc(CFtimeStart)];
regLR2=REG;
%-------- evaluation
regLR1.img(regLR1.movIdx).D = interpolateD ( regLR1.img(regLR1.movIdx), regLR2.img(regLR2.movIdx).D );
regHR.img(regHR.movIdx).D = interpolateD ( regHR.img(regHR.movIdx), regLR1.img(regLR1.movIdx).D );
[e1, e0] =  evaluateResults(regHR.img(regHR.movIdx).D, regHR.img(regHR.movIdx).voxelSize, xyzRef, xyzMov);
err=[err; [e0 e1] ];

% save results
storeResults;
    
% ---- optim LR2 iteration 3----------------------------------------------------
REG = regLR2;  
T1=[T1; -1];
CFsteps=[CFsteps;0];
CFtimeStart=tic();
NCGmin=8;
PDFfilterSize=6;
if length(SimMethod)>=3
    SM=SimMethod(3);
else 
    SM=SimMethod(end);
end
optimizeBSpline(SM, NCGmin, PDFfilterSize);
CFtime=[CFtime; toc(CFtimeStart)];
regLR2=REG;
%-------- evaluation
regLR1.img(regLR1.movIdx).D = interpolateD ( regLR1.img(regLR1.movIdx), regLR2.img(regLR2.movIdx).D );
regHR.img(regHR.movIdx).D = interpolateD ( regHR.img(regHR.movIdx), regLR1.img(regLR1.movIdx).D );
[e1, e0] =  evaluateResults(regHR.img(regHR.movIdx).D, regHR.img(regHR.movIdx).voxelSize, xyzRef, xyzMov);
err=[err; [e0 e1] ];

% save results
storeResults;

% ---- optim LR1 iteration 1----------------------------------------------------
if 0
%regLR1.img(regLR1.movIdx).D = interpolateD ( regLR1.img(regLR1.movIdx), regLR2.img(regLR2.movIdx).D );
REG = regLR1; 
T1=[T1; -1];
CFsteps=[CFsteps;0];
CFtimeStart=tic();
NCGmin=4;
PDFfilterSize=3;
if length(SimMethod)>=4
    SM=SimMethod(4);
else 
    SM=SimMethod(end);
end
optimizeBSpline(SM, NCGmin, PDFfilterSize);
CFtime=[CFtime; toc(CFtimeStart)];
regLR1=REG;
%-------- evaluation
regHR.img(regHR.movIdx).D = interpolateD ( regHR.img(regHR.movIdx), regLR1.img(regLR1.movIdx).D );
[e1, e0] =  evaluateResults(regHR.img(regHR.movIdx).D, regHR.img(regHR.movIdx).voxelSize, xyzRef, xyzMov);
err=[err; [e0 e1] ];

% save results
storeResults;
end %if 0/1
    
end
%===============================================================================






