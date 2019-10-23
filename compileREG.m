% Author: Peter Rogelj <peter.rogelj@upr.si>

[REGfolder,name,ext] = fileparts(which('compileREG'));
WorkFolder=pwd;
cd(REGfolder);
addpath(REGfolder);

if isoctave() , % compiling in Octave
  mkoctfile --mex -DMATLAB_MEX_FILE -W "-std=c++11" pvi.cpp
  mkoctfile --mex -DMATLAB_MEX_FILE -W "-std=c++11" linearIntHist_.cpp
  mkoctfile --mex -DMATLAB_MEX_FILE -W "-std=c++11" psm.cpp
  mkoctfile --mex -DMATLAB_MEX_FILE -W "-std=c++11" linearPsm_.cpp
  mkoctfile --mex -DMATLAB_MEX_FILE -W "-std=c++11" resampleRef2Mov.cpp
  mkoctfile --mex -DMATLAB_MEX_FILE -W "-std=c++11 -O3" resampleMov2Ref_.cpp
  mkoctfile --mex -DMATLAB_MEX_FILE -W "-std=c++11" inverseD_.cpp
  mkoctfile --mex -DMATLAB_MEX_FILE -W "-std=c++11" T2D.cpp


else % compiling in Matlab
  mex pvi.cpp
  mex linearIntHist_.cpp
  mex psm.cpp
  mex linearPsm_.cpp
  mex resampleRef2Mov.cpp
  mex resampleMov2Ref_.cpp
  mex inverseD_.cpp
  mex T2D.cpp

end

cd +cg
  cg.compileREGcg
cd ..

cd(WorkFolder);
