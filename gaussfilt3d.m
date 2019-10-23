% Author: Peter Rogelj <peter.rogelj@upr.si>

function fa=gaussfilt3d(a,sigma)
% a common function for 3D Gaussian filtering for Matlab and Octave

Filter = fspecial ("gaussian", [6*sigma+1,1], sigma);
Filter = Filter / max(Filter);
fa = convn (a, Filter, "same");
Filter = fspecial ("gaussian", [1,6*sigma+1], sigma);
Filter = Filter / max(Filter);
fa = convn (fa, Filter, "same");
Filter = fspecial ("gaussian", [1,1,6*sigma+1], sigma);
Filter = Filter / max(Filter);
fa = convn (fa, Filter, "same");