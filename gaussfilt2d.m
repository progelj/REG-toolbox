% Author: Peter Rogelj <peter.rogelj@upr.si>

function fa=gaussfilt2d(a,sigma)
% a common function for Gaussian filtering for Matlab and Octave
% 2d

if isoctave() , % Octave
    fa = imsmooth(a, "Gaussian", sigma); %"Gaussian" filter for octave
else
    fa = imgaussfilt(a, sigma, 'Padding', 0);  % for Matlab
end
