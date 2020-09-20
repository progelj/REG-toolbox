% Author: Peter Rogelj <peter.rogelj@upr.si>

function fa=gaussfilt3d(a,sigma)
% a common function for 3D Gaussian filtering for Matlab and Octave
if numel(sigma)==1;
    sgma=[sigma,sigma,sigma];
elseif numel(sigma)==2;
    sgma=[sigma(1),sigma(1),sigma(3)];
elseif numel(sigma)>=3; %3 components for x,y and z direction
    sgma=sigma(1:3);
else
    error("Invalid sigma for gaussfilt3d!");
end

if sgma(1)>0
    Filter = fspecial ("gaussian", [2*ceil(3*sgma(1)+1),1], sgma(1));
    Filter = Filter / max(Filter);
    fa = convn (a, Filter, "same");
end
if sgma(2)>0
    Filter = fspecial ("gaussian", [1,2*ceil(3*sgma(2)+1)], sgma(2));
    Filter = Filter / max(Filter);
    fa = convn (fa, Filter, "same");
end
if sgma(3)>0
    fsize= 2*ceil(3*sgma(3)+1);
    Filter = fspecial ("gaussian", [1,fsize], sgma(3));
    Filter = reshape( Filter,[1,1,fsize]);
    Filter = Filter / max(Filter);
    fa = convn (fa, Filter, "same");
end