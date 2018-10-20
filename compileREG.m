% Author: Peter Rogelj <peter.rogelj@upr.si>

[REGfolder,name,ext] = fileparts(which('compileREG'));
WorkFolder=pwd;
cd(REGfolder);

if isoctave() , % compiling in Octave
  mkoctfile --mex -DMATLAB_MEX_FILE -W "-std=c++11" pvi.cpp
  mkoctfile --mex -DMATLAB_MEX_FILE -W "-std=c++11" linearIntHist_.cpp
  mkoctfile --mex -DMATLAB_MEX_FILE -W "-std=c++11" psm.cpp
  mkoctfile --mex -DMATLAB_MEX_FILE -W "-std=c++11" linearPsm_.cpp
  mkoctfile --mex -DMATLAB_MEX_FILE -W "-std=c++11" resampleRef2Mov.cpp
  mkoctfile --mex -DMATLAB_MEX_FILE -W "-std=c++11 -O3" resampleMov2Ref_.cpp


else % compiling in Matlab
  mex pvi.cpp
  mex linearIntHist_.cpp
  mex psm.cpp
  mex linearPsm_.cpp
  mex resampleRef2Mov.cpp
  mex resampleMov2Ref_.cpp


end

cd(WorkFolder);
