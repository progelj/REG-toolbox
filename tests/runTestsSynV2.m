%runTests
clear all; close all;
printf('pid: %d\n',getpid());

global cgSteps CFsteps CFtime err REG;

%define the synth. deformation:
%Gcenter = [70 70 91]; % [91 109 91]; %center of deformation in the center of image
Gsigma = 40;
Gamplitude = 8  *[1 1 1]; %equal in all three directions
useTrueH12 = 0;

%Gcenters=40 + ceil ( rand(4,3).*[181-80 217-80 181-80] )
Gcenters =[
    55   128    49
   135    97    84
    81    96   129
    66   151    67
]


for caseNr=1:size(Gcenters,1)
    Gcenter=Gcenters(caseNr,:)

SimMethod=3;
%testSynthGaussV2( Gcenter, Gsigma, Gamplitude, SimMethod, useTrueH12);

SimMethod=13;
%testSynthGaussV2( Gcenter, Gsigma, Gamplitude, SimMethod, useTrueH12);

SimMethod=11;
%testSynthGaussV2( Gcenter, Gsigma, Gamplitude, SimMethod, useTrueH12);

SimMethod=23;
%testSynthGaussV2( Gcenter, Gsigma, Gamplitude, SimMethod, useTrueH12);

SimMethod=21;
testSynthGaussV2( Gcenter, Gsigma, Gamplitude, SimMethod, useTrueH12);

end