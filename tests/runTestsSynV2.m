%runTests
clear all; close all;
printf('pid: %d\n',getpid());

global cgSteps CFsteps CFtime err REG;

%define the synth. deformation:
Gcenter = [70 70 91]; % [91 109 91]; %center of deformation in the center of image
Gsigma = 40;
Gamplitude = 8  *[1 1 1]; %equal in all three directions
useTrueH12 = 0;

SimMethod=3;
testSynthGaussV2( Gcenter, Gsigma, Gamplitude, SimMethod, useTrueH12);

SimMethod=13;
testSynthGaussV2( Gcenter, Gsigma, Gamplitude, SimMethod, useTrueH12);

SimMethod=11;
testSynthGaussV2( Gcenter, Gsigma, Gamplitude, SimMethod, useTrueH12);

SimMethod=23;
testSynthGaussV2( Gcenter, Gsigma, Gamplitude, SimMethod, useTrueH12);

SimMethod=21;
testSynthGaussV2( Gcenter, Gsigma, Gamplitude, SimMethod, useTrueH12);
