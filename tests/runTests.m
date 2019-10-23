%runTests
clear all; close all;
fprintf('pid: %d\n',getmyPID());

global cgSteps CFsteps CFtime err;

DIRid=5;
SimMethod=21;
testDIR4Dn(DIRid, SimMethod);