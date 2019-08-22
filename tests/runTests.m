%runTests
clear all; close all;
printf('pid: %d\n',getpid());

global cgSteps CFsteps CFtime err;

DIRid=5;
SimMethod=21;
testDIR4Dn(DIRid, SimMethod);