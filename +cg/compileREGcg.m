% Author: Peter Rogelj <peter.rogelj@upr.si>

if isoctave() , % compiling in Octave
  mkoctfile --mex -DMATLAB_MEX_FILE -W "-std=c++11" computeDisplacement.cpp
  mkoctfile --mex -DMATLAB_MEX_FILE -W "-std=c++11" modifyDisplacement.cpp


else % compiling in Matlab
  mex computeDisplacement.cpp
  mex modifyDisplacement.cpp

end

